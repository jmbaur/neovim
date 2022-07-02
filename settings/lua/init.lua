vim.g.mapleader = " "
vim.g.markdown_fenced_languages = { "bash=sh", "python", "typescript", "go" }

if vim.g.embed == 0 then
	require("ui")
end
require("behavior")
require("sitter")

vim.opt.clipboard = "unnamedplus"
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.showmatch = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.wrap = false
