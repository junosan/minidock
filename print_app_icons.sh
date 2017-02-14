#!/bin/bash

# Consulted imgls example of 
#   https://www.iterm2.com/documentation-images.html

SCRIPT_PATH=${0%/*}

function print_image() {
    # tmux requires that an unrecognized control <sequence> be wrapped as
    #   DCS tmux; <sequence> ST  (without spaces)
    # and that all ESCs in <sequence> be replaced with ESC ESC, where
    #   ESC = \033, DCS = \033P, ST = \033\\
    # (see http://invisible-island.net/xterm/ctlseqs/ctlseqs.html)

    # image start (OSC)
    if [ x"$TERM" = "xscreen" ] ; then
        printf "\033Ptmux;\033\033]"
    else
        printf "\033]"
    fi

    # header
    printf '1337;File=name='`echo -n "$1" | base64`";inline=1;height=1;width=2;preserveAspectRatio=true:"
    
    # data
    base64 < "$1"

    # image end (^G)
    if [ x"$TERM" = "xscreen" ] ; then
        printf "\a\033\\"
    else
        printf "\a"
    fi
}

IFS=';'
for app in $1; do
    if [[ ${app::1} = '*' ]]; then
        app=${app:1}
        is_focus=true
    else
        is_focus=false
    fi

    [ $app = 'Finder' ] && continue
    
    file="$SCRIPT_PATH/icons/$app.png"
    
    if [ -f $file ]; then
        printf "\n"
        print_image "$file"
        printf "\033[D" # move cursor left once
    else
        printf "\n\033[38;5;251m%s" ${app:0:2}
    fi

    if $is_focus; then
        printf "• "
    else
        printf "  "
    fi
done
unset IFS
