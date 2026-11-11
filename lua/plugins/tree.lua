return {
  "nvim-neo-tree/neo-tree.nvim",
  name = "neo-tree",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup {
      enable_diagnostics = true,
      default_component_configs = {
        diagnostics = {
          errors_only = false,
          icons = {
            hint = "●",
          },
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        }
      },
      window = {
        audo_expand_width = true,
        position = "left",
        width = 35,
        view = { adaptive_size = true },
        mappings = {
          -- neo-tree maps <Tab> to "select"; unmap it so the global
          -- double-Tab window-nav handler (lua/vim-options.lua) works here.
          ["<Tab>"] = "none",
        },
      }
    }
    vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', {})
  end
}
