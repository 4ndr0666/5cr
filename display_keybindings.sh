#!/bin/bash

keybindings="Keybindings
Keys\tAction
super + Return\tOpen terminal
super + shift + Return\tOpen floating terminal
super + alt + Return\tOpen terminal with selected geometry
super + T\tOpen full-screen terminal with big fonts
super + shift + F\tOpen file manager
super + shift + E\tOpen text editor
super + shift + W\tOpen web browser
super, super + D\tRun app launcher
super + X\tRun powermenu
super + N\tOpen network manager
super + P\tRun colorpicker
super + C/Q\tKill active window
ctrl + alt + L\tRun lockscreen
ctrl + alt + Delete\tExit Hyprland instantly
super + F\tToggle fullscreen mode
super + Space\tToggle floating mode
super + S\tToggle pseudo mode
super + Left / Right / Up / Down\tChange focus of the container
super + shift + Left / Right / Up / Down\tMove active container directionally
super + ctrl + Left / Right / Up / Down\tResize active container
super + alt + Left / Right / Up / Down\tMove floating container directionally
super + Tab\tCycle between container
super + 1,2..8\tChange workspace/tag from 1 to 8
super + shift + 1,2..8\tMove active container to respective workspace/tag
super + ctrl + F\tToggle All floating mode
super + ctrl + S\tToggle All pseudo mode
super + shift + P\tPin floating container
super + shift + S\tSwap next container
super + G\tToggle Group Mode
super + H\tChange active group container to left
super + L\tChange active group container to right"

yad --title "Keybindings" --text "$keybindings" --no-buttons --geometry=500x600 --sticky --skip-taskbar --on-top --borders=10 --fontname="monospace" --text-align=center --fixed --opacity=204 --escape-ok --wrap

