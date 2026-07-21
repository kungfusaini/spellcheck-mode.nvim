local M = {}
local config = require("spellcheck-mode.config")
local setup_autocmds

function M.setup(user_config)
	config.set(user_config or {})
	setup_autocmds()

	vim.api.nvim_create_user_command("SpellcheckMode", M.toggle_spellcheck, {
		desc = "Toggle spellcheck mode for the current window",
		force = true,
	})
end

-- Pre-create a buffer for the floating window to avoid recreation overhead
local suggestion_buf = vim.api.nvim_create_buf(false, true)

-- Custom function for previous error that wraps
function M.prev_error_wrap()
	local initial_pos = vim.fn.getpos('.')
	vim.cmd('normal! [s')
	if vim.fn.getpos('.') == initial_pos then
		vim.cmd('normal! G')
		vim.cmd('normal! [s')
	end
end

-- Replace a word without entering Insert mode or interpreting characters in the
-- suggestion as Normal-mode commands. Exposed for deterministic testing.
function M._replace_current_word(word, suggestion)
	local row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local search_from = 1

	while true do
		local word_start, word_end = line:find(word, search_from, true)
		if not word_start then
			return false
		end
		if word_start - 1 <= cursor_col and word_end >= cursor_col then
			local start_col = word_start - 1
			vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, word_end, { suggestion })
			vim.api.nvim_win_set_cursor(0, { row, start_col + #suggestion - 1 })
			return true
		end
		search_from = word_end + 1
	end
end

-- Fast floating window implementation with pre-allocated buffer
function M.quick_suggestions()
	local word = vim.fn.spellbadword()
	if word[1] == '' then return end

	-- Store the current word for potential addition to dictionary
	local current_word = vim.fn.expand('<cword>')

	-- Get suggestions
	local suggestions = vim.fn.spellsuggest(word[1], config.current.options.max_suggestions)
	if #suggestions == 0 then return end

	-- Prepare content
	local lines = { "Suggestions for '" .. current_word .. "':", "" }
	for i, suggestion in ipairs(suggestions) do
		table.insert(lines, i .. ". " .. suggestion)
	end

	-- Add instruction for adding to dictionary
	table.insert(lines, "")
	table.insert(lines, "Press '" .. config.current.keys.add_to_dict .. "' to add to dictionary")

	-- Make buffer modifiable again before setting content
	vim.api.nvim_buf_set_option(suggestion_buf, 'modifiable', true)
	vim.api.nvim_buf_set_lines(suggestion_buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(suggestion_buf, 'modifiable', false)

	-- Calculate window position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local row = math.min(cursor_pos[1] - 1, vim.o.lines - #lines - 3)
	local col = math.min(cursor_pos[2], vim.o.columns - 60)

	local win = vim.api.nvim_open_win(suggestion_buf, true, {
		relative = 'editor',
		width = 60,
		height = #lines,
		row = row,
		col = col,
		style = 'minimal',
		focusable = false,
		noautocmd = true,
		border = 'single',
	})

	-- Get user input
	vim.cmd('redraw')
	local choice = vim.fn.nr2char(vim.fn.getchar())
	local num = tonumber(choice)

	-- Close the suggestion window
	vim.api.nvim_win_close(win, true)

	-- Handle adding to dictionary
	if choice == config.current.keys.add_to_dict then
		M.add_to_dictionary()
		return
	end

	if num and num >= 1 and num <= #suggestions then
		M._replace_current_word(word[1], suggestions[num])
	end
end

-- Add current word to dictionary (can be called without showing window)
function M.add_to_dictionary()
	local current_word = vim.fn.expand('<cword>')
	vim.cmd('normal! zg')
	print("Added '" .. current_word .. "' to dictionary")
end

-- Setup keymaps for spell check mode
function M.setup_keymaps()
	-- Create buffer-local keymaps
	vim.keymap.set('n', config.current.keys.next_error, ']s', {
		buffer = 0,
		desc = 'Next spelling error',
		nowait = true
	})

	vim.keymap.set('n', config.current.keys.prev_error, M.prev_error_wrap, {
		buffer = 0,
		desc = 'Previous spelling error (wrap)',
		nowait = true
	})

	vim.keymap.set('n', config.current.keys.suggestions, M.quick_suggestions, {
		buffer = 0,
		desc = 'Show spelling suggestions (quick)'
	})

	-- Add to dictionary keymap (works without showing window)
	vim.keymap.set('n', config.current.keys.add_to_dict, M.add_to_dictionary, {
		buffer = 0,
		desc = 'Add word to dictionary'
	})
end

-- Remove keymaps for spell check mode
function M.remove_keymaps()
	pcall(vim.keymap.del, 'n', config.current.keys.next_error, { buffer = 0 })
	pcall(vim.keymap.del, 'n', config.current.keys.prev_error, { buffer = 0 })
	pcall(vim.keymap.del, 'n', config.current.keys.suggestions, { buffer = 0 })
	pcall(vim.keymap.del, 'n', config.current.keys.add_to_dict, { buffer = 0 })
end

-- Toggle spellcheck
function M.toggle_spellcheck()
	if vim.wo.spell then
		vim.opt_local.spell = false
		M.remove_keymaps()
		vim.notify("Spellcheck: OFF")
	else
		vim.opt_local.spell = true
		vim.opt_local.spelllang = config.current.options.default_lang
		M.setup_keymaps()
		vim.notify("Spellcheck: ON (" .. config.current.options.default_lang .. ")")
	end
end

-- Rebuild the FileType autocmd whenever setup() receives new configuration.
setup_autocmds = function()
	local group = vim.api.nvim_create_augroup("SpellcheckMode", { clear = true })
	if #config.current.options.auto_enable_filetypes == 0 then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = config.current.options.auto_enable_filetypes,
		callback = function()
			vim.opt_local.spell = true
			vim.opt_local.spelllang = config.current.options.default_lang
			M.setup_keymaps()
		end,
	})
end

return M
