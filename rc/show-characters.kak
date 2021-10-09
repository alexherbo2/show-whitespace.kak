# Show characters and whitespaces
# Public commands: ["show-characters", "hide-characters", "add-character", "add-cursor-character-unicode-expansion"]
# Public expansions: ["cursor_character_unicode"]

# Faces ────────────────────────────────────────────────────────────────────────

set-face global EmphasisCharacter 'green+if'
set-face global StrongCharacter 'green+bf'
set-face global MathSymbol 'cyan+f'

set-face global WhitespaceIgnore '+F'
set-face global WhitespaceOk 'green+uF'
set-face global WhitespaceError 'red+uF'

set-face global Indent WhitespaceIgnore
set-face global Tab WhitespaceOk
set-face global Newline WhitespaceOk
set-face global NonBreakingSpace WhitespaceError
set-face global EmptyLine WhitespaceError
set-face global TrailingWhitespace WhitespaceError

# Expansions ───────────────────────────────────────────────────────────────────

# Show Unicode value in the status line.
declare-option str cursor_character_unicode

define-command -override add-cursor-character-unicode-expansion -docstring 'add %opt{cursor_character_unicode} expansion' %{
  remove-hooks global update-cursor-character-unicode-expansion
  hook -group update-cursor-character-unicode-expansion global NormalIdle '' %{
    set-option window cursor_character_unicode %sh{printf '%04x' "$kak_cursor_char_value"}
  }
}

# Highlighters ─────────────────────────────────────────────────────────────────

# Order matters:
#
# “You can think of highlighters as like a list of painting instructions.” — Screwtape
#
add-highlighter -override shared/show-characters group

# Convenient command to add new characters.
define-command -override add-character -params 3 -docstring 'add-character <name> <pattern> <face>' %{
  add-highlighter -override "shared/show-characters/%arg{1}" regex %arg{2} "0:%arg{3}"
}

# Show consecutive whitespaces, then paint over indent.
add-character multiple-whitespaces '\h{2,}' WhitespaceError
add-character indent '^\h+' Indent

# Show empty lines and trailing whitespaces.
add-character empty-lines '^\h+$' EmptyLine
add-character trailing-whitespaces '\h+$' TrailingWhitespace

# Show odd and deep indent.
add-character odd-indent '^(\h{1}|\h{3}|\h{5}|\h{7}|\h{9})(?=\H)' WhitespaceError
add-character deep-indent '^\h{9,}' WhitespaceError

# Show limit of 80 characters.
add-character limit '(?S)^.{80}$\K\n' Newline

# Show other whitespaces (tabs, non-breaking-spaces).
add-character tabs '\t+' Tab
add-character non-breaking-spaces ' +' NonBreakingSpace

# Show various characters (Unicode characters, math symbols).
add-character unicode-2013 '–+' EmphasisCharacter
add-character unicode-2014 '—+' StrongCharacter
add-character math-symbols '[−×]+' MathSymbol

# Commands ─────────────────────────────────────────────────────────────────────

define-command -override show-characters -docstring 'show characters' %{
  add-highlighter -override global/show-characters ref show-characters

  # Only shown when not in insert mode.
  remove-hooks global show-characters
  hook -group show-characters global ModeChange 'push:normal:insert' %{
    set-face window EmptyLine WhitespaceIgnore
    set-face window TrailingWhitespace WhitespaceIgnore

    # Restore
    hook -always -once window ModeChange 'pop:insert:normal' %{
      unset-face window EmptyLine
      unset-face window TrailingWhitespace
    }
  }
}

define-command -override hide-characters -docstring 'hide characters' %{
  remove-hooks global show-characters
  remove-highlighter global/show-characters
}
