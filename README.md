# spellcheck-mode.nvim

A enhanced spell check mode for Neovim with quick suggestions and intuitive navigation.

## Features

- 🔢 Quick suggestions without having to press Enter
- 🔄 Wrap-around navigation
- 🎯 Buffer-local keymaps that don't interfere with normal workflow
- ⚡ Auto-enable for specific file types
- 🎨 Fully configurable

## Installation

Using lazy.nvim:

```lua
{
  'your-username/spellcheck-mode.nvim',
  config = function()
    require('spellcheck-mode').setup({
      -- Your configuration here
    })
  end
}
```

## Default Configuration

```lua
require('spellcheck-mode').setup({
  keys = {
    toggle = '<leader>sp',     -- Toggle spell check mode
    next_error = 'n',          -- Next spelling error
    prev_error = 'p',          -- Previous spelling error
    suggestions = '<Space>',   -- Show suggestions
  },
  options = {
    default_lang = 'en_gb',    -- Default spell language
    max_suggestions = 10,      -- Maximum number of suggestions to show
    auto_enable_filetypes = {  -- File types to auto-enable spell check
      'markdown', 'gitcommit', 'text', 'tex'
    },
    spell_options = 'camel'    -- Vim spell options
  }
})
```
