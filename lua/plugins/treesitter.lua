return {
  "nvim-treesitter/nvim-treesitter",
  name = "treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "go",
        "java",
        "python"
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}
