local M = {}
local config = require('spellcheck-mode.config')

-- Setup asdf function for configuration only
M.setup = function(user_config)
	config.set(user_config or {})
end

-- Custom function for previous error that WRAPS AROUND
local function prev_spell_error_wrap()
	local initial_pos = vim.fn.getpos('.')
	vim.cmd('normal! [s')
	if vim.fn.getpos('.') == initial_pos then
		vim.cmd('normal! G')
		vim.cmd('normal! [s')
	end
end

-- Toggle spellcheck with language selection and custom keymaps
function M.toggle_spellcheck()
	if vim.o.spell then
		-- Turn spellcheck OFF and clean up our custom keymaps
		vim.o.spell = false
		pcall(vim.keymap.del, 'n', config.current.keys.next_error, { buffer = 0 })
		pcall(vim.keymap.del, 'n', config.current.keys.prev_error, { buffer = 0 })
		pcall(vim.keymap.del, 'n', config.current.keys.suggestions, { buffer = 0 })
		print("Spellcheck: OFF")
	else
		-- Turn spellcheck ON
		vim.o.spell = true
		vim.o.spelllang = config.current.options.default_lang
		print("Spellcheck: ON (" .. vim.o.spelllang .. ")")

		-- Create buffer-local keymaps
		-- In your setup function
		vim.keymap.set('n', config.current.keys.suggestions, 'z=', {
			buffer = 0,
			desc = 'Show spelling suggestions'
		})
		vim.keymap.set('n', config.current.keys.next_error, ']s', {
			buffer = 0,
			desc = 'Next spelling error',
			nowait = true
		})

		vim.keymap.set('n', config.current.keys.prev_error, prev_spell_error_wrap, {
			buffer = 0,
			desc = 'Previous spelling error (wrap)',
			nowait = true
		})

		vim.keymap.set('n', config.current.keys.suggestions, quick_suggestions, {
			buffer = 0,
			desc = 'Show spelling suggestions (quick)'
		})
	end
end

-- Auto-enable for configured file types
local function setup_autocmds()
	if #config.current.options.auto_enable_filetypes > 0 then
		vim.api.nvim_create_autocmd({ "FileType" }, {
			pattern = config.current.options.auto_enable_filetypes,
			callback = function()
				vim.opt_local.spell = true
				vim.opt_local.spelllang = config.current.options.default_lang
			end
		})
	end
end

-- Initialize auto commands
setup_autocmds()

return M
