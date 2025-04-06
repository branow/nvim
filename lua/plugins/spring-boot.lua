return {
  "elmcgill/springboot-nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-jdtls",
  },
  config = function()
    local sb = require("springboot-nvim");

    vim.keymap.set('n', '<leader>Jr', sb.boot_run, {desc = "[J]ava [R]un Spring Boot"})
    vim.keymap.set('n', '<leader>Jc', sb.generate_class, {desc = "[J]ava Create [C]lass"})
    vim.keymap.set('n', '<leader>Ji', sb.generate_interface, {desc = "[J]ava Create [I]nterface"})
    vim.keymap.set('n', '<leader>Je', sb.generate_enum, {desc = "[J]ava Create [E]num"})

    sb.setup({})
  end
}
