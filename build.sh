#!/bin/bash

SCRIPT_PATH=${0%/*}

clang++ -framework CoreAudio -std=c++11 -o $SCRIPT_PATH/audio_device $SCRIPT_PATH/audio_device.cc
clang -framework AppKit -o $SCRIPT_PATH/print_app $SCRIPT_PATH/print_app.m
clang -framework AppKit -o $SCRIPT_PATH/screen_size $SCRIPT_PATH/screen_size.m
