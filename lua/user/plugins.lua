-- ~/.config/nvim/lua/user/plugins.lua

return {
  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- Load colorscheme early
    config = function()
      vim.cmd.colorscheme "gruvbox"
    end,
  },

  -- Add more plugins here as we migrate them
}
