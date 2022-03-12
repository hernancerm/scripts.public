@namespace "c"

# Credit of the `set_colors` function goes to DJ Mills (e36freak):
# <https://github.com/e36freak/awk-libs/blob/master/colors.awk>

# Set colors and decorations (e.g. bold, italic), in the provided array.
#
# @param `array` the array in which to store colors and decorations.
function set_colors(array) {
  # Bold.
  cmd = "tput bold";
  cmd | getline array["bold"];
  close(cmd);
  # Black.
  cmd = "tput setaf 0";
  cmd | getline array["black"];
  close(cmd);
  # Red.
  cmd = "tput setaf 1";
  cmd | getline array["red"];
  close(cmd);
  # Green.
  cmd = "tput setaf 2";
  cmd | getline array["green"];
  close(cmd);
  # Yellow.
  cmd = "tput setaf 3";
  cmd | getline array["yellow"];
  close(cmd);
  # Blue.
  cmd = "tput setaf 4";
  cmd | getline array["blue"];
  close(cmd);
  # Magenta
  cmd = "tput setaf 5";
  cmd | getline array["magenta"];
  close(cmd);
  # Cyan.
  cmd = "tput setaf 6";
  cmd | getline array["cyan"];
  close(cmd);
  # White.
  cmd = "tput setaf 7";
  cmd | getline array["white"];
  close(cmd);
  # Reset.
  cmd = "tput sgr0";
  cmd | getline array["reset"];
  close(cmd);

  # (Note on ansi escape codes
  # --------------------------
  # The ANSI escape code for italic text is: `ESC[3m`, where `ESC` is the ASCII
  # escape character. Every ANSI escape code begins with this `ESC`. In hex, this
  # character is 1B, and the escape sequence `\x` in gawk, interprets hex
  # digits as a character.
  # <https://en.wikipedia.org/wiki/ANSI_escape_code>
  # <https://en.wikipedia.org/wiki/Escape_character#ASCII_escape_character>).

  # Italic.
 array["italic"] = "\x1B[3m";
}

# @return today's date in ISO 8601 format (e.g. 2022-03-21).
function get_today_date() {
  return awk::strftime("%F", awk::systime());
}

