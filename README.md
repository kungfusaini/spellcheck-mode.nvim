# spellcheck-mode.nvim

A powerful spell check mode for Neovim with intuitive navigation, quick suggestions, and dictionary management.

## Features

- 🚀 **Fast floating window suggestions** with instant word replacement
- 🔄 **Wrap-around navigation** for previous spelling errors  
- 📝 **Add words to dictionary** directly from suggestions
- ⚡ **Auto-enable** for specific file types
- 🎯 **Buffer-local keymaps** that don't interfere with normal editing
- 🔧 **Fully configurable** keybindings and options

## Installation

Using lazy.nvim:

```lua
return {
  'kungfusaini/spellcheck-mode.nvim',
  config = function()
    require('spellcheck-mode').setup({
      keys = {
        next_error = 'n',          -- Go to next spelling error
        prev_error = 'p',          -- Go to previous spelling error (with wrap-around)
        suggestions = '<Space>',   -- Show suggestions in floating window
        add_to_dict = 'A'          -- Add current word to dictionary
      },
      options = {
        default_lang = 'en_gb',    -- Default spell check language
        max_suggestions = 10,      -- Maximum number of suggestions to show
        auto_enable_filetypes = {  -- File types to auto-enable spell check
          'markdown', 'gitcommit', 'text', 'tex'
        },
        spell_options = 'camel'    -- Vim spell options
      }
    })
  end
}
```

## Usage
### Basic Commands
- Toggle spell check mode: <leader>sp

- Navigate to next error: n (when spell check is active)

- Navigate to previous error: p (when spell check is active, with wrap-around)
- Show suggestions: <Space> (when on a misspelled word)
- Add to dictionary: A (when on a misspelled word)

### Suggestion Window
When you press <Space> on a misspelled word:

- A floating window appears with numbered suggestions

- Type a number to instantly replace the word

- Press A to add the word to your personal dictionary

### Auto-enable
Spell check automatically enables for these file types:

- Markdown (*.md)

- Git commit messages

- Plain text files (*.txt)

- LaTeX files (*.tex)

## Configuration
### Key Customization
All keybindings are configurable:

``` lua
keys = {
  next_error = ']',          -- Change next error key
  prev_error = '[',          -- Change previous error key  
  suggestions = 's',         -- Change suggestions key
  add_to_dict = 'D'          -- Change add to dictionary key
}
```

### Language Options
```lua
options = {
  default_lang = 'en_us',    -- Use US English
  max_suggestions = 5,       -- Show fewer suggestions
  auto_enable_filetypes = {  -- Add more file types
    'markdown', 'gitcommit', 'text', 'tex', 'latex'
  },
  spell_options = 'camel'    -- Support camelCase words
}
``` 
## Key Features
- Wrap-around Navigation
The p key for previous errors wraps around to the end of the file when you reach the beginning, providing seamless navigation.

- Dictionary Management
Quickly add words to your personal dictionary to prevent them from being flagged in the future.

- Non-intrusive
All keymaps are buffer-local and only active when spell check is enabled, so they don't interfere with your normal editing workflow.

## Requirements
Neovim 0.8+

Lazy.nvim (or your preferred package manager)
