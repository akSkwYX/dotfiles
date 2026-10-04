return {
   "akSkwYX/vankim.nvim",
   keys = {
      { "<leader>an", "<cmd>AnkiNew<cr>", desc = "Anki: New Note" },
      { "<leader>as", "<cmd>AnkiSend true<cr>", desc = "Anki: Send Note" },
      { "<leader>aj", "<cmd>AnkiJump next<cr>", desc = "Anki: Jump to next field" },
      { "<leader>ak", "<cmd>AnkiJump previous<cr>", desc = "Anki: Jump to previous field" },
      { "<leader>ab", "<cmd>AnkiJump beginning<cr>", desc = "Anki: Move to begining of field" },
      { "<leader>ae", "<cmd>AnkiJump end<cr>", desc = "Anki: Move to end of field" },
      { "<leader>am", "<cmd>AnkiModel<cr>", desc = "Anki: Select Model" },
      { "<leader>ad", "<cmd>AnkiDeck<cr>", desc = "Anki: Select Deck" },
      { "<leader>app", "<cmd>AnkiPreamble<cr>", desc = "Anki: Edit Preamble" },
      { "<leader>apn", "<cmd>AnkiPreambleAdd<cr>", desc = "Anki: Add to Preamble" },
      { "<leader>apd", "<cmd>AnkiPreambleDelete<cr>", desc = "Anki: Delete Preamble" },
      { "<leader>at", "<cmd>AnkiTags typst<cr>", desc = "Anki: Add Typst Tags" },
      { "<leader>al", "<cmd>AnkiTags latex<cr>", desc = "Anki: Add LaTeX Tags" },
   },
   config = function()
      require("vankim.vankim").setup({})
   end,
}
