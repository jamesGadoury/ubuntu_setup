return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, for filetype icons
  },
  config = function()
    -- Enable true color support if not already set
    vim.opt.termguicolors = true

    require("bufferline").setup {
      options = {
        -- Example: hide unnamed ("[No Name]") buffers from the bufferline
        custom_filter = function(bufnr) return vim.fn.bufname(bufnr) ~= "" end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        -- Add any other options you want here
      },
    }
  end,
}
