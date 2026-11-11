return {
  "nvim-treesitter/nvim-treesitter",
  name = "treesitter",
  -- the main branch is the rewrite that supports Neovim 0.12; it does not support lazy-loading
  branch = "main",
  lazy = false,
  dependencies = {
    -- ts-autotag utilizes treesitter to understand the code structure to automatically clsoe tsx tags
    "windwp/nvim-ts-autotag"
  },
  -- when the plugin builds run the TSUpdate commnad to ensure all our parsers are installed and updated
  build = ":TSUpdate",
  config = function()
    -- parsers are compiled locally, so this needs the tree-sitter CLI (brew install tree-sitter-cli)
    require("nvim-treesitter").install({
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
      "rust",
      "sql",
    })

    -- sql is highlighted by sqlserver.vim instead (see tsql.lua)
    local no_highlight = { sql = true }

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang or not vim.treesitter.language.add(lang) then
          return
        end
        if not no_highlight[lang] then
          vim.treesitter.start(args.buf, lang)
        end
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    require("nvim-ts-autotag").setup()
  end
}
