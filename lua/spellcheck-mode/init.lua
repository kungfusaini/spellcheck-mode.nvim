local M = {}
local config = require('spellcheck-mode.config')

-- Setup function for configuration only
M.setup = function(user_config)
	config.set(user_config or {})
end

-- Pre-create a buffer for the floating window to avoid recreation overhead
local suggestion_buf = vim.api.nvim_create_buf(false, true)

-- Custom function for previous error that WRAPS AROUND
local function prev_spell_error_wrap()
	local initial_pos = vim.fn.getpos('.')
	vim.cmd('normal! [s')
	if vim.fn.getpos('.') == initial_pos then
		vim.cmd('normal! G')
		vim.cmd('normal! [s')
	end
end

-- Fast floating window implementation with pre-allocated buffer
local function quick_suggestions()
	local word = vim.fn.spellbadword()
	if word[1] == '' then return end

	-- Get suggestions
	local suggestions = vim.fn.spellsuggest(word[1], config.current.options.max_suggestions)
	if #suggestions == 0 then return end

	-- Prepare content
	local lines = { "Suggestions:" }
	for i, suggestion in ipairs(suggestions) do
		table.insert(lines, i .. ". " .. suggestion)
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(suggestion_buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(suggestion_buf, 'modifiable', false)

	-- Calculate window position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local row = math.min(cursor_pos[1] - 1, vim.o.lines - #lines - 3)
	local col = math.min(cursor_pos[2], vim.o.columns - 50)

	-- Create or update floating window
	local win = vim.api.nvim_open_win(suggestion_buf, true, {
		relative = 'editor',
		width = 50,
		height = #lines,
		row = row,
		col = col,
		style = 'minimal',
		focusable = false,
		noautocmd = true, -- Skip autocmds for faster creation
		border = 'single',
	})

	-- Get user input
	vim.cmd('redraw')
	local choice = vim.fn.nr2char(vim.fn.getchar())
	local num = tonumber(choice)

	-- Close the suggestion window
	vim.api.nvim_win_close(win, true)

	if num and num >= 1 and num <= #suggestions then
		vim.cmd('normal! ciw' .. suggestions[num])
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
