#!/bin/bash

# See README.md

SCRIPT_PATH=${0%/*}

WINDOW_WIDTH=26    # font dependent
IGNORE_IP_LOC='kr' # ip_loc only drawn if not this value (no connection or VPN)

# '' (turn off) or 'print_app_icons.sh' or 'print_app_names.sh'
PRINT_APP_SH='print_app_names.sh'

# Unless poll_ip_loc.sh is already running, launch one in the background
cnt=`ps -A | grep 'poll_ip_loc\.sh' | wc -l`
[ $cnt = 0 ] && $SCRIPT_PATH/poll_ip_loc.sh &

# Storage for $rows, $pos_x inside loop
rows_prev=0
pos_x_prev=0

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
    # prevent content shifting by pre-/post-scrolling
    [ $rows -gt $rows_prev ] && printf "\033["$(($rows - $rows_prev))"S"
    [ $rows  != $rows_prev ] && printf "\033[8;"$rows";20t" # minimum is 2;20
    [ $rows -lt $rows_prev ] && printf "\033["$(($rows_prev - $rows))"T"
    rows_prev=$rows


    # Calculate position based on screen size
    # Dock can modify coordinates, so compensate for it
    widths=(`$SCRIPT_PATH/screen_width`)
    orientation=`defaults read com.apple.dock orientation`
    if [ $orientation = 'left' ]; then
        main_width=${widths[1]} # use visibleFrame's width
    else
        main_width=${widths[0]} # use frame's width
    fi
    pos_x=$(($main_width - $WINDOW_WIDTH))
    
    # Reposition
    [ $pos_x != $pos_x_prev ] && printf "\033[3;"$pos_x";0t"
    pos_x_prev=$pos_x


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
