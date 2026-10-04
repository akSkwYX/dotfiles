return {
   "m4xshen/autoclose.nvim",
   config = function ()
      require("autoclose").setup({
         keys = {
            ["("] = { escape = true, close = true, pair = "()" },
            ["{"] = { escape = true, close = true, pair = "{}" },
            ["["] = { escape = true, close = true, pair = "[]" },
            ['"'] = { escape = true, close = true, pair = '""' },
            ["'"] = { escape = false, close = false, pair = "''" },
            ["`"] = { escape = false, close = false, pair = "``" },
         },
      })
   end
}
