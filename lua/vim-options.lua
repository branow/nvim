vim.cmd("set number")
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set clipboard+=unnamedplus")
vim.g.mapleader = " "

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4"
})

vim.keymap.set(
  "n", "<leader>nd", [[<cmd>lua vim.diagnostic.goto_next()<CR>]])
vim.keymap.set(
  "n", "<leader>pd", [[<cmd>lua vim.diagnostic.goto_prev()<CR>]])

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
-- vim.opt.shortmess:append("c")
vim.opt.title = true
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.updatetime = 300
vim.opt.colorcolumn = { 81, 101 }
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "<-",
  lead = ".",
  trail = ".",
  nbsp = "_",
}
vim.opt.showbreak = "->"
vim.opt.foldenable = false
vim.opt.signcolumn = "yes"
vim.opt.formatoptions:append("r")
vim.opt.formatoptions:append("n")
vim.opt.formatoptions:append("t")
vim.opt.swapfile = false
vim.opt.spelllang = { "en", "uk" }
vim.opt.undofile = true
vim.opt.mousemodel = "extend"

