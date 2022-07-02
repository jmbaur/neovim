require("lsp")
require("scope")
require("snips")
require("nvim-lastplace").setup({})

vim.opt.belloff = "all"
vim.opt.colorcolumn = "80"
vim.opt.cursorline = false -- https://github.com/neovim/neovim/issues/9800
vim.opt.list = false
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statusline = "%<%f %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%) %P"
vim.opt.termguicolors = false

vim.cmd("colorscheme jared")
