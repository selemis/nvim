-- Leader key
vim.g.mapleader = "\\"

-- Clear search highlights with backspace in normal mode
vim.keymap.set('n', '<BS>', ':nohlsearch<CR>', { silent = true })

-- Move vertically by visual line
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Edit vimrc in new tab
vim.keymap.set('n', '<leader>ev', ':tabedit $MYVIMRC<CR>')
