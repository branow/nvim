return {
  {
    'tpope/vim-dadbod',
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion',
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_win_position = 'left'
      vim.keymap.set('n', '<leader-c>', '<cmd>DBUI<CR>')
      vim.keymap.set('n', '<leader>q', '<Plug>(DBUI_ExecuteQuery)')
      vim.keymap.set('v', '<leader>q', '<Plug>(DBUI_ExecuteQuery)')
      vim.keymap.set('n', '<leader>df', '<cmd>DBUIFindBuffer<CR>')
    end,
  },
  {
    'kristijanhusak/vim-dadbod-completion',
    dependencies = { 'tpope/vim-dadbod' },
    ft = { 'sql', 'mysql', 'plsql' },
  },
}
