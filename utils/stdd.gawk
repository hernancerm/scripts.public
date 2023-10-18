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

function trim(string) {
  return awk::gensub(/^\s+|\s+$/, "", "g", string);
}

function _toTrueFalse(boolean) {
  return boolean ? "true" : "false"
}
