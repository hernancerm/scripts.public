#!/bin/bash

# Remove ANSI color codes from piped stdin.
#
# Credit of sed pattern goes to:
# https://stackoverflow.com/a/18000433/12591546
#
# @stdin Lines with ANSI color escape codes.
function strip_ansi_colors {
  local pattern='s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g'

  local os="$(spub-os-which)"
  if [[ "$os" == 'mac' ]]; then
    local sed_command='gsed'
  else
    local sed_command='sed'
  fi

  while IFS='$\n' read -r line; do
    echo "$line" | eval "$sed_command -r '$pattern'"
  done
}

