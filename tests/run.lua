local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "values differ") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
	end
end

local function run()
	local spellcheck = require("spellcheck-mode")
	local config = require("spellcheck-mode.config")

	spellcheck.setup({
		keys = {
			next_error = "]s",
			prev_error = "[s",
			suggestions = "z=",
			add_to_dict = "zg",
		},
		options = {
			default_lang = "en_us",
			auto_enable_filetypes = { "markdown" },
		},
	})

	assert_equal(vim.fn.exists(":SpellcheckMode"), 2, "setup creates :SpellcheckMode")
	assert_equal(config.get().options.default_lang, "en_us", "setup applies options")

	vim.cmd("enew")
	vim.cmd("setfiletype markdown")
	assert_equal(vim.wo.spell, true, "configured filetype enables spellcheck")
	assert_equal(vim.bo.spelllang, "en_us", "configured filetype applies spell language")
	assert_equal(vim.fn.maparg("]s", "n", false, true).buffer, 1, "auto-enable creates buffer-local mappings")

	spellcheck.toggle_spellcheck()
	assert_equal(vim.wo.spell, false, "toggle disables spellcheck")
	assert_equal(vim.fn.maparg("]s", "n"), "", "toggle removes mode mappings")

	vim.cmd("SpellcheckMode")
	assert_equal(vim.wo.spell, true, "command enables spellcheck")
	assert_equal(vim.fn.maparg("]s", "n", false, true).buffer, 1, "command restores mode mappings")

	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "sentnce" })
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	vim.api.nvim_feedkeys("1", "n", false)
	spellcheck.quick_suggestions()
	assert_equal(vim.api.nvim_get_current_line(), "sentence", "suggestion replaces the misspelled word")
	assert_equal(vim.api.nvim_get_mode().mode, "n", "suggestion replacement remains in Normal mode")

	spellcheck.setup({ options = { auto_enable_filetypes = {} } })
	local autocmds = vim.api.nvim_get_autocmds({ group = "SpellcheckMode", event = "FileType" })
	assert_equal(#autocmds, 0, "setup clears obsolete filetype autocmds")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
	vim.api.nvim_err_writeln(err)
	vim.cmd("cquit 1")
end

print("spellcheck-mode.nvim tests passed")
vim.cmd("qa!")
