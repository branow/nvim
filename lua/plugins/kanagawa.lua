return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  name = "kanagawa",
  config = function()
    require("kanagawa").setup({
      keywordStyle = { italic = false },
      transparent = false,
      overrides = function(colors)
        return {
          Boolean = { bold = false },
        }
      end
    })
    vim.cmd.colorscheme("kanagawa-wave")
  end
}
