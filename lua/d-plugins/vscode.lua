return {
  "Mofiqul/vscode.nvim",
  lazy = false,
  name = "vscode",
  priority = 1000,
  config = function()
    require("vscode").setup({
      transparent = true,
      italic_comments = true,
      underline_links = true,
    })
    vim.cmd.colorscheme = "vscode"
    vim.o.background = "dark"
  end
}
