-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- Check if the buffer's shiftwidth is not already set to 4
    if vim.bo.shiftwidth ~= 4 then
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.softtabstop = 4
      vim.bo.expandtab = true
    end
  end,
})

local diagnostics_active = true

function ToggleDiagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
  else
    vim.diagnostic.enable(false)
  end
end

vim.api.nvim_create_user_command("ToggleDiagnostics", function() ToggleDiagnostics() end, {})

require("toggleterm").setup {
  open_mapping = [[<leader>tt]],
  insert_mappings = false, -- Whether to enable mappings in insert mode
  terminal_mappings = false, -- Whether to enable mappings in terminal mode
  direction = "float", -- Set to "horizontal", "vertical", or "tab" as needed
  size = 20, -- Size of the terminal window
  shade_filetypes = {},
  autochdir = true, -- Terminal will change directory when Neovim does
  float_opts = {
    border = "curved",
    width = 100,
    height = 30,
  },
}

-- TODO: figure out how to make this only work on python--
-- OR figure out how to make it add the ignore syntax for linter / formatter comment for each type (ex. cpp and python) --
vim.keymap.set("n", "<leader>ti", "A # type: ignore<Esc>", { desc = "Add type ignore" })

--NOTE: make vim always paste from clipboard register--
vim.o.clipboard = "unnamedplus"
vim.keymap.set({ "n", "v" }, "p", '"+p')
vim.keymap.set({ "n", "v" }, "P", '"+P')
vim.keymap.set("x", "p", '"_dP', { noremap = true })
