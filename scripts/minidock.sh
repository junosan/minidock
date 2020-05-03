#!/bin/bash

# to support running through a symlink (macOS doesn't have realpath)
SCRIPT_PATH=$(python -c "import os; print(os.path.dirname(os.path.realpath('$0')))")

python $SCRIPT_PATH/music_status.py &
$SCRIPT_PATH/../bin/minidock
