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
    },

    -- Replacement for dragvisuals.vim
    {
        'echasnovski/mini.move',
        version = false,
        event = "VeryLazy",
        config = function()
            require('mini.move').setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Move visual selection in Visual mode
                    left = '<LEFT>',
                    right = '<RIGHT>',
                    down = '<DOWN>',
                    up = '<UP>',

                    -- Move current line in Normal mode
                    line_left = '',
                    line_right = '',
                    line_down = '',
                    line_up = '',
                },
                -- Options which control moving behavior
                options = {
                    -- Automatically reindent selection during linewise vertical move
                    reindent_linewise = false,
                },
            })
        end
    },

    -- Replacement for Tabularize.vim
    {
        'echasnovski/mini.align',
        version = false,
        event = "VeryLazy",
        config = function()
            require('mini.align').setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    start = 'ga',
                    start_with_preview = 'gA',
                },
            })
        end
    }

  -- Add more plugins here as we migrate them
}
