return {
  -- Rose Pine — ThePrimeagen's preferred colorscheme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "main", -- "main" | "moon" | "dawn"
      dark_variant = "main",
      styles = {
        transparency = false,
      },
    },
  },

  -- Set rose-pine as the active colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
