@namespace "stdd"

# TODO: Refactor the logic of "extracting a boolean" and "extracting a string".
# WARNING: Currenlty this function only supports `item` equal to `"decorator"` and `"expand"`.
#          It is assumed that a decorator will always be present and have a colon.
#
# @param metadata raw metadata from a single raw stdd.
# @param item metadata item name.
# @return `item`'s value.
function get_metadata_value(metadata, target_item) {
  # Step 1: Split `metadata` in an array.
  split(metadata, metadata_array, /[ ]/)
  for (i in metadata_array) {
    metadata_array_item = metadata_array[i]
    if (match(metadata_array_item, /^decorator/)) {
      # Step 2.1: Store in a variable the `decorator` item.
      decorator_item = metadata_array_item
    }
    if (match(metadata_array_item, /^expand/)) {
      # Step 2.2: Store in a variable the `expand` item.
      expand_item = metadata_array_item
    }
  }
  # Step 3: Retrieve the value of the `decorator` item.
  decorator_item_value = awk::gensub(/decorator:/, "", "g", decorator_item)
  # Step 4.1: Normalize the `decorator` item value.
  if (length(decorator_item_value) == 0) {
    decorator_item_value_normalized = " "
  } else {
    decorator_item_value_normalized = decorator_item_value
  }
  # Step 4.2: Normalize the `expand` item value.
  if (length(expand_item) == 0) {
    expand_item_value_normalized = "false"
  } else {
    expand_item_value_normalized = "true"
  }
  # Step 5: Return the requested metadata item.
  if (target_item == "decorator") {
    return decorator_item_value_normalized
  }
  if (target_item == "expand") {
    return expand_item_value_normalized
  }
}
