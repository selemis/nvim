-- ~/.config/nvim/lua/user/lsp.lua
local M = {}

function M.setup()
    -- Configure LSP global capabilities
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Setup keybindings when an LSP attaches to a buffer
    local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        -- LSP actions
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

        -- Show diagnostics in a floating window
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, bufopts)
    end

    -- Helper function to find Elixir executable
    local function find_elixir()
        -- Check for Elixir in standard locations
        local possible_paths = {
            "/usr/local/bin/elixir",                                -- Homebrew default
            "/opt/homebrew/bin/elixir",                             -- Apple Silicon Homebrew
            vim.fn.expand("$HOME/.asdf/shims/elixir"),              -- asdf
            vim.fn.expand("$HOME/.local/share/rtx/installs/elixir") -- rtx
        }

        -- Also check PATH
        local path_elixir = vim.fn.exepath("elixir")
        if path_elixir ~= "" then
            table.insert(possible_paths, 1, path_elixir)  -- Add to beginning of list
        end

        -- Check each possible path
        for _, path in ipairs(possible_paths) do
            if vim.fn.executable(path) == 1 then
                return path
            end
        end

        return nil  -- Not found
    end

    -- Debug info - print to messages
    local elixir_path = find_elixir()
    if elixir_path then
        vim.notify("Found Elixir at: " .. elixir_path, vim.log.levels.INFO)
    else
        vim.notify("Elixir executable not found! LSP may not work correctly.", vim.log.levels.WARN)
    end

    -- Configure ElixirLS with custom environment
    local elixirls_cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls") }

    -- Setting up environment variables for the LSP server
    local elixirls_env = {
        -- Explicitly set PATH to include Homebrew paths
        PATH = "/usr/local/bin:/opt/homebrew/bin:" .. (vim.fn.getenv("PATH") or ""),
        -- Force the server to use the Elixir we found
        ELIXIR_EXE = elixir_path
    }

    -- Configure ElixirLS
    local lspconfig = require('lspconfig')
    lspconfig.elixirls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = elixirls_cmd,
        cmd_env = elixirls_env,
        -- Important: Configure the root_dir to match your actual project structure
        root_dir = lspconfig.util.root_pattern("mix.exs", ".git"),
        settings = {
            elixirLS = {
                dialyzerEnabled = true,
                fetchDeps = false,
                enableTestLenses = true,
                suggestSpecs = true,
            }
        }
    }

    -- Configure diagnostics appearance
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })

    -- Link to Mason-LSPConfig for automatic server setup
    require("mason-lspconfig").setup_handlers {
        function(server_name)
            -- Skip elixirls as we've manually configured it above
            if server_name ~= "elixirls" then
                lspconfig[server_name].setup {
                    capabilities = capabilities,
                    on_attach = on_attach,
                }
            end
        end,
    }

    -- Add command to show LSP environment
    vim.api.nvim_create_user_command("ElixirLspInfo", function()
        local info = {
            ["Elixir Path"] = elixir_path or "Not found",
            ["ElixirLS Path"] = elixirls_cmd[1],
            ["PATH"] = elixirls_env.PATH,
            ["Root Dir Setting"] = "mix.exs or .git",
        }

        vim.api.nvim_echo({{"Elixir LSP Configuration:\n", "Title"}}, false, {})
        for k, v in pairs(info) do
            vim.api.nvim_echo({{k .. ": ", "String"}, {v, "None"}}, false, {})
        end
    end, {})
end

return M
