vim.cmd("set number")
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set clipboard+=unnamedplus")
vim.g.mapleader = " "

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "java",
--   command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4"
-- })

vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format() end)
vim.keymap.set("v", "<leader>p", "\"_dP")
vim.keymap.set(
  "n", "<leader>nd", [[<cmd>lua vim.diagnostic.goto_next()<CR>]])
vim.keymap.set(
  "n", "<leader>pd", [[<cmd>lua vim.diagnostic.goto_prev()<CR>]])

-- Double <Tab> handler for window nav, without breaking single <Tab>
vim.keymap.set('n', '<Tab>', function()
  local key = vim.fn.getchar()
  if type(key) == "number" then
    key = vim.fn.nr2char(key)
  end

  if key == '\t' then
    -- Double Tab → next window
    vim.cmd('wincmd w')
  elseif tonumber(key) then
    -- Tab + number → go to window N
    vim.cmd('wincmd ' .. key .. 'w')
  else
    -- Fallback: re-inject <Tab> + key into input stream to preserve Harpoon or others
    vim.api.nvim_feedkeys('\t' .. key, 'n', true)
  end
end, { noremap = true })


vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
-- vim.opt.shortmess:append("c")
vim.opt.title = true
-- vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.completeopt = { "menu", "menuone", }
vim.opt.updatetime = 300
vim.opt.colorcolumn = { 81, 101 }
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = {
   -- tab      = "⇥-",
   tab      = "··",
   lead     = "·",
   trail    = "·",
   nbsp     = "⇥",
   extends  = "⟩",
   precedes = "⟨",
}
vim.opt.showbreak = "⇥-"
vim.opt.foldenable = false
vim.opt.signcolumn = "yes"
vim.opt.formatoptions:append("r")
vim.opt.formatoptions:append("n")
vim.opt.formatoptions:append("t")
vim.opt.swapfile = false
vim.opt.spelllang = { "en_US", "uk" }
vim.opt.spell = true
vim.opt.undofile = true
vim.opt.mousemodel = "extend"

vim.filetype.add({
  extension = {
    dwl = "c",  -- use Tree-sitter C parser for .dwl files
  },
})
