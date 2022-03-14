#!/bin/bash

# Manipulate «standard directories». These are directories which are
# standard to my setup, and I commonly visit them. They are defined
# in a CSV file. To learn what each column means, see the variable
# `STDD__FIELD_OPTIONS`.

declare -A STDD__FIELD_OPTIONS
STDD__FIELD_OPTIONS=([path]=1 [description]=2 [metadata]=3)

STDD__PUBLIC_FILEPATH='$SPUB/resources/stdd.pub.csv'
STDD__PRIVATE_FILEPATH='$SPRI/resources/stdd.pri.csv'

# @return public standard directories as-are, no transormations applied to file.
function stdd__get_pub_raw {
  cat "$(eval echo $STDD__PUBLIC_FILEPATH)"
}

# @return private standard directories as-are, no transormations applied to file.
function stdd__get_pri_raw {
  cat "$(eval echo $STDD__PRIVATE_FILEPATH)"
}

# @return all standard directories as-are, no transormations applied to the files.
#         (the public directories are listed first, then the private ones).
function stdd__get_all_raw {
  stdd__get_pub_raw
  stdd__get_pri_raw
}

# @stdin valid raw line(s) of standard directory(ies).
# @param `$1` name of field to retrieve: `path`, `description` or `metadata`.
# @return the trimmed value of the field.
function stdd__get_field_from_raw {
  local stdin="$(cat -)"
  local field_value="$(echo "$stdin" \
      | gawk -F',' -i 'commons.gawk' -v field="${STDD__FIELD_OPTIONS[$1]}" \
          '{ print c::trim($field); }')"
  echo "$field_value"
}

# Pretty print the provided lines of standard directories. This adds any styling
# useful for a pleasing, human-readable presentation.
#
# @stdin valid raw line(s) of standard directory(ies).
# @return pretty-printed standard directories.
function stdd__pretty_print {
  local stdin="$(cat -)"
  filtered_field_values="$(echo $stdin | gawk -F',' '{ print $1", --"$2 }')"
  echo "$filtered_field_values" | column -ts ','
}

# @stdin prettified line(s) of standard directory(ies).
# @param `$1` name of field to retrieve: `path` or `description`.
# @return the trimmed value of the field.
function stdd__get_field_from_pretty {
  local stdin="$(cat -)"
  local field_value="$(echo "$stdin" \
      | gawk -F'--' -i 'commons.gawk' -v field="${STDD__FIELD_OPTIONS[$1]}" \
          '{ print c::trim($field); }')"
  echo "$field_value"
}

# Crate, if not already existent, the directories that are marked with the
# metadata value of `auto_create`.
#
# @stdin valid raw line(s) of raw standard directory(ies).
function stdd__create_directories {
  local stdin="$(cat -)"

  local stdd
  while IFS='' read -r stdd; do
    local stdd_path="$(echo "$stdd" | stdd__get_field_from_raw 'path')"
    local stdd_metadata="$(echo "$stdd" | stdd__get_field_from_raw 'metadata')"

    if [[ "$stdd_metadata" =~ auto_create ]]; then
      local stdd_path_expanded="$(eval echo $stdd_path)"
      mkdir -vp "$stdd_path_expanded"
    fi

  done <<< "$stdin"
}

