#!/bin/bash

# Manipulate «standard directories». These are directories which are
# standard to my setup, and I commonly visit them. They are defined
# in a CSV file.

STDD_PUBLIC_FILEPATH='$SPUB/resources/stdd.pub.csv'
STDD_PRIVATE_FILEPATH='$SPRI/resources/stdd.pri.csv'

# @param `$1` field name, options: 'path', 'description', 'metadata'.
function stdd_get_field_index {
  local index
  case "$1" in
    path)        index=1;;
    description) index=2;;
    metadata)    index=3;;
  esac
  echo $index
}

# @return public standard directories as-are, no transormations applied to file.
function stdd_get_pub_raw {
  cat "$(eval echo $STDD_PUBLIC_FILEPATH)"
}

# @return private standard directories as-are, no transormations applied to file.
function stdd_get_pri_raw {
  cat "$(eval echo $STDD_PRIVATE_FILEPATH)"
}

# @return all standard directories as-are, no transormations applied to the files.
#         (the public directories are listed first, then the private ones).
function stdd_get_all_raw {
  stdd_get_pub_raw
  stdd_get_pri_raw
}

# @stdin valid raw line(s) of standard directory(ies).
# @param `$1` name of field to retrieve: `path`, `description` or `metadata`.
# @return the trimmed value of the field.
function stdd_get_field_from_raw {
  local stdin="$(cat -)"
  local field_value="$(echo "$stdin" \
      | gawk -F',' -i 'commons.gawk' -v field="$(stdd_get_field_index $1)" \
          '{ print c::trim($field); }')"
  echo "$field_value"
}

# Pretty print the provided lines of standard directories. This adds any styling
# useful for a pleasing, human-readable presentation.
#
# @stdin valid raw line(s) of standard directory(ies).
# @return pretty-printed standard directories.
function stdd_pretty_print {
  local stdin="$(cat -)"
  filtered_field_values="$(echo $stdin | gawk -F',' '{ print $1", --"$2 }')"
  echo "$filtered_field_values" | column -ts ','
}

# @stdin prettified line(s) of standard directory(ies).
# @param `$1` name of field to retrieve: `path` or `description`.
# @return the trimmed value of the field.
function stdd_get_field_from_pretty {
  local stdin="$(cat -)"
  local field_value="$(echo "$stdin" \
      | gawk -F'--' -i 'commons.gawk' -v field="$(stdd_get_field_index $1)" \
          '{ print c::trim($field); }')"
  echo "$field_value"
}

# Crate, if not already existent, the directories that are marked with the
# metadata value of `auto_create`.
#
# @stdin valid raw line(s) of raw standard directory(ies).
function stdd_create_directories {
  local stdin="$(cat -)"

  local stdd
  while IFS='' read -r stdd; do
    local stdd_path="$(echo "$stdd" | stdd_get_field_from_raw 'path')"
    local stdd_metadata="$(echo "$stdd" | stdd_get_field_from_raw 'metadata')"

    if [[ "$stdd_metadata" =~ auto_create ]]; then
      local stdd_path_expanded="$(eval echo $stdd_path)"
      mkdir -vp "$stdd_path_expanded"
    fi

  done <<< "$stdin"
}

