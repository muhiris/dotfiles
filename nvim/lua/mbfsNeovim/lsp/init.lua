local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "mbfsNeovim.lsp.lsp-installer"
require("mbfsNeovim.lsp.handlers").setup()
--require "user.lsp.null-ls"
