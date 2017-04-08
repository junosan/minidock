#!/bin/bash

SCRIPT_PATH=${0%/*}

make
clang++ -std=c++14 -Wall -framework AppKit -o $SCRIPT_PATH/bin/print_app $SCRIPT_PATH/readme/print_app.mm
