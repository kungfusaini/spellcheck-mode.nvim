local M = {}

-- Default configuration
local defaults = {
	keys = {
		next_error = 'n',
		prev_error = 'p',
		suggestions = '<Space>',
		add_to_dict = 'A' -- New key for adding to dictionary
	},
	options = {
		default_lang = 'en_gb',
		max_suggestions = 10,
		auto_enable_filetypes = { 'markdown', 'gitcommit', 'text', 'tex' },
		spell_options = 'camel'
	}
}

-- Current configuration
M.current = vim.deepcopy(defaults)

-- Merge user configuration with defaults
function M.set(user_config)
	user_config = user_config or {}

	-- Merge keys
	if user_config.keys then
		M.current.keys = vim.tbl_extend('force', M.current.keys, user_config.keys)
	end

	-- Merge options
	if user_config.options then
		M.current.options = vim.tbl_extend('force', M.current.options, user_config.options)
	end

	-- Apply spell options
	vim.opt.spelloptions = M.current.options.spell_options
end

-- Get configuration
function M.get()
	return M.current
end

-- Initialize with defaults
M.set()

return M
