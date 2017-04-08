#!/bin/bash

# For all .apps in /Applications, find icon files and convert to 64 x 64 png

# - Store icons as icons/$APPNAME.png without internal subdirectories,
#   where $APPNAME can be found by using bin/print_app while the app is running
#   (the name found in Info.plist is usually the right one, but not always)
# - Icons can be any size, but large images will slow iTerm2 down

SCRIPT_PATH=${0%/*}

APP_PATH=/Applications
OUT_PATH=~/Desktop/icons
SIZE=64

mkdir -p $OUT_PATH

IFS=$'\n'
for app in `find $APP_PATH -name '*.app' | grep -v '\.app/'`; do # exclude app-inside-app
    app=${app#$APP_PATH/}
    app_name=${app##*/} # name.app

    app_path=${app%$app_name}
    app_path=${app_path%/} # $app may or may not contain /
    app_name=${app_name%.app}

    info_plist=$APP_PATH/$app_path/$app_name.app/Contents/Info.plist

    icns_name=`defaults read $info_plist CFBundleIconFile 2>/dev/null`
    icns_name=${icns_name%.icns}
    icns_filename=$APP_PATH/$app_path/$app_name.app/Contents/Resources/$icns_name.icns
    [ -f $icns_filename ] || continue 

    out_name=`defaults read $info_plist CFBundleDisplayName 2>/dev/null`
    [ -z $out_name ] && out_name=$app_name
    out_filename=$OUT_PATH/$app_path/$out_name.png

    [ -z $app_path ] || printf "%s/" $app_path
    printf "%s.png\n" $out_name

    mkdir -p $OUT_PATH/$app_path
    sips -s format png -z $SIZE $SIZE $icns_filename --out $out_filename 1>/dev/null
done
unset IFS
