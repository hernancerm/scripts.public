@namespace "stdd"

# WARNING: Currenlty this function only supports `item` equal to `"decorator"`.
#          It is assumed that a decorator will always be present and have a colon.
#
# @param metadata raw metadata from a single raw stdd.
# @param item metadata item name.
# @return `item`'s value.
function get_metadata_value(metadata, target_item) {
  # Step 1: Split `metadata` in an array.
  split(metadata, metadata_array, /[ ]/)
  # Step 2: Store in a variable the decorator item.
  for (i in metadata_array) {
    metadata_array_item = metadata_array[i]
    if (match(metadata_array_item, /^decorator/)) {
      decorator_item = metadata_array_item
    }
  }
  # Step 3: Retrieve the value of the decorator item.
  decorator_item_value = awk::gensub(/decorator:/, "", "g", decorator_item)
  # Step 4: Normalize the decorator item value and return.
  if (length(decorator_item_value) == 0) {
    decorator_item_value_normalized = " "
  } else {
    decorator_item_value_normalized = decorator_item_value
  }
  return decorator_item_value_normalized
}
