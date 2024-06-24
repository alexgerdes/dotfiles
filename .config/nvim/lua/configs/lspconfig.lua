-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local util = lspconfig.util
local servers = { "html", "cssls", "pyre", "hls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- Haskell
lspconfig.hls.setup {
  root_dir = function(fname)
    return util.root_pattern("*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml")
      or util.path.dirname(fname)
  end,
}
