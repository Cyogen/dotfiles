-- Options are automatically loaded before lazy.nvim startup
-- Overrides/additions on top of LazyVim defaults

local opt = vim.opt

-- Keep cursor vertically centered with more context
opt.scrolloff = 8

-- Faster CursorHold events (used by LSP hover, gitsigns, etc.)
opt.updatetime = 50

-- No swap or backup — undofile handles history
opt.swapfile = false
opt.backup = false

-- Persistent undo across sessions
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.fn.mkdir(vim.fn.expand("~/.vim/undodir"), "p")

-- Column guide at 80 chars
opt.colorcolumn = "80"

-- Keep sign column always open so diagnostics don't shift text
opt.signcolumn = "yes"

-- Show whitespace characters
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
