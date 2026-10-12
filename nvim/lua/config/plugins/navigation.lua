return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        position = "left",
        width = 32,
      },
    },
    keys = {
      {
        "<C-n>",
        "<cmd>Neotree toggle filesystem left<CR>",
        desc = "Toggle file explorer",
      },
    },
  },
  {
	  "nvim-telescope/telescope.nvim",
	  dependencies = {
	    "nvim-lua/plenary.nvim",
	  },
	  keys = {
	    {
	      "<leader>ff",
	      "<cmd>Telescope find_files<CR>",
	      desc = "Find files",
	    },
	    {
	      "<leader>fg",
	      "<cmd>Telescope live_grep<CR>",
	      desc = "Search text in project",
	    },
	    {
	      "<leader>fb",
	      "<cmd>Telescope buffers<CR>",
	      desc = "Find open buffers",
	    },
	    {
	      "<leader>fh",
	      "<cmd>Telescope help_tags<CR>",
	      desc = "Search help",
	    },
	  },
	},
}
