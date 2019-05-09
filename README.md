
# minidock

&nbsp;&nbsp;&nbsp; <img src="readme/app_name.png" width="34"/>
&nbsp;&nbsp;&nbsp; <img src="readme/app_icon.png" width="34"/>
&nbsp;&nbsp;&nbsp; <img src="readme/app_none.png" width="34"/>

*minidock* is an application for [iTerm2](https://www.iterm2.com) that
creates a miniature dock (26 px wide) with a list of currently open apps
and some status information from the Menu Bar.
It is intended to be used with the Menu Bar & Dock hidden for
screen estate/minimalism.

It creates a tiny display placed at the middle right side or the top right
  corner with (each can be turned on/off)
  - clock - hour & minute
  - input language as a flag
  - audio output device name (first letter) and volume (- mute, 0~9, | full)
  - internet connection (nc - no connection, country - if on VPN)
  - currently open apps (decreasing order in recency of focus)


# How to use

- Clone repository and build binaries with `build.sh`
- Create a new [iTerm2](https://www.iterm2.com) profile with
  - Profiles > Window > Style > No Title Bar
  - Profiles > Terminal > (off) Disable session-initialized window resizing
  - Profiles > Keys > A hotkey opens a dedicated window with this profile
    - Set hotkey
    - (on) Pin hotkey window, Floating window
- Above screenshots were taken after setting
  - Profiles > Colors (Background/Cursor f4f4f4)
  - Profiles > Text > Font (14pt Menlo Regular, Anti-aliased)
- Edit `$HOME/.minidockrc` to configure behavior


## Displaying icons in the app list
- Modify `$HOME/.minidockrc` to include `applist_use_icons 1`
- Extract icons from `/Applications/*/*.app`s using `extract_icons.sh`
- Put them in `icons` directory as `icons/$APPNAME.png`, where `$APPNAME`s
  can be found by using `bin/print_app` while the apps are running

## Notes on using multiple monitors
- If using an external monitor in 'Mirror Displays' mode, the external monitor
  needs to be placed on the right side and be set as the main display
  (In System Preferences > Displays > Arrangement, put the external monitor
  on the right side and drag the menu bar to the external monitor before
  turning mirroring on)
- If not using the 'Mirror Displays' mode, the external monitor can be placed
  on any side
