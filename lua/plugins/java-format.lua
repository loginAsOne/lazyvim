return {
  "mfussenegger/nvim-jdtls",
  opts = {
    jdtls = function(opts)
      opts.settings = {
        java = {
          format = {
            enabled = true,
            settings = {
              url = vim.fn.expand("~/.config/nvim/eclipse-intellij-default-style.xml"),
              profile = "IntelliJDefault",
            },
          },
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
        },
      }

      return opts
    end,
  },
  -- opts = function(_, opts)
  --   local jdtls = require("jdtls")
  --
  --   -- Inject custom formatting options
  --   opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
  --     java = {
  --       format = {
  --         enabled = true,
  --         settings = {
  --           -- url = "file://" .. vim.fn.stdpath("config") .. "/intellij-java-style.xml",
  --           url = vim.fn.expand("~/.config/nvim/eclipse-intellij-default-style.xmle"),
  --           profile = "IntelliJDefault",
  --         },
  --       },
  --       inlayHints = {
  --         parameterNames = {
  --           enabled = "all",
  --         },
  --       },
  --     },
  --   })
  -- end,
}
