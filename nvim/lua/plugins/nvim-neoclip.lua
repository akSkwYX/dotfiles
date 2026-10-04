-- Clipboard manager with preview using telescope
return {
   "AckslD/nvim-neoclip.lua",
   dependencies = {
      "nvim-telescope/telescope.nvim",
      {"kkharji/sqlite.lua", module = "sqlite"}
   },
   config = function()
      require("neoclip").setup()
   end,
}
