-- ~/.config/nvim/lua/user/plugins.lua

-- Add this to the top of your plugins.lua file, outside any plugin definitions
local function read_env_file()
  local home = os.getenv("HOME")
  local env_path = home .. "/.env"
  local file = io.open(env_path, "r")

  if not file then
    print("Could not open .env file at: " .. env_path)
    return false
  end

  local contents = file:read("*all")
  file:close()

  for line in contents:gmatch("[^\r\n]+") do
    local key, value = line:match("^([%w_]+)=(.+)$")
    if key and value then
      -- Remove any quotes that might be present
      value = value:gsub('^"(.*)"$', '%1')
      value = value:gsub("^'(.*)'$", '%1')

      -- Set environment variable
      vim.fn.setenv(key, value)
      print("Set environment variable: " .. key)
    end
  end

  return true
end


return {

    -- Colorschemes/Themes
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000, -- High priority to load early
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
    },

    {
        "folke/tokyonight.nvim",
        priority = 1000,
    },

    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
    },

    {
        "shaunsingh/solarized.nvim",  -- Solarized theme
        priority = 1000,
    },

    {
        "maxmx03/solarized.nvim",  -- Another implementation with both light and dark variants
        priority = 1000,
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

            -- Add coloscheme picker
            vim.keymap.set('n', '<leader>ct', function()
                require('telescope.builtin').colorscheme({enable_preview = true})
            end)
        end
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        priority = 800,
        config = function()
            require("nvim-treesitter.configs").setup({
                -- A list of parser names, or "all" (parsers with treesitter support)
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query", -- For Neovim itself
                    "bash", "markdown", "markdown_inline", -- Common formats
                    "elixir", "heex", "eex", -- Elixir
                    "javascript", "typescript", "html", "css", -- Web
                    "json", "yaml", "toml", -- Data formats
                    "c", "python", "ruby", -- Other languages
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                auto_install = true,

                highlight = {
                    enable = true,
                    -- Using TreeSitter disables the Vim regex syntax highlighting
                    additional_vim_regex_highlighting = false,
                },

                indent = {
                    enable = true,
                },

                -- Incremental selection based on the named nodes from the grammar
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn", -- Start incremental selection
                        node_incremental = "grn", -- Increment selection to next named node
                        scope_incremental = "grc", -- Increment selection to next scope
                        node_decremental = "grm", -- Decrement selection to previous node
                    },
                },
            })
        end,
    },

    -- Rainbow parentheses using treesitter
    {
        "HiPhish/nvim-ts-rainbow2",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({
                rainbow = {
                    enable = true,
                    -- Which query to use for finding delimiters
                    query = 'rainbow-parens',
                    -- Highlight the entire buffer all at once
                    strategy = require('ts-rainbow').strategy.global,
                },
            })
        end,
    },

    {
        "github/copilot.vim",
        lazy = false,
        config = function()
            -- Basic configuration
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
            vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Next()', { silent = true, expr = true })
            vim.api.nvim_set_keymap("i", "<C-h>", 'copilot#Previous()', { silent = true, expr = true })
        end
    },

    {
        'roman/golden-ratio',
        config = function()
        end
    },

  -- Add more plugins here as we migrate them
}
