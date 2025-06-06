return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  end
}
-- - ERROR rg: not found. `live-grep` finder will not function without [BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep) installed.
-- - WARNING fd: not found. Install [sharkdp/fd](https://github.com/sharkdp/fd) for extended capabilities
