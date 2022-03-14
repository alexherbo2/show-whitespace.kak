# Refined show whitespaces
# Public commands: ["show-whitespaces", "hide-whitespaces"]

# Faces ────────────────────────────────────────────────────────────────────────

# Whitespace characters:
set-face global Tab WhitespaceError
set-face global Newline Whitespace
set-face global NonBreakingSpace WhitespaceError

# Indentation rules:
set-face global Indent Whitespace
set-face global MixedIndent WhitespaceError
set-face global OddIndent WhitespaceError

# Extra whitespace:
set-face global TrailingWhitespace WhitespaceError
set-face global ConsecutiveWhitespace WhitespaceWarning

# Generic faces:
set-face global WhitespaceRuler 'green+f'
set-face global WhitespaceError 'red+f'
set-face global WhitespaceWarning 'red+f'

# Highlighters ─────────────────────────────────────────────────────────────────

# Order matters:
#
# “You can think of highlighters as like a list of painting instructions.” — Screwtape
#
add-highlighter -override shared/whitespaces group

# Show whitespaces (tabs, newlines, non-breaking-spaces).
add-highlighter -override shared/whitespaces/tabs regex '\t+' '0:Tab'
add-highlighter -override shared/whitespaces/newlines regex '\n+' '0:Newline'
add-highlighter -override shared/whitespaces/non-breaking-spaces regex ' +' '0:NonBreakingSpace'

# Show consecutive whitespaces, then paint over indent.
add-highlighter -override shared/whitespaces/consecutive-whitespaces regex '\h{2,}' '0:ConsecutiveWhitespace'
add-highlighter -override shared/whitespaces/indent regex '^\h+' '0:Indent'

# Show trailing whitespaces.
add-highlighter -override shared/whitespaces/trailing-whitespaces regex '\h+$' '0:TrailingWhitespace'

# Show odd and mixed indent.
add-highlighter -override shared/whitespaces/odd-indent regex '^( {1}| {3}| {5}| {7}| {9}| {11}| {13}| {15}| {17}| {19})(?=\H)' '0:OddIndent'
add-highlighter -override shared/whitespaces/mixed-indent regex '^(\t+ | +\t)\h*' '0:MixedIndent'

# Show limit of 80 characters.
add-highlighter -override shared/whitespaces/ruler regex '(?S)^.{80}$\K\n' '0:WhitespaceRuler'

# Commands ─────────────────────────────────────────────────────────────────────

define-command -override show-whitespaces -params .. -shell-script-candidates %[ printf '%s\n' -lf -nbsp -spc -tab -tabpad ] -docstring 'show-whitespaces [options]: show whitespaces' %{
  add-highlighter -override global/show-whitespaces show-whitespaces %arg{@}
  add-highlighter -override global/whitespaces ref whitespaces

  # Only shown when not in insert mode.
  remove-hooks global show-whitespaces
  hook -group show-whitespaces -always global ModeChange 'push:normal:insert' %{
    set-face window TrailingWhitespace Whitespace
    set-face window ConsecutiveWhitespace Whitespace

    # Restore
    hook -always -once window ModeChange 'pop:insert:normal' %{
      unset-face window TrailingWhitespace
      unset-face window ConsecutiveWhitespace
    }
  }
}

define-command -override hide-whitespaces -docstring 'hide-whitespaces: hide whitespaces' %{
  remove-highlighter global/show-whitespaces
  remove-hooks global show-whitespaces
  remove-highlighter global/whitespaces
}
