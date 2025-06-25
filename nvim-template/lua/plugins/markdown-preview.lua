return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
  init = function()
    vim.g.mkdp_theme = "dark"
    -- Optional: Configure auto-refresh
    vim.g.mkdp_refresh_slow = 0
    -- Optional: Configure browser
    -- vim.g.mkdp_browser = "firefox"
    -- Optional: Configure port
    -- vim.g.mkdp_port = "8888"
    -- Optional: Configure preview window position
    -- vim.g.mkdp_preview_options = {
    --   position = "tab"
    -- }
  end,
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Open Markdown Preview" },
    { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Markdown Preview" },
    { "<leader>mt", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
  },
}
