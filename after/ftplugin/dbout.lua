vim.opt_local.colorcolumn = ''

local dbout = require('dbout')
vim.keymap.set('n', 'gs', dbout.sort,         { buffer = true, silent = true, desc = 'Sort by column under cursor' })
vim.keymap.set('n', 'gS', dbout.clear_sort,   { buffer = true, silent = true, desc = 'Remove sort for column under cursor' })
vim.keymap.set('n', 'gf', dbout.filter,       { buffer = true, silent = true, desc = 'Filter by value under cursor' })
vim.keymap.set('n', 'gF', dbout.clear_filter, { buffer = true, silent = true, desc = 'Remove filter for column under cursor' })
vim.keymap.set('n', 'ga', dbout.pin_col,      { buffer = true, silent = true, desc = 'Pin column to front' })
vim.keymap.set('n', 'gA', dbout.unpin_col,    { buffer = true, silent = true, desc = 'Unpin column under cursor' })
vim.keymap.set('n', 'gX', dbout.clear,        { buffer = true, silent = true, desc = 'Clear everything (sort/filter/pins)' })
vim.keymap.set('n', ']c', dbout.next_col,     { buffer = true, silent = true, desc = 'Jump to next column' })
vim.keymap.set('n', '[c', dbout.prev_col,     { buffer = true, silent = true, desc = 'Jump to previous column' })
