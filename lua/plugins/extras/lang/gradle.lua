-- File: lua/lazyvim/plugins/extras/lang/gradle.lua
-- This configuration sets up the Gradle Language Server using nvim-lspconfig.
-- Adjust the executable path if you installed gradle-language-server somewhere nonstandard.

local gradle_filetypes = { "groovy", "gradle", "kts" } -- filetypes to trigger LSP

local function find_gradle_root(fname)
  return vim.fn.finddir("gradle", vim.fn.fnamemodify(fname, ":p:h") .. ";") ~= ""
    or vim.fn.findfile("settings.gradle", vim.fn.fnamemodify(fname, ":p:h") .. ";") ~= ""
    or vim.fn.findfile("settings.gradle.kts", vim.fn.fnamemodify(fname, ":p:h") .. ";") ~= ""
    or vim.fn.findfile("build.gradle", vim.fn.fnamemodify(fname, ":p:h") .. ";") ~= ""
    or vim.fn.findfile("build.gradle.kts", vim.fn.fnamemodify(fname, ":p:h") .. ";") ~= ""
      and vim.fn.fnamemodify(fname, ":p:h")
end

return {
  -- Add support to Treesitter if desired:
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "groovy" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gradle_lsp = {}, -- name this as you like; not official, so we’ll use a custom name.
      },
      setup = {
        gradle_lsp = function(server, opts)
          -- Return false if you want the default lspconfig setup to run as normal.
          return false
        end,
      },
    },
  },
  {
    "your-user/gradle-lsp",
    ft = gradle_filetypes,
    -- You can instead place this configuration under the nvim-lspconfig settings,
    -- but here we separate it similar to LazyVim extras.
    opts = function()
      -- Path to your gradle-language-server; adjust if necessary:
      local gradle_ls_path = vim.fn.exepath("gradle-language-server")
      if gradle_ls_path == "" then
        vim.notify("gradle-language-server not found in PATH", vim.log.levels.WARN)
        return {}
      end

      return {
        -- Command to start the language server:
        cmd = { gradle_ls_path },
        -- Define root_dir using our custom finder:
        root_dir = function(fname)
          return find_gradle_root(fname)
        end,
        -- (Optional) Additional settings if supported by gradle-language-server:
        settings = {
          gradle = {
            -- Example setting, adjust based on your needs and the server docs:
            buildCache = true,
          },
        },
        -- If you have any capabilities to pass from cmp-nvim-lsp:
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      }
    end,
    config = function(_, opts)
      -- Delay load nvim-lspconfig since this server only applies for specific filetypes.
      local lspconfig = require("lspconfig")
      lspconfig.gradle_lsp = {
        default_config = vim.tbl_deep_extend("force", lspconfig.util.default_config, opts),
      }
      -- Create an autocommand to attach the server to matching files.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = gradle_filetypes,
        callback = function(args)
          local bufnr = args.buf
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local root = opts.root_dir(fname)
          if not root or root == "" then
            vim.notify("Could not detect Gradle project root", vim.log.levels.WARN)
            return
          end
          -- Start or attach the LSP using lspconfig; the server name is `gradle_lsp`
          lspconfig.gradle_lsp.setup({}) -- Use the default configuration
          vim.lsp.buf_attach_client(bufnr, vim.lsp.get_clients({ name = "gradle_lsp" })[1].id)
        end,
      })
    end,
  },
}
