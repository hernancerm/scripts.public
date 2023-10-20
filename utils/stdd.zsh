#!/bin/zsh

# Manipulate "standard directories". These are directories which are standard to my setup,
# and I commonly visit them. They are defined in a CSV file.

# CSV configuration file format:
# {path}, {description}, {metadata}
#
# {metadata}:
#     The items are separated by a space. Each item can have a value after a colon. If an
#     item does not have a colon then the assumed value is to be `true`. If the item is
#     not present then the assumed value is `false`. Metadata items:
#     - decorator (string): Prefix of the {path} in the pretty print output. Must be a
#                           single char. Default value: A single whitespace character.
#     - expand (boolean): Whether to list all level-1 subdirectories in the pretty print.

STDD_CONFIG_HOME=${XDG_CONFIG_HOME:-'~/.config/stdd'}

# @param $1 field name, options: 'path', 'description', 'metadata'.
function stdd_get_field_index {
  local index
  case "$1" in
    path)        index=1;;
    description) index=2;;
    metadata)    index=3;;
  esac
  echo $index
}

# @return string standard directories as-are, no transormations applied to contents.
#         It is required to have this file.
function stdd_get_raw_directories {
  local stdd_filepath=$(eval echo "$STDD_CONFIG_HOME/directories.csv")
  if ! [[ -f "$stdd_filepath" ]]; then
    echo "Missing configuration file: "$stdd_filepath"" 1>&2
    return 1
  fi
  cat "$stdd_filepath"
}

# @return string local standard directories as-are, no transormations applied to contents.
#         It is not required to have this file.
function stdd_get_raw_directories_local {
  local stdd_filepath_local=$(eval echo "$STDD_CONFIG_HOME/directories_local.csv")
  if [[ -f "$stdd_filepath_local" ]]; then
    cat "$stdd_filepath_local"
  fi
}

# @return string all standard directories as-are, no transormations applied to the files.
#         (the public directories are listed first, then the private ones).
function stdd_get_raw_directories_all {
  stdd_get_raw_directories
  stdd_get_raw_directories_local
}

# @stdin raw lines of stdds.
# @param $1 name of field to retrieve: `path`, `description` or `metadata`.
# @return string the trimmed value of the field.
function stdd_get_field_from_raw {
  gawk -F',' -i stdd.gawk -v field_index="$(stdd_get_field_index $1)" '{
    print stdd::trim($field_index) }'
}

# Pretty print the provided lines of raw stdds.
#
# @stdin raw lines of stdds.
# @return string pretty-printed standard directories.
function stdd_pretty_print {
  local stdin="$(cat -)"
  local longest_path_length="$(echo "$stdin" \
      | stdd_get_field_from_raw 'path' \
      | gawk '{ print(length($0)) }' \
      | sort -rn \
      | head -1)"
  echo "$stdin" | gawk -i stdd.gawk -v longest_path_length="${longest_path_length}" '{
      stdd::pretty_print($0, longest_path_length) }'
}

# @stdin prettified lines of stdds.
# @param $1 name of field to retrieve: `path` or `description`.
# @return string the trimmed value of the field.
function stdd_get_field_from_pretty {
  gawk -i stdd.gawk -v field_index="$(stdd_get_field_index $1)" '{
    split($0, fields_array, /\-\-/)
    print(stdd::trim(substr(fields_array[field_index], 2)))
  }'
}

# vim: textwidth=90
