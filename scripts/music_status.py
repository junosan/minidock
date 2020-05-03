import time
import subprocess
import functools as ft

script = """tell application "Music"
    if running and player state = playing then
        set _properties to (properties of current track)
        set _bitrate to bit rate of _properties as string
        set _rating to (round of ((rating of _properties) / 20)) as string
        set _output to _bitrate & "," & _rating
    end if
end tell"""

lines = (['-e', line] for line in script.split('\n'))
command = ['osascript'] + ft.reduce(list.__add__, lines)

while True:
    proc = subprocess.run(command, capture_output=True)
    output = proc.stdout.decode().strip()
    
    if ',' in output:
        bitrate, rating = output.split(',')
        output = f"{'R' if int(bitrate) > 320 else 'L'}{rating}"
    
    with open('/tmp/music_status', 'w') as f:
        f.write(output)
    
    time.sleep(1)
