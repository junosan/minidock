#!/bin/bash

# Print currently selected input method's language on macOS

# http://stackoverflow.com/questions/21597804 with modifications
# Depending on the input method, language may be stored in key
#     "KeyboardLayout Name" or "Bundle ID" or "Input Mode"
# so instead of grep'ing for the key, grep for the language

pair_list='U.S.;🇺🇸 Korean;🇰🇷 Japanese;🇯🇵 British;🇬🇧 Canadian;🇨🇦 Australian;🇦🇺 SCIM;🇨🇳 TCIM;🇹🇼 Spanish;🇪🇸 Russian;🇷🇺 German;🇩🇪 Austrian;🇦🇹 French;🇫🇷 Italian;🇮🇹'

src=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources`

# assumes no ' ' in language names
for pair in $pair_list; do
    lang=(${pair//;/ }) # ';'->' ' then convert to array
    echo $src | grep -sq "${lang[0]}" && echo -n "${lang[1]}" && break
done
