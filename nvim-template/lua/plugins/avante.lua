if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
-- NOTE: I'm commenting this out temporarily from my mainline config until I find
-- the right ollama model to make this worth it.
return {
  "yetone/avante.nvim",
  cond = function()
    -- Try to connect to Ollama server
    local handle = io.popen "curl --silent --max-time 1 http://127.0.0.1:11434/api/tags"
    if not handle then return false end
    local result = handle:read "*a"
    handle:close()
    -- If result is not empty, assume Ollama is running
    return result ~= nil and result ~= ""
  end,
  event = "VeryLazy",
  build = "make",
  opts = {
    provider = "ollama", -- or "deepseek", "claude", etc.
    ollama = {
      model = "codegemma:7b", -- or your preferred model
      timeout = 30000,
      temperature = 0,
      max_tokens = 4096,
    },
    -- configure other providers as needed
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "MeanderingProgrammer/render-markdown.nvim",
    -- optional:
    "nvim-tree/nvim-web-devicons",
    "hrsh7th/nvim-cmp",
    "HakonHarnes/img-clip.nvim",
    "zbirenbaum/copilot.lua",
  },
}
