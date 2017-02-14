#!/bin/bash

# See README.md

SCRIPT_PATH=${0%/*}

POS_Y_MIDDLE=1     # 0 - top right corner, 1 - middle right side
IGNORE_IP_LOC='kr' # ip_loc only drawn if not this value (no connection or VPN)

# '' (turn off) or 'print_app_icons.sh' or 'print_app_names.sh'
PRINT_APP_SH='print_app_names.sh'

# Unless poll_ip_loc.sh is already running, launch one in the background
cnt=`ps -A | grep 'poll_ip_loc\.sh' | wc -l`
[ $cnt = 0 ] && $SCRIPT_PATH/poll_ip_loc.sh &

# Storage for variables inside loop
rows_prev=0
pos_x_prev=0
pos_y_prev=0

while sleep .1; do

    input_lang=`$SCRIPT_PATH/input_lang.sh` # comment out to turn off
    if ! [ -z $input_lang ]; then
        disp_lang=1
    else
        disp_lang=0
    fi

    audio_device=`$SCRIPT_PATH/audio_device` # comment out to turn off
    if ! [ -z $audio_device ]; then
        disp_audio=1
    else
        disp_audio=0
    fi
    
    disp_ip_loc=0 # set IGNORE_IP_LOC='*' to turn off
    if [[ $IGNORE_IP_LOC != '*' ]]; then
        [ -f /tmp/poll_ip_loc.log ] && ip_location=`cat /tmp/poll_ip_loc.log`
        [ -z $ip_location ] && ip_location='nc'
        [ $ip_location != $IGNORE_IP_LOC ] && disp_ip_loc=1
    fi


    # Calculate size
    rows=$((2 + $disp_lang + $disp_audio + $disp_ip_loc))
    
    if ! [ -z $PRINT_APP_SH ]; then
        # Get number of open apps
        apps=`$SCRIPT_PATH/print_app`
        commas=${apps//[^;]} # remove all except semicolons
        app_cnt=${#commas}   # app count excluding Finder == number of semicolons
        rows=$(($rows + 1 + $app_cnt)) # add horizontal bar + apps
    fi 

    # Resize
    # Prevent content shifting by pre-/post-scrolling
    [ $rows -gt $rows_prev ] && printf "\033["$(($rows - $rows_prev))"S"
    [ $rows  != $rows_prev ] && printf "\033[8;"$rows";20t" # minimum is 2;20
    [ $rows -lt $rows_prev ] && printf "\033["$(($rows_prev - $rows))"T"
    rows_prev=$rows


    # Calculate position based on screen size & window size
    # Window size with 14pt Menlo Regular
    #   size_x = col *  8 + 26 (left edge to first character distance 5)
    #   size_y = row * 17 +  6
    sizes=(`$SCRIPT_PATH/screen_size`)

    # Compensate for x-coordinate modification due to the Dock
    orientation=`defaults read com.apple.dock orientation`
    if [ $orientation = 'left' ]; then
        main_width=${sizes[1]} # use visibleFrame's width
    else
        main_width=${sizes[0]} # use frame's width
    fi
    pos_x=$(($main_width - 26)) # substract window width (5 + 2 * 8 + 5)
    
    if [ $POS_Y_MIDDLE = 0 ]; then
        pos_y=0
    else
        pos_y=$(((${sizes[2]} - ($rows * 17 + 6)) / 2)) # font size dependent

        # Compensate for y-coordinate modification due to the Menu Bar
        menu_hidden=`defaults read NSGlobalDomain _HIHideMenuBar`
        [ $menu_hidden = 0 ] && pos_y=$(($pos_y - (${sizes[2]} - ${sizes[3]})))
    fi
    
    # Reposition
    [[ $pos_y != $pos_y_prev || $pos_x != $pos_x_prev ]] && printf "\033[3;"$pos_x";"$pos_y"t"
    pos_x_prev=$pos_x
    pos_y_prev=$pos_y


    # Display
    # Set third & fourth characters in a line as ' '
    # in case something goes wrong and prints stuff there
    
    printf "\033[1;1H" # cursor at top left corner
    
    printf "\033[38;5;251m" # Grey78 c6c6c6
    date "+%I  " # hour
    printf "%s  " $(date "+%M") # minute (suppress \n)
    [ $disp_lang   = 1 ] && printf "\n$input_lang  "
    [ $disp_audio  = 1 ] && printf "\n$audio_device  "
    [ $disp_ip_loc = 1 ] && printf "\n$ip_location  "
    
    # App list
    if ! [ -z $PRINT_APP_SH ]; then
        printf "\n──  "
        $SCRIPT_PATH/$PRINT_APP_SH "$apps"
    fi
    
    printf "\033[1;5H" # cursor out of screen

done
