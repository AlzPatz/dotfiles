local opt = vim.opt

-- Editing
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true

-- Indentation defaults (filetype plugins may override these)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Navigation and display
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true

-- External changes (Claude Code, Git, etc.)
opt.autoread = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Responsiveness
opt.updatetime = 300
opt.timeoutlen = 400

-- Display LSP diagnostics directly in the editor
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = "●",
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
  underline = true,
  signs = true,
  severity_sort = true,
  update_in_insert = false,
})
