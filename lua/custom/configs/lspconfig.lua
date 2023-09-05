local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = {
  "html",
  "cssls",
  "tsserver",
  "clangd",
  "lua_ls",
  "rnix",
  "rust_analyzer",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = function ()
      on_attach()
    end,
    capabilities = capabilities,
  }
end

lspconfig.clangd.setup {
  cmd = { 'clangd', '-j=8',
          '--query-driver=/home/shved/kl/**/*,/nix/store/**/*,*',
          '--header-insertion=never'
  },
}

lspconfig.lua_ls.setup {
  cmd = { 'lua-language-server' },
}

lspconfig.rust_analyzer.setup {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true;
      }
    }
  }
}
