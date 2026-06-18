return {
  -- Regex-based T-SQL / MS SQL Server syntax. Unlike treesitter it highlights
  -- token-by-token, so it doesn't collapse to one color when it meets
  -- T-SQL-specific syntax it can't fully parse.
  "vim-scripts/sqlserver.vim",
  ft = { "sql", "sqlserver" },
  init = function()
    vim.g.sql_type_default = "sqlserver"
  end,
}
