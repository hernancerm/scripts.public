@namespace "stdd"

function get_metadata_value_string(metadata_item) {
  if (metadata_item == "") { return metadata_item }
  return awk::gensub(/\w+:/, "", "g", metadata_item)
}

function get_metadata_value_boolean(metadata_item) {
  return _toTrueFalse(metadata_item != "")
}

function get_metadata_value(metadata, target_item,
      _metadata_array, _target_item_extracted, _target_item_value) {
  split(metadata, _metadata_array, /[ ]/)
  for (i in _metadata_array) {
    if (_metadata_array[i] ~ "^"target_item) {
      _target_item_extracted = _metadata_array[i]
      break
    }
  }
  if (_target_item_extracted ~ ":") {
    _target_item_value = get_metadata_value_string(_target_item_extracted)
  } else {
    _target_item_value = get_metadata_value_boolean(_target_item_extracted)
  }
  if (target_item == "decorator" \
        && (length(_target_item_value) > 1 || _target_item_value == "")) {
    _target_item_value = " "
  }
  return _target_item_value
}

function pretty_print(raw_stdd, longest_path_length,
      _raw_stdd_array, _path_trimmed, _path_padded, _description_formatted) {
  split(raw_stdd, _raw_stdd_array, /,/)
  _decorator = get_metadata_value(_raw_stdd_array[3], "decorator")
  _path_trimmed = trim(_raw_stdd_array[1])
  _path_padded = _path_trimmed \
      _repeatSymbol(" ", longest_path_length - length(_path_trimmed)) \
      _repeatSymbol(" ", 4)
  _description_formatted = "--" trim(_raw_stdd_array[2])
  # Print standard directory.
  printf("%s%s%s\n", _decorator, _path_padded, _description_formatted)
  # Print expanded directories.
  if (get_metadata_value(_raw_stdd_array[3], "expand") == "true") {
    system("find " _path_trimmed " -maxdepth 1 -type d \
        | sed '1d' \
        | xargs realpath \
        | sed 's#" ENVIRON["HOME"] "#~#' \
        | xargs printf ' %s\n'")
  }
}

function trim(string) {
  return awk::gensub(/^\s+|\s+$/, "", "g", string);
}

function _repeatSymbol(symbol, times, _output) {
  _output = ""
  while (times > 0) {
    _output = _output symbol
    times--
  }
  return _output
}

function _toTrueFalse(boolean) {
  return boolean ? "true" : "false"
}

# vim: textwidth=80
