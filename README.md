# minidock.sh

&nbsp;&nbsp;&nbsp; <img src="readme/app_name.png" width="34"/>
&nbsp;&nbsp;&nbsp; <img src="readme/app_icon.png" width="34"/>
&nbsp;&nbsp;&nbsp; <img src="readme/app_none.png" width="34"/>

`minidock.sh` is a Bash script for [iTerm2](https://www.iterm2.com) that
creates a miniature dock (26 px wide) with a list of currently open apps
and some status information usually served on the Menu Bar.
It is intended to provide just enough information to help make macOS less
inconvenient with the Menu Bar & Dock hidden for screen estate/minimalism.

- Requires [iTerm2](https://www.iterm2.com) in 'No Title Bar' mode
- Creates a tiny display with
  - clock - hour & minute
  - (optional) input language as a flag
  - (optional) audio output device name (first letter) 
               and volume (- mute, 0~9, | full)
  - (optional) internet connection
               (nc - no connection, country - to tell if on VPN)
  - (optional) currently open apps (dot on focused app)
- Placed at the middle right side or the top right corner;
  automatically adjusts to screen size changes 


# How to use

- Clone repository
- Build auxiliary tools with `build.sh`
- Configure options in `minidock.sh`
- Run within [iTerm2](https://www.iterm2.com) after setting
  - Profiles > Colors (Background/Cursor f7f7f7) (optional)
  - Profiles > Text > Font (14pt Menlo Regular, Anti-aliased) (optional)
  - Profiles > Window > Style > No Title Bar
  - Profiles > Terminal > (off) Disable session-initialized window resizing
  - Keys > Show/hide *iTerm2* with a system-wide hotkey
  - Advanced > Hide *iTerm2* from the dock (optional)
- If *iTerm2* is not showing up, use the show/hide hotkey (`option-space`)
  after focusing on a different window
- To launch on *iTerm2* startup, edit `.bash_profile` to include
  (unless run in background with a ` &`, it will have trouble exiting cleanly)
```bash
    if [ $TERM_PROGRAM = 'iTerm.app' ]; then
        if [ `ps | grep -c 'minidock\.sh'` = 0 ]; then
            relative/path/to/minidock.sh &
        else
            : # usual init stuff
        fi
    fi
```


## To use `print_app_icons.sh`
- Icons need to be stored as `icons/$APPNAME.png`
- They cannot be uploaded here due to copyright issues, but can be extracted
  automatically from `/Applications` using `extract_icons.sh`
- If an `$APPNAME.png` is not present, the app will be displayed as the first
  two letters of `$APPNAME` in grey text
- To find the `$APPNAME` for an app, use `print_app` while the app is running;
  name tends to be (but not always) the same as shown on the macOS Menu Bar 


## Notes
- For consistent behavior in a multi-screen scenario,
  this script should be launched without external screens first
- `print_app_icons.sh` can be a bit CPU-taxing, so be cautious
  if you're mainly on battery
