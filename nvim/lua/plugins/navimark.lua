-- Bookmark manager
return {
   "zongben/navimark.nvim",
   dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
   },
   config = function()
      require("navimark").setup()
   end,
}
