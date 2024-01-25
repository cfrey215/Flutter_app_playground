#!/bin/sh -l

export DISPLAY=:99
Xvfb :99 -screen 0 1000x1000x16 &
    xrandr –query
    sleep 5
    nohup startxfce4 &
    apt install xdotool -y

xdotool mousemove 493 539 click 1

xdotool key KP_Enter

xrandr –query