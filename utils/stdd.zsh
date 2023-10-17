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

# @stdin raw line of stdds.
# @param $1 name of field to retrieve: `path`, `description` or `metadata`.
# @return the trimmed value of the field.
function stdd_get_field_from_raw {
  gawk -F',' -i 'commons.gawk' -v field="$(stdd_get_field_index $1)" '{
    print c::trim($field) }'
}

# Pretty print the provided lines of raw standard directories.
#
# @stdin valid raw line(s) of standard directory(ies).
# @return pretty-printed standard directories.
function stdd_pretty_print {
  local stdin="$(cat -)"
  stdds_pretty_with_metadata="$(echo "$stdin" | \
          gawk -F',' -i 'stdd.gawk' -v metadata="3" '{ \
              print stdd::get_metadata_value($metadata, "decorator") \
                  $1", --"$2" metadata: "$3 }' | column -ts ',')"
  # TODO: Move long inline-gawk script to stdd.gawk.
  echo "$(echo "$stdds_pretty_with_metadata" | gawk -i 'commons.gawk' -i 'stdd.gawk' '{
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
          system("find "path" -maxdepth 1 -type d | sed \"1d\" | xargs realpath \
              | sed \"s#$HOME#~#\" | xargs printf \" %s\\n\"")
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

# Create the directories marked with the metadata item `create`.
#
# @stdin lines of raw stdds.
function stdd_create_directories {
  gawk -i stdd.gawk -F, -v path=1 -v metadata=3 '{
    stdd::create_directories($path, $metadata)
  }'
}

# vim: textwidth=90
