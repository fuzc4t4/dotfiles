#!/usr/bin/env bash

killall -q polybar

if type "xrandr"; then
  PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
  MONITOR=$PRIMARY polybar useful --reload &
  sleep 1
  for m in $(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1); do
    MONITOR=$m polybar --reload useful &
  done
else
  polybar --reload useful &
fi
