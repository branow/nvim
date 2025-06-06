return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  dependency = {
    "nvim-lua/plenary.nvim"
  },
  config = function()
    -- <Shift> m
    vim.keymap.set("n", "<s-m>", "<cmd>lua require('harpoon.mark').add_file()<cr>", {desc = "Harpoon Mark File"})
    vim.keymap.set("n", "<leader><TAB>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {desc = "Harpoon Toggle  Menu"})

    require("harpoon").setup({
      menu = {
        width = 90,
      },
    })
  end
}
