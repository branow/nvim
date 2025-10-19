return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    -- ts-autotag utilizes treesitter to understand the code structure to automatically clsoe tsx tags
    "windwp/nvim-ts-autotag"
  },
  name = "treesitter",
  -- when the plugin builds run the TSUpdate commnad to ensure all our servers are installed and updated
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "vim",
        "vimdoc",
        "lua",
        "go",
        "glsl",
        "python",
        "java",
        "kotlin",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "gitignore",
        "json",
        "xml",
        "php",
      },
      highlight = { enable = true },
      autotag = {
        enable = true
      },
      indent = { enable = true },
    })
  end
}
