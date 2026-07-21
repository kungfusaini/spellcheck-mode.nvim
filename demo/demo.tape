Output assets/demo.gif

Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 700
Set Padding 0
Set Margin 0
Set MarginFill "#1e1e2e"
Set TypingSpeed 35ms
Set PlaybackSpeed 1
Set LoopOffset 20%
Set Theme "Catppuccin Mocha"

Type "nvim -n -u demo/minimal_init.lua -c SpellcheckMode demo/sample.md"
Enter
Sleep 3s
Type "]s"
Sleep 1s
Space
Sleep 2s
Type "1"
Sleep 2s
Type "]s"
Sleep 1s
Space
Sleep 2s
Type "1"
Sleep 3s
Type ":qa!"
Enter
