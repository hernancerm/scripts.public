# scripts.public

General-purpose scripts.

## Development standards

### Filenames

```text
spub-{category}-{description}
```

e.g. `spub-os-find-word`

### Documentation

Scripts must have these comments at the top of the file, only preceded by a shebang, if any.

```text
# Description:
# -----------
# (Explain the purpose of the script, e.g.:
#  Given a single file, find all it's lines which contain a given word.)
#
# Parameters:
# ----------
# (Explain the script's intended usage of each parameter, e.g.:
#  $1: Filename.
#  $2: Word to find in the provided file.)
```

Scripts may have these comments directly after the mandatory documentation comments.

```text
# Examples:
# --------
# (Provide one or more examlpes, e.g.:
#  Find the word `hello` in the file `foo.txt`:
#  ```
#  $ spub-os-find-word hello './foo.txt'
#  Line 23: And he said: "hello, stranger".
#  ```).
#
# Internal notes:
# --------------
# (Provide information about implementation details, e.g.:
#  All pattern searches are done using grep, for convenience.
```

