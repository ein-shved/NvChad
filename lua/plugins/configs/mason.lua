local options = {
  ensure_installed = { "lua-language-server" }, -- not an option from mason.nvim

  PATH = "skip",

  ui = {
    icons = {
      package_pending = " ",
      package_installed = "󰄳 ",
      package_uninstalled = " 󰚌",
    },

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  max_concurrent_installers = 10,
  stub = function()
    package.loaded["mason"] = {}
    package.loaded["mason-registry"] = {
      on = function(self, event, foo)
        foo({ name = "" })
      end
    }
    vim.g.mason_binaries_list = {}
    local function quiet_stub()
    end
    local function stub()
      print("Mason was disabled")
    end
    vim.api.nvim_create_user_command("Mason", stub, {})
    vim.api.nvim_create_user_command("MasonInstall", quiet_stub, {})
    vim.api.nvim_create_user_command("MasonInstallAll", quiet_stub, {})
    vim.api.nvim_create_user_command("MasonUninstall", quiet_stub, {})
    vim.api.nvim_create_user_command("MasonUninstallAll", quiet_stub, {})
    vim.api.nvim_create_user_command("MasonLog", stub, {})
  end
}

return options
