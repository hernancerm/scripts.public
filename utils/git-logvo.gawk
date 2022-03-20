@include "commons.gawk"

# Get regex that matches in it's first capturing group the item value.
#
# @param `item_name` the name of the item.
function get_item_value_regex(item_name) {
  return "~"item_name"(.*)"item_name"~"
}

# Get the value of an item. It is always assumed that the item exists.
#
# @param `item_name` the name of the item.
# @param `commit` the commit string.
function get_item_value(item_name, commit) {
  match(commit, get_item_value_regex(item_name), matches)
  return matches[1]
}

# Remove the items in `commit` that are listed in `items_to_remove`.
#
# @param `items_to_remove` space-separated string of item names.
# @param `commit` the commit string.
# @return the modified commit string.
function remove_items(items_to_remove, commit) {
  split(items_to_remove, items, /[ ]/)
  for (itemIndex in items) {
    commit = gensub(get_item_value_regex(items[itemIndex]), "", "g", commit)
  }
  return commit
}

# Format an item into a normal or special style, can use ANSI escape codes. e.g.:
# ~A_NAMEHernán C.A_NAME~ -> (italic) (cyan) Hernán C. (reset)
#
# @param `item_name` the name of the item to substitute with proper formatting.
# @param `item_formatted` the item formatted. If empty, use the the actual value.
# @param `predicate` when true the `special_style` is used, else the `normal_style`.
# @param `normal_style` normal style, can use ANSI escape codes.
# @param `special_style` special style, can use ANSI escape codes.
# @param `commit` the commit string.
# @return the modified commit string.
function format_item(item_name, item_formatted, predicate, normal_style, special_style, commit) {
  if (length(item_formatted) == 0) {
    item_formatted = "\\2"
  }

  if (predicate) {
    commit = gensub("^(.*)~"item_name"(.*)"item_name"~(.*)$",
        "\\1"special_style item_formatted c["reset"]"\\3", "g", commit)
  } else {
    commit = gensub("^(.*)~"item_name"(.*)"item_name"~(.*)$",
        "\\1"normal_style item_formatted c["reset"]"\\3", "g", commit)
  }
  return commit
}


# Format an item into a style, can use ANSI escape codes. e.g.:
# ~A_NAMEHernán C.A_NAME~ -> (cyan) Hernán C. (reset)
#
# @param `item_name` the name of the item to substitute with proper formatting.
# @param `item_formatted` the item formatted. If empty, use the the actual value.
# @param `style` style, can use ANSI escape codes.
# @param `commit` the commit string.
# @return the modified commit string.
function format_item_simple(item_name, item_formatted, style, commit) {
  if (length(item_formatted) == 0) {
    item_formatted = "\\2"
  }

  commit = gensub("^(.*)~"item_name"(.*)"item_name"~(.*)$",
      "\\1"style item_formatted c["reset"]"\\3", "g", commit)
  return commit
}

BEGIN {
  c::set_colors(c)
}

{
  commit = $0 # The current commit string.

  # Determine if the commit is a merge commit.
  is_merge_commit = match(commit, /~PARENTS[a-z0-9]+ [a-z0-9 ]+PARENTS~/)
  commit = remove_items("PARENTS", commit)

  # Set special style for the hash when it identifies a merge commit (i.e. has more than one parent).
  commit = format_item("HASH", "", is_merge_commit, c["italic"] c["yellow"], c["bold"] c["yellow"], commit)

  # Determie if the author is different from the committer (either name or email).
  an = get_item_value("A_NAME", commit)
  ae = get_item_value("A_EMAIL", commit)
  cn = get_item_value("C_NAME", commit)
  ce = get_item_value("C_EMAIL", commit)
  commit = remove_items("C_NAME A_EMAIL C_EMAIL", commit)
  is_author_diff_from_committer = an != cn || ae != ce

  # Set special style for the author name when it is different from the committer name.
  # The author is different from the commiter name when a regular (non-merge) commit is rewritten
  # by a history-rewriting command, such as `git commit --amend`, or when the person applying the
  # patch is different from the author, e.g. when sending a patch by email.
  commit = format_item("A_NAME", "", is_author_diff_from_committer, c["italic"] c["cyan"], c["bold"] c["cyan"], commit)

  print commit
}

