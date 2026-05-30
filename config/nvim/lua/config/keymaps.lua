-- Keymaps are automatically loaded on the VeryLazy event
-- Additions on top of LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ── Scrolling (keep cursor centered) ──────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- ── Search (keep match centered and unfold) ────────────────────────────────────
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- ── Clipboard ─────────────────────────────────────────────────────────────────
-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- Paste over visual selection without losing the register
map("x", "<leader>p", '"_dP', { desc = "Paste (preserve register)" })

-- Delete to void register (don't pollute " with deletions)
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to void" })

-- ── Search & replace word under cursor ────────────────────────────────────────
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- ── Make file executable ──────────────────────────────────────────────────────
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })

-- ── Disable Q (ex mode — almost always a misfire) ─────────────────────────────
map("n", "Q", "<nop>")

-- ── Join line without moving cursor ───────────────────────────────────────────
map("n", "J", "mzJ`z", { desc = "Join line (keep cursor)" })
