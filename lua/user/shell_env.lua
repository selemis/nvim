-- ~/.config/nvim/lua/user/shell_env.lua
local M = {}

-- Check for important environment variables and executables
function M.check()
    local result = {
        elixir_found = false,
        elixir_path = "",
        elixir_version = "",
        shell_path = vim.fn.getenv("PATH") or "",
        shell = vim.fn.getenv("SHELL") or "",
        issues = {},
    }

    -- Check if elixir is in the PATH
    local elixir_path = vim.fn.exepath("elixir")
    if elixir_path ~= "" then
        result.elixir_found = true
        result.elixir_path = elixir_path

        -- Get Elixir version
        local handle = io.popen("elixir --version 2>&1")
        if handle then
            local version = handle:read("*a")
            handle:close()
            result.elixir_version = version:match("Elixir%s+([%d%.]+)") or "Unknown"
        end
    else
        table.insert(result.issues, "Elixir executable not found in PATH")
    end

    -- Check if we're using a version manager
    local version_managers = {
        asdf = vim.fn.exepath("asdf"),
        mise = vim.fn.exepath("mise"),
        rtx = vim.fn.exepath("rtx"),
        vfox = vim.fn.exepath("vfox"),
    }

    result.version_managers = {}
    for name, path in pairs(version_managers) do
        if path ~= "" then
            table.insert(result.version_managers, name)
        end
    end

    if #result.version_managers == 0 and not result.elixir_found then
        table.insert(result.issues, "No version manager found (asdf, mise, rtx, vfox)")
    end

    return result
end

-- Print the environment status
function M.print_status()
    local status = M.check()

    vim.api.nvim_echo({{"Elixir Environment Status:\n", "Title"}}, false, {})

    if status.elixir_found then
        vim.api.nvim_echo({{"✓ Elixir found: ", "String"}, {status.elixir_path, "None"}}, false, {})
        vim.api.nvim_echo({{"✓ Elixir version: ", "String"}, {status.elixir_version, "None"}}, false, {})
    else
        vim.api.nvim_echo({{"✗ Elixir not found", "ErrorMsg"}}, false, {})
    end

    if #status.version_managers > 0 then
        vim.api.nvim_echo({{"✓ Version managers: ", "String"}, {table.concat(status.version_managers, ", "), "None"}}, false, {})
    end

    vim.api.nvim_echo({{"Shell: ", "String"}, {status.shell, "None"}}, false, {})
    vim.api.nvim_echo({{"PATH environment variable: ", "String"}}, false, {})
    for path in string.gmatch(status.shell_path, "([^:]+)") do
        vim.api.nvim_echo({{"  " .. path, "None"}}, false, {})
    end

    if #status.issues > 0 then
        vim.api.nvim_echo({{"Issues found:", "WarningMsg"}}, false, {})
        for _, issue in ipairs(status.issues) do
            vim.api.nvim_echo({{"  - " .. issue, "WarningMsg"}}, false, {})
        end

        vim.api.nvim_echo({{"", "None"}}, false, {})
        vim.api.nvim_echo({{"Recommendations:", "Title"}}, false, {})
        vim.api.nvim_echo({{"1. Install Elixir using Homebrew: 'brew install elixir'", "None"}}, false, {})
        vim.api.nvim_echo({{"2. Or install asdf and use it to manage Elixir: 'brew install asdf'", "None"}}, false, {})
        vim.api.nvim_echo({{"3. Make sure Elixir is in your PATH", "None"}}, false, {})
        vim.api.nvim_echo({{"4. Restart Neovim after installing", "None"}}, false, {})
    end
end

-- Add a command to check Elixir environment
function M.setup()
    vim.api.nvim_create_user_command("CheckElixirEnv", function()
        M.print_status()
    end, {})
end

return M
