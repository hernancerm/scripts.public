@include "commons.gawk"

# Remove the items in `commit` that are listed in `items_to_remove`.
#
# @param `items_to_remove` space-separated string of item names.
# @param `commit` the commit string.
# @return the modified commit string.
function remove_items(items_to_remove, commit) {
  split(items_to_remove, items, /[ ]/)
  for (itemIndex in items) {
    commit = gensub("~"items[itemIndex]"(.*)"items[itemIndex]"~", "", "g", commit)
  }
  return commit
}

# Format an item conditionally into a normal or special style, e.g.:
# ~A_NAMEHernán C.A_NAME~ -> (italic) (cyan) Hernán C. (reset)
#
# @param `item_name` the name of the item to substitute with proper formatting.
# @param `item_formatted` the proper formmating of the item. If empty, use the the actual contents.
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

  # Determie if commit is from today.
  match(commit, /~A_DATE_YEAR_4D(.*)A_DATE_YEAR_4D~/, ad_year_4d_matches)
  match(commit, /~A_DATE_MONTH_2D(.*)A_DATE_MONTH_2D~/, ad_month_2d_matches)
  match(commit, /~A_DATE_MONTH_3L(.*)A_DATE_MONTH_3L~/, ad_month_3l_matches)
  match(commit, /~A_DATE_DAY_2D(.*)A_DATE_DAY_2D~/, ad_day_2d_matches)
  commit = remove_items("A_DATE_YEAR A_DATE_MONTH_2D A_DATE_MONTH_3L A_DATE_DAY_2D", commit)
  iso_8601_commit_date = ad_year_4d_matches[1] "-" ad_month_2d_matches[1] "-" ad_day_2d_matches[1]
  is_commit_from_today = iso_8601_commit_date == c::get_today_date()

  # Set special style for date if it is a commit from today.
  ad_formatted = ad_day_2d_matches[1] "/" ad_month_3l_matches[1] "/" substr(ad_year_4d_matches[1], 3)
  commit = format_item("A_DATE_PARTS", ad_formatted, is_commit_from_today, c["italic"] c["green"], c["bold"] c["green"], commit)

  # Determie if the author is different from the committer (either name or email).
  match(commit, /~A_NAME(.*)A_NAME~/, an_matches)
  match(commit, /~C_NAME(.*)C_NAME~/, cn_matches)
  match(commit, /~A_EMAIL(.*)A_EMAIL~/, ae_matches)
  match(commit, /~C_EMAIL(.*)C_EMAIL~/, ce_matches)
  commit = remove_items("C_NAME A_EMAIL C_EMAIL", commit)
  is_author_diff_from_committer = an_matches[1] != cn_matches[1] || ae_matches[1] != ce_matches[1]

  # Set special style for the author name when it is different from the committer name.
  # The author is different from the commiter name when a regular (non-merge) commit is rewritten
  # by a history-rewriting command, such as `git commit --amend`, or when the person applying the
  # patch is different from the author, e.g. when sending a patch by email.
  commit = format_item("A_NAME", "", is_author_diff_from_committer, c["italic"] c["cyan"], c["bold"] c["cyan"], commit)

  print commit
}

