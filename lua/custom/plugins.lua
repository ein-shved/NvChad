local plugins =  {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- defaults
        "vim",
        "lua",
        "bash",

        "json",

        "c",
        "cpp",
        "python",
        "nix",
        "rust",
      },
    },
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    opts = function(_, opts)
      config = require('session_manager.config')
      return {
        autoload_mode = config.AutoloadMode.CurrentDir,
        autosave_last_session = true,
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
     config = function()
        require "plugins.configs.lspconfig"
        require "custom.configs.lspconfig"
     end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
  {
    "prichrd/netrw.nvim",
    lazy = false,
    opts = {
         use_devicons = true,
    }
  },
  {
    "f-person/git-blame.nvim",
    lazy = false
  },
  {
    "simrat39/rust-tools.nvim",
  },
  {
  'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  }
}

return plugins
