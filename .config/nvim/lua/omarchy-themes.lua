-- Extra colorschemes available on omarchy for theme switching.
-- On macOS this returns an empty table (no extra themes loaded).
if vim.fn.isdirectory(vim.fn.expand("~/.local/share/omarchy")) == 0 then
  return {}
end

local repos = {
  "ribru17/bamboo.nvim",
  "sainnhe/everforest",
  "kepano/flexoki-neovim",
  "ellisonleao/gruvbox.nvim",
  "rebelot/kanagawa.nvim",
  "loctvl842/monokai-pro.nvim",
  "shaunsingh/nord.nvim",
  { "rose-pine/neovim", name = "rose-pine" },
  "folke/tokyonight.nvim",
}

return vim.tbl_map(function(repo)
  if type(repo) == "string" then
    return { repo, lazy = true, priority = 1000 }
  end
  return vim.tbl_extend("force", repo, { lazy = true, priority = 1000 })
end, repos)
