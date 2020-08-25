#!/usr/bin/env bash
set -euo pipefail
    for win in $(wmctrl -l | awk '{print $1}'); do
    wmctrl -i -c $win
    done
