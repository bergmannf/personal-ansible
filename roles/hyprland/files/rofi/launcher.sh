#!/usr/bin/env bash

dir="$HOME/.config/rofi/"
theme='launcher-style'

## Run
rofi \
    -show combi -modes combi -combi-modes "window,drun,run" \
    -theme ${dir}/${theme}.rasi
