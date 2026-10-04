return {
   "NeogitOrg/neogit",
   lazy = true,
   dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",

      "nvim-telescope/telescope.nvim",
   },
   cmd = "Neogit",
   keys = {
      { "<leader>gi", "<cmd>Neogit<cr>", desc = "Neogit" },
   }
}
