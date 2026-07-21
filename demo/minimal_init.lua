local demo_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.runtimepath:prepend(vim.fn.fnamemodify(demo_dir, ":h"))
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.cmd.colorscheme("habamax")

require("spellcheck-mode").setup({
	keys = {
		next_error = "]s",
		prev_error = "[s",
	},
	options = {
		default_lang = "en_us",
	},
})
