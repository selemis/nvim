-- ~/.config/nvim/lua/user/elixir_diagnostics.lua
local M = {}

-- Function to check Elixir installation
function M.check_elixir()
    local result = {
        status = "unknown",
        message = "",
        version = "",
        path = "",
        details = {}
    }

    -- Try to execute elixir --version
    local handle = io.popen("elixir --version 2>&1")
    if not handle then
        result.status = "error"
        result.message = "Failed to run command"
        return result
    end

    local output = handle:read("*a")
    handle:close()

    if output:match("command not found") or output:match("not recognized") then
        result.status = "not_found"
        result.message = "Elixir not found in PATH"
    elseif output:match("Elixir") then
        result.status = "ok"
        result.version = output:match("Elixir%s+([%d%.]+)") or "Unknown"
        result.message = "Elixir " .. result.version .. " found"

        -- Find path
        local path_handle = io.popen("which elixir 2>&1")
        if path_handle then
            result.path = path_handle:read("*l") or ""
            path_handle:close()
        end
    else
        result.status = "error"
        result.message = "Unknown error running elixir"
        result.details.output = output
    end

    return result
end

-- Function to check Mason ElixirLS installation
function M.check_elixirls()
    local result = {
        status = "unknown",
        message = "",
        path = "",
        details = {}
    }

    local elixirls_path = vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls")
    if vim.fn.executable(elixirls_path) == 1 then
        result.status = "ok"
        result.message = "ElixirLS found at " .. elixirls_path
        result.path = elixirls_path

        -- Check if script is valid
        local file = io.open(elixirls_path, "r")
        if file then
            local content = file:read("*a")
            file:close()

            if content:match("command not found: elixir") then
                result.status = "warning"
                result.message = "ElixirLS script might have issues finding Elixir"
            end
        end
    else
        result.status = "not_found"
        result.message = "ElixirLS not found at " .. elixirls_path
    end

    return result
end

-- Function to check if launch.sh is working
function M.check_launch_script()
    local result = {
        status = "unknown",
        message = "",
        details = {}
    }

    local launch_path = vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls/launch.sh")
    if vim.fn.filereadable(launch_path) == 1 then
        -- Try to run the script with -v to check version
        local handle = io.popen("bash " .. launch_path .. " -v 2>&1")
        if not handle then
            result.status = "error"
            result.message = "Failed to run launch script"
            return result
        end

        local output = handle:read("*a")
        handle:close()

        if output:match("command not found: elixir") then
            result.status = "error"
            result.message = "launch.sh can't find Elixir"
            result.details.output = output
        elseif output:match("ElixirLS") then
            result.status = "ok"
            result.message = "launch.sh works correctly"
        else
            result.status = "warning"
            result.message = "Unexpected output from launch.sh"
            result.details.output = output
        end
    else
        result.status = "not_found"
        result.message = "launch.sh not found at " .. launch_path
    end

    return result
end

-- Create a patched launch script
function M.create_patched_launch()
    local elixir_path = vim.fn.exepath("elixir")
    if elixir_path == "" then
        vim.notify("Cannot create patched launch script: Elixir not found in PATH", vim.log.levels.ERROR)
        return false
    end

    local elixir_dir = string.match(elixir_path, "(.+)/elixir$")
    if not elixir_dir then
        vim.notify("Cannot determine Elixir directory from " .. elixir_path, vim.log.levels.ERROR)
        return false
    end

    -- Read original launch script
    local orig_path = vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls/launch.sh")
    local file = io.open(orig_path, "r")
    if not file then
        vim.notify("Cannot read original launch.sh", vim.log.levels.ERROR)
        return false
    end

    local content = file:read("*a")
    file:close()

    -- Create patch directory if it doesn't exist
    local patch_dir = vim.fn.expand("~/.config/nvim/elixir_ls_patch")
    vim.fn.mkdir(patch_dir, "p")

    -- Create patched script
    local patched_path = patch_dir .. "/launch.sh"
    local out_file = io.open(patched_path, "w")
    if not out_file then
        vim.notify("Cannot write to " .. patched_path, vim.log.levels.ERROR)
        return false
    end

    -- Add export for PATH
    local patched_content = "#!/bin/bash\n\n# Patched by Neovim config\nexport PATH=\"" .. elixir_dir .. ":$PATH\"\n\n" .. content
    out_file:write(patched_content)
    out_file:close()

    -- Make executable
    os.execute("chmod +x " .. patched_path)

    vim.notify("Created patched launch script at " .. patched_path, vim.log.levels.INFO)
    return patched_path
end

-- Run all diagnostics
function M.run_all()
    local elixir = M.check_elixir()
    local elixirls = M.check_elixirls()
    local launch = M.check_launch_script()

    vim.api.nvim_echo({{"Elixir LSP Diagnostics:\n", "Title"}}, false, {})

    -- Elixir
    if elixir.status == "ok" then
        vim.api.nvim_echo({{"✓ ", "String"}, {"Elixir: ", "String"}, {elixir.message, "None"}}, false, {})
        vim.api.nvim_echo({{"  Path: ", "String"}, {elixir.path, "None"}}, false, {})
    else
        vim.api.nvim_echo({{"✗ ", "ErrorMsg"}, {"Elixir: ", "ErrorMsg"}, {elixir.message, "ErrorMsg"}}, false, {})
    end

    -- ElixirLS
    if elixirls.status == "ok" then
        vim.api.nvim_echo({{"✓ ", "String"}, {"ElixirLS: ", "String"}, {elixirls.message, "None"}}, false, {})
    elseif elixirls.status == "warning" then
        vim.api.nvim_echo({{"⚠ ", "WarningMsg"}, {"ElixirLS: ", "WarningMsg"}, {elixirls.message, "WarningMsg"}}, false, {})
    else
        vim.api.nvim_echo({{"✗ ", "ErrorMsg"}, {"ElixirLS: ", "ErrorMsg"}, {elixirls.message, "ErrorMsg"}}, false, {})
    end

    -- Launch.sh
    if launch.status == "ok" then
        vim.api.nvim_echo({{"✓ ", "String"}, {"Launch Script: ", "String"}, {launch.message, "None"}}, false, {})
    elseif launch.status == "warning" then
        vim.api.nvim_echo({{"⚠ ", "WarningMsg"}, {"Launch Script: ", "WarningMsg"}, {launch.message, "WarningMsg"}}, false, {})
    else
        vim.api.nvim_echo({{"✗ ", "ErrorMsg"}, {"Launch Script: ", "ErrorMsg"}, {launch.message, "ErrorMsg"}}, false, {})
    end

    -- Overall status
    vim.api.nvim_echo({{"", "None"}}, false, {})

    -- If any issues, suggest fixes
    if elixir.status ~= "ok" or elixirls.status ~= "ok" or launch.status ~= "ok" then
        vim.api.nvim_echo({{"Recommendations:", "Title"}}, false, {})

        if elixir.status ~= "ok" then
            vim.api.nvim_echo({{"• Make sure Elixir is installed and in your PATH", "None"}}, false, {})
            vim.api.nvim_echo({{"  Run: brew install elixir", "None"}}, false, {})
        end

        if elixirls.status ~= "ok" then
            vim.api.nvim_echo({{"• Reinstall ElixirLS using Mason", "None"}}, false, {})
            vim.api.nvim_echo({{"  Run: :MasonInstall elixirls", "None"}}, false, {})
        end

        if launch.status ~= "ok" then
            vim.api.nvim_echo({{"• Create a patched launch script", "None"}}, false, {})
            vim.api.nvim_echo({{"  Run: :ElixirLspPatch", "None"}}, false, {})
        end
    end
end

-- Setup function to add commands
function M.setup()
    vim.api.nvim_create_user_command("ElixirLspDiag", function()
        M.run_all()
    end, {})

    vim.api.nvim_create_user_command("ElixirLspPatch", function()
        local patched_path = M.create_patched_launch()
        if patched_path then
            -- Update lspconfig to use the patched script
            local lspconfig = require('lspconfig')
            lspconfig.elixirls.setup {
                cmd = { patched_path }
            }
            vim.notify("Updated LSP config to use patched script", vim.log.levels.INFO)
        end
    end, {})
end

return M
