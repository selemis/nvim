-- Core options from my old vimrc
local options = {

  -- Display
  termguicolors = true,        -- Enable true color support

}

-- Apply all options
for k, v in pairs(options) do
  vim.opt[k] = v
end
