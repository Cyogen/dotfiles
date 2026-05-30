return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- <leader>pv = "project view" — ThePrimeagen's classic binding, now opens oil
    keys = {
      { "<leader>pv", "<cmd>Oil<cr>", desc = "Oil file browser" },
    },
    opts = {
      -- Edit files like a buffer — save writes, delete removes, etc.
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true, -- show dotfiles
      },
      -- Keymaps inside the oil buffer
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-x>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
    },
  },
}
