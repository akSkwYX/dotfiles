return {
   {
      "neovim/nvim-lspconfig",
      config = function()
         vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})

         vim.lsp.enable("lua_ls")
         vim.lsp.enable("ocamllsp")
         vim.lsp.enable("clangd")
         vim.lsp.enable("java_language_server")
         vim.lsp.enable("hls")
         vim.lsp.enable("basedpyright")

         vim.diagnostic.config({
            virtual_text = { severity = { min = vim.diagnostic.INFO }, },
            underline = { severity = { min = vim.diagnostic.severity.INFO } },
            signs = { severity = { min = vim.diagnostic.severity.INFO } },
         })
      end,
   },
}
