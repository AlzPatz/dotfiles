return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.install({
        "c_sharp",
        "lua",
        "json",
        "xml",
        "bash",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cs", "lua", "json", "xml", "sh" },
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if not ok then
            -- Fall back to Neovim's regular syntax highlighting.
            vim.bo[args.buf].syntax = "on"
          end
        end,
      })
    end,
  },
}
