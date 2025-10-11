return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = {
          "lua_ls",
          "vtsls",
          "cssls",
          "clangd",
          "gopls",
          "dockerls",
          "jdtls",
          "kotlin_language_server",
          "sqls",
          "jsonls",
          "pylsp",
          "intelephense",
        }
      })
    end
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "java-debug-adapter", "java-test" }
      })
    end
  },
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local function setup_jdtls()
        local home = os.getenv("HOME")
        local workspace_path = home .. "/code/workspace/"
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = workspace_path .. project_name

        local jdtls = require("jdtls")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local config = {
          cmd = {
            "java",
            "-javaagent:" .. home .. "/.local/share/lombok/lombok.jar",
            "-Xmx2G",
            "-XX:+UseG1GC",
            "-XX:+UseStringDeduplication",
            "-jar", vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
            "-configuration", home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
            "-data", workspace_dir,
          },
          root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
          capabilities = capabilities,
          on_init = function(client)
            client.server_capabilities.semanticTokensProvider = nil
          end,
        }

        jdtls.start_or_attach(config)
      end

      vim.filetype.add({
        extension = {
          drl = "java",
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = setup_jdtls,
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.vtsls.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.clangd.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.sqls.setup({ capabilities = capabilities })
      lspconfig.dockerls.setup({ capabilities = capabilities })
      lspconfig.jsonls.setup({ capabilities = capabilities })
      lspconfig.pylsp.setup({ capabilities = capabilities })
      lspconfig.intelephense.setup({ capabilities = capabilities })
      lspconfig.kotlin_language_server.setup({
        capabilities = capabilities,
        cmd_env = {
          KOTLIN_LANGUAGE_SERVER_OPTS = "-Xms512m -Xmx3g -XX:+UseG1GC -XX:+UseStringDeduplication",
          MAVEN_OPTS = "-Xms512m -Xmx2g -XX:+UseG1GC",
        },
        root_dir = lspconfig.util.root_pattern(
          "settings.gradle", "settings.gradle.kts",
          "build.gradle", "build.gradle.kts",
          "pom.xml", ".git"
        ),
      })

      vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>cD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', '<leader>ci', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', '<leader>cs', vim.lsp.buf.signature_help, {})
      vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>cf', vim.lsp.buf.references, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})

    end
  }
}
