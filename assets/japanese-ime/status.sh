#!/bin/bash
state=$(fcitx5-remote 2>/dev/null || echo "1")
im=$(fcitx5-remote -n 2>/dev/null || echo "keyboard-us")
printf "state\t%s\nim\t%s\n" "$state" "$im"
