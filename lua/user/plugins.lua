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

    {
        'echasnovski/mini.trailspace',
        version = false,
        config = function()
            require('mini.trailspace').setup({
                -- Highlight only in normal buffers (not in terminal, help, etc)
                only_in_normal_buffers = true
            })
        end
    }

  -- Add more plugins here as we migrate them
}
