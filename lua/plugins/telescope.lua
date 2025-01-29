return { 
  "nvim-telescope/telescope.nvim", 
  tag = "0.1.5", 
  depencies = {"nvim-lua/plenary.nvim"},
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set('n', '<c-p>', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  end
}
