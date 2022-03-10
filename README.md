# Hernán's scripts 🧰

## Standards

### Filenames

```text
spub-{category}-{description}
```

e.g. `spub-os-find-word`

### Documentation

Every script must have the following documentation sections at the top:

```text
# Description:
# -----------
# (Explain the purpose of the script, e.g.:
#  Given a single file, find all it's lines which contain a given word.
# ).
#
# Parameters:
# ----------
# (Explain the script's intended usage of each parameter, e.g.:
#  $1: Filename.
#  $2: Word to find in the provided file.
# ).
#
# Examples:
# --------
# (Provide at least one example, e.g.:
#  Find the word `hello` in the file `foo.txt`:
#  ```
#  $ spub-os-find-word hello './foo.txt'
#  Line 23: And he said: "hello, stranger".
#  ```
# ).
```

