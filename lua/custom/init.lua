opts = {
  number = false,
  wrap = false,

  guifont = "JetBrainsMono Nerd Font:h8",

  ruler = true,
  laststatus = 2,

  list = true,
  listchars = 'tab:→\\ ,nbsp:␣,trail:•,precedes:«,extends:»',

  tw = 80,
  colorcolumn = "81",
  backspace = "indent,eol,start",
  expandtab = true,
  autoindent = true,
  smartindent = true,
  tabstop = 4,
  shiftwidth = 4,

  formatoptions = "croql",
}

for n, v in pairs(opts) do
  vim.opt[n] = v
end

local autocmd = vim.api.nvim_create_autocmd

function runstatusline(active)
  local modules = require "nvchad.statusline.default"
  if config.overriden_modules then
    modules = vim.tbl_deep_extend("force", modules, config.overriden_modules())
  end
  if active then
    return modules.run()
  else
    return table.concat {
      modules.fileInfo(),
      modules.git(),
      "%=",
      modules.cwd(),
      modules.cursor_position(),
    }
  end
end

autocmd("BufWritePre", {
  pattern = '*',
  command = ':%s/\\s\\+$//e',
})

autocmd({ "WinEnter", "BufRead" }, {
  callback = function()
    vim.opt.statusline = ""
    --vim.opt_local.statusline = "%!v:lua.require('nvchad_ui.statusline.default').run(true)"
    vim.opt_local.statusline = "%!v:lua.runstatusline(v:true)"
  end,
})


autocmd("WinLeave", {
  callback = function()
    vim.opt.statusline = ""
    vim.opt_local.statusline = runstatusline(false)
  end,
})

autocmd("FileType", {
  pattern = { "xml", "nix", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.config({ virtual_text = false, })
    if not vim.diagnostic.is_disabled() then
      vim.diagnostic.open_float({
        focusable = false,
      })
    end
  end,
})

vim.cmd("let g:netrw_liststyle= 3")
