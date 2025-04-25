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
    },

    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- Optional, for file icons
        },
        event = "VeryLazy",
        config = function()
            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })

            -- Key mappings
            vim.keymap.set('n', '<leader>1', ':NvimTreeToggle<CR>', {silent = true})
            -- Similar to your netrw mapping
            vim.keymap.set('n', '-', ':NvimTreeFocus<CR>', {silent = true})
        end
    },
    -- Replacement for ctrl-p
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make"
            }
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = {"node_modules", ".git"},
                    layout_strategy = "horizontal",
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    }
                }
            })

            -- Load extensions
            require("telescope").load_extension("fzf")

            -- Key mappings similar to your CtrlP config
            vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, {})
            vim.keymap.set('n', '<C-r>', require('telescope.builtin').oldfiles, {})
            vim.keymap.set('n', '<leader>f', function()
                vim.cmd('Telescope find_files')
            end, {})
        end
    }

  -- Add more plugins here as we migrate them
}
