return {
  "AnkushRoy-code/scribble.nvim",
  config = function ()
    local scribble = require("scribble")
    scribble.setup({
      pos = "center"
    })

    vim.keymap.set("n", "<C-l>", scribble.toggle, {desc = "Toggle Scribble"})
    vim.keymap.set("n", "<leader>sl", scribble.find, {desc = "Fuzzy find scribble pads"})
  end
}
