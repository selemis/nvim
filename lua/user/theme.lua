-- ~/.config/nvim/lua/user/theme.lua
local M = {}

function M.setup()
  -- Set your default theme
  vim.cmd.colorscheme "gruvbox"

  -- Add keymapping to cycle through themes
  vim.keymap.set("n", "<F5>", function()
    M.cycle_themes()
  end, { desc = "Cycle themes", silent = true })

end

-- List of themes to cycle through
M.themes = {
  "gruvbox",
  "catppuccin",
  "tokyonight",
  "kanagawa",
  "solarized",
}
M.current_theme = 1

function M.cycle_themes()
  M.current_theme = M.current_theme % #M.themes + 1
  local theme = M.themes[M.current_theme]

  -- Apply specific configuration for certain themes
  if theme == "catppuccin" then
    vim.g.catppuccin_flavour = "mocha"
  elseif theme == "tokyonight" then
    vim.g.tokyonight_style = "storm"
  end

  -- Try to set the colorscheme, fallback if it fails
  local success, err = pcall(vim.cmd.colorscheme, theme)
  if not success then
    vim.notify("Failed to set colorscheme " .. theme .. ": " .. err, vim.log.levels.ERROR)
    -- Try next theme
    M.cycle_themes()
    return
  end

  vim.notify("Theme: " .. theme, vim.log.levels.INFO)
end

return M

