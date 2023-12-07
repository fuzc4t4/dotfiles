if type "jgmenu"; then
  pkill jgmenu
  sleep 1
  jgmenu --csv-cmd="jgmenu_run lx" --hide-on-startup
fi
