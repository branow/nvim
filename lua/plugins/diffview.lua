return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    {
      "<leader>gc",
      function()
        local commit = vim.fn.input("Commit: ")
        if commit ~= "" then
          vim.cmd("DiffviewOpen " .. commit .. "^.." .. commit)
        end
      end,
      desc = "Diffview: show a commit",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
  },
  config = function()
    require("diffview").setup({
      keymaps = {
        -- Free up <Tab>/<S-Tab> so the global double-Tab window-nav handler
        -- (see lua/vim-options.lua) works to switch between the file tree and diffs.
        view = {
          { "n", "<tab>", false },
          { "n", "<s-tab>", false },
        },
        file_panel = {
          { "n", "<tab>", false },
          { "n", "<s-tab>", false },
        },
        file_history_panel = {
          { "n", "<tab>", false },
          { "n", "<s-tab>", false },
        },
      },
    })
  end,
}
