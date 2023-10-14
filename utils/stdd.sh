#!/bin/bash

# Manipulate "standard directories". These are directories which are
# standard to my setup, and I commonly visit them. They are defined
# in a CSV file.

# CSV configuration file format:
# {path}, {description}, {metadata}
#
# {metadata}:
#     The items are separated by a space. Each item can have a value after a colon. If an item does
#     not have a colon then the assumed value is to be `true`. If the item is not present then the
#     assumed value is `false`. Metadata items:
#     - decorator (string): Prefix of the {path} in the pretty print output. Must be a single char.
#                           Default value: A single whitespace character.
#     - create (boolean): Whether to create the directories on `stdd_create_directories`.
#     - expand (boolean): Whether to list all level-1 subdirectories in the pretty print.

STDD_PUBLIC_FILEPATH='$SPUB/resources/stdd.pub.csv'
STDD_PRIVATE_FILEPATH='$SPRI/resources/stdd.pri.csv'

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
# @param $1 name of field to retrieve: `path`, `description` or `metadata`.
# @return the trimmed value of the field.
function stdd_get_field_from_raw {
  local stdin="$(cat -)"
  local field_value="$(echo "$stdin" \
      | gawk -F',' -i 'commons.gawk' -v field="$(stdd_get_field_index $1)" \
          '{ print c::trim($field); }')"
  echo "$field_value"
}

# TODO: Fix expansion happens for all dirs, not just `expand` marked.
# TODO: Abbreviate `/Users/hernancervera` with `~`.
# TODO: Do not shift order when pressing `*`.
# Pretty print the provided lines of raw standard directories.
#
# @stdin valid raw line(s) of standard directory(ies).
# @return pretty-printed standard directories.
function stdd_pretty_print {
  local stdin="$(cat -)"
  stdds_columnar_with_metadata="$(echo "$stdin" | gawk -F',' -i 'stdd.gawk' -v metadata="3" '{ \
        print stdd::get_metadata_value($metadata, "decorator")$1", --"$2" metadata: "$3 }' \
      | column -ts ',')"
  echo "$(echo "$stdds_columnar_with_metadata" | gawk -i 'commons.gawk' -i 'stdd.gawk' '{ \
        # Print the pretty stdd.
        print(gensub(/[ ]*metadata:.*$/, "", "g", $0))
        # Store raw metadata in a variable.
        metadata = gensub(/^.*metadata:[ ]*/, "", "g", $0)
        # Extract `expand` metadata item.
        expand = stdd::get_metadata_value(metadata, "expand")
        # Extract `path` field.
        path = substr(c::trim(gensub(/ -- .*/, "", "g", $0)), 2)
        # Conditionally expand the stdd.
        if (expand == "true" ) {
          system("ls -d1 "path"/* | xargs realpath | xargs printf \" %s\\n\"")
        }
      }')"
}

# @stdin prettified line(s) of standard directory(ies).
# @param $1 name of field to retrieve: `path` or `description`.
# @return the trimmed value of the field.
function stdd_get_field_from_pretty {
  local stdin="$(cat -)"
  local pretty_without_decorator="$(echo "$stdin" | gawk '{ print substr($0, 2) }')"
  local field_value="$(echo "$pretty_without_decorator" \
      | gawk -F'--' -i 'commons.gawk' -v field="$(stdd_get_field_index $1)" \
          '{ print c::trim($field); }')"
  echo "$field_value"
}

# Create, if not already existent, the directories that are marked with the
# metadata value of `create`.
#
# @stdin valid raw line(s) of raw standard directory(ies).
function stdd_create_directories {
  local stdin="$(cat -)"

  local stdd
  while IFS='' read -r stdd; do
    local stdd_path="$(echo "$stdd" | stdd_get_field_from_raw 'path')"
    local stdd_metadata="$(echo "$stdd" | stdd_get_field_from_raw 'metadata')"

    if [[ "$stdd_metadata" =~ create ]]; then
      echo "Beginning creation of directory: ${stdd_path}"
      local stdd_path_expanded="$(eval echo $stdd_path)"
      mkdir -vp "$stdd_path_expanded"
    fi

  done <<< "$stdin"
}
