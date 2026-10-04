return {
   -- Tree-Sitter
	"nvim-treesitter/nvim-treesitter", branch="main", build = ":TSUpdate",

   -- Configure Treesitter
   config = function()
      local config = require("nvim-treesitter.config")
      config.setup({
         auto_install = true,
         highlight = { enable = true },
         indent = { enable = true },
      })
   end,
}
