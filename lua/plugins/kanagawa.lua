return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  name = "kanagawa",
  config = function()
    require("kanagawa").setup({
      keywordStyle = { italic = false },
      transparent = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = { italic = true },
      statementStyle = { bold = true },
      terminalColors = true,
      theme = "wave", -- vim.o.background = ""
      background = {
        dark = "wave", -- vim.o.background = "dark"
        light = "lotus" -- vim.o.background = "light"
      },
      overrides = function(colors)
        return {
          Boolean = { bold = false },
        }
      end
    })
    vim.cmd.colorscheme("kanagawa")
    vim.o.background = "dark"
  end
}
