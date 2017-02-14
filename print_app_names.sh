#!/bin/bash

# xterm-256color
#   Foreground  \033[38;5;(color#)m
#   Background  \033[48;5;(color#)m
#   Color table https://jonasjacek.github.io/colors/
# Avoid colors in the range 0~15 as they can be changed by settings

IFS=';'
for app in $1; do
    if [[ ${app::1} = '*' ]]; then
        app=${app:1}
        is_focus=true
    else
        is_focus=false
    fi

    [ $app = 'Finder' ] && continue
    
    case $app in
        'Activity Monitor')
            printf "\n\033[38;5;16mA\033[38;5;28mc" ;;
        'App Store')
            printf "\n\033[38;5;27mA\033[38;5;33mp" ;;
        'Calculator')
            printf "\n\033[38;5;249mC\033[38;5;208ml" ;;
        'Calendar')
            printf "\n\033[38;5;203mC\033[38;5;251md" ;;
        'Code')
            printf "\n\033[38;5;27mC\033[38;5;251md" ;;
        'Contacts')
            printf "\n\033[38;5;130mCn" ;;
        'Dictionary')
            printf "\n\033[38;5;124mDc" ;;
        'Firefox')
            printf "\n\033[38;5;202mF\033[38;5;33mf" ;;
        'Illustrator')
            printf "\n\033[38;5;94mI\033[38;5;214ml" ;;
        'iTerm2')
            printf "\n\033[38;5;16mi\033[38;5;28mT" ;;
        'iTunes')
            printf "\n\033[38;5;205mi\033[38;5;135mT" ;;
        'Mail')
            printf "\n\033[38;5;27mM\033[38;5;245ma" ;;
        'Maps')
            printf "\n\033[38;5;144mMp" ;;
        'MATLAB')
            printf "\n\033[38;5;24mM\033[38;5;160mt" ;;
        'Messages')
            printf "\n\033[38;5;75mM\033[38;5;251ms" ;;
        'Microsoft Excel')
            printf "\n\033[38;5;28mEx" ;;
        'Microsoft PowerPoint')
            printf "\n\033[38;5;160mPw" ;;
        'Microsoft Remote Desktop')
            printf "\n\033[38;5;160mRm" ;;
        'Microsoft Word')
            printf "\n\033[38;5;27mWd" ;;
        'Notes')
            printf "\n\033[38;5;214mN\033[38;5;251mt" ;;
        'OmniGraffle')
            printf "\n\033[38;5;34mO\033[38;5;240mm" ;;
        'Photos')
            printf "\n\033[38;5;202mP\033[38;5;106mh" ;;
        'Photoshop')
            printf "\n\033[38;5;18mP\033[38;5;33ms" ;;
        'Preview')
            printf "\n\033[38;5;69mPv" ;;
        'Reminders')
            printf "\n\033[38;5;208mR\033[38;5;251mm" ;;
        'Safari')
            printf "\n\033[38;5;75mS\033[38;5;203mf" ;;
        'Skype')
            printf "\n\033[38;5;75mS\033[38;5;251mk" ;;
        'System Preferences')
            printf "\n\033[38;5;240mS\033[38;5;251my" ;;
        'Telegram')
            printf "\n\033[38;5;75mT\033[38;5;251mg" ;;
        'Terminal')
            printf "\n\033[38;5;16mTm" ;;
        'TeXShop')
            printf "\n\033[38;5;109mT\033[38;5;251mx" ;;
        'TextEdit')
            printf "\n\033[38;5;251mE\033[38;5;240md" ;;
        'TextWrangler')
            printf "\n\033[38;5;214mT\033[38;5;75mW" ;;
        'Transmission')
            printf "\n\033[38;5;160mT\033[38;5;245mr" ;;
        'VirtualBox'*)
            printf "\n\033[38;5;18mV\033[38;5;33mt" ;;
        'VLC')
            printf "\n\033[38;5;208mV\033[38;5;251mL" ;;
        *)
            printf "\n\033[38;5;251m%s" ${app:0:2} ;;
    esac
    
    if $is_focus; then
        printf "\033[0m• "
    else
        printf "  "
    fi

done
unset IFS
