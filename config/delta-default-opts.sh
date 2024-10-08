# Navigation stop points.
DELTA_FILE_ADDED_LABEL='added:'
DELTA_FILE_COPIED_LABEL='copied:'
DELTA_FILE_MODIFIED_LABEL='Δ'
DELTA_FILE_REMOVED_LABEL='removed:'
DELTA_FILE_RENAMED_LABEL='renamed:'
DELTA_HUNK_LABEL='•'

DELTA_DEFAULT_OPTS=(\
--syntax-theme='none' \
--line-numbers \
--line-numbers-left-style 'gray' \
--line-numbers-right-style 'gray' \
--line-numbers-zero-style '' \
--line-numbers-plus-style '' \
--line-numbers-minus-style '' \
--file-style='bold blue' \
--file-decoration-style='blue ul ol' \
--hunk-header-style='syntax line-number' \
--hunk-header-decoration-style='gray box' \
--max-line-length=6500 \
--navigate \
--file-added-label="$DELTA_FILE_ADDED_LABEL" \
--file-copied-label="$DELTA_FILE_COPIED_LABEL" \
--file-modified-label="$DELTA_FILE_MODIFIED_LABEL" \
--file-removed-label="$DELTA_FILE_REMOVED_LABEL" \
--file-renamed-label="$DELTA_FILE_RENAMED_LABEL" \
--hunk-label="$DELTA_HUNK_LABEL")

