-- Core options from my old vimrc
local options = {

  -- Display
  termguicolors = true,        -- Enable true color support
  background = "dark",         -- Dark background
  number = true,               -- Show line numbers

  -- Indentation
  expandtab = true,            -- Convert tabs to spaces
  tabstop = 4,                 -- 4 spaces for a tab
  shiftwidth = 4,              -- 4 spaces when indenting
  smartindent = true,          -- Auto-indent new lines

  -- Search
  hlsearch = true,             -- Highlight search results
  ignorecase = true,           -- Case insensitive search
  smartcase = true,            -- Case sensitive when using uppercase
  incsearch = true,            -- Incremental search

  -- Code display
  syntax = "on",               -- Enable syntax highlighting

  -- Split management
  splitbelow = true,           -- Open horizontal splits below
  splitright = true,           -- Open vertical splits to the right

  -- File handling
  swapfile = true,             -- Use swap files
  directory = vim.fn.expand("$HOME/.local/share/nvim/swp//"), -- Store swap files here

  -- Editor behavior
  mouse = "a",                 -- Enable mouse in all modes
  ruler = true,                -- Show cursor position

  -- GUI options for Neovim GUI applications
  guifont = "FiraMono:h16",    -- Default font
}

-- Apply all options
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Set color column marker
vim.opt.colorcolumn = "81"
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#FF0000" })

