local lspconfig = require("lspconfig")
local telescope = require("telescope.builtin")

local function org_imports()
	local params = vim.lsp.util.make_range_params()
	params.context = { only = { "source.organizeImports" } }
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
	for _, res in pairs(result or {}) do
		for _, r in pairs(res.result or {}) do
			if r.edit then
				vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
			else
				vim.lsp.buf.execute_command(r.command)
			end
		end
	end
end

local get_on_attach = function(settings)
	return function(client, bufnr)
		local callback = nil

		client.server_capabilities.documentFormattingProvider = settings.format

		if settings.format and settings.org_imports then
			callback = function()
				vim.lsp.buf.formatting_sync()
				org_imports()
			end
		elseif settings.format and not settings.org_imports then
			callback = vim.lsp.buf.formatting_sync
		elseif not settings.format and settings.org_imports then
			callback = org_imports
		end

		if callback ~= nil then
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "<buffer>",
				callback = callback,
			})
		end

		-- Prevent LSP preview window from opening on omnifunc
		vim.cmd("set completeopt-=preview")

		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

		local opts = { buffer = 0 } -- use current buffer
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>d", function()
			telescope.diagnostics({ bufnr = 0 }) -- show diagnostics only for current buffer
		end, opts)
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>i", telescope.lsp_implementations, opts)
		vim.keymap.set("n", "<leader>n", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>r", telescope.lsp_references, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	end
end

local on_attach_format_orgimports = get_on_attach({ format = true, org_imports = true })
local on_attach_format = get_on_attach({ format = true, org_imports = false })
local on_attach_org_imports = get_on_attach({ format = false, org_imports = true })
local on_attach = get_on_attach({ format = false, org_imports = false })

local servers = {
	gopls = {
		on_attach = on_attach_format_orgimports,
		settings = { gopls = { gofumpt = true, staticcheck = true } },
	},
	pyright = { on_attach = on_attach },
	rnix = { on_attach = on_attach_format },
	rust_analyzer = { on_attach = on_attach_format },
	tsserver = { on_attach = on_attach_org_imports },
	zls = { on_attach = on_attach_format },
}
vim.g.zig_fmt_autosave = 0

local sumneko_root_path = os.getenv("SUMNEKO_ROOT_PATH")
if sumneko_root_path ~= nil then
	servers["sumneko_lua"] = {
		cmd = {
			sumneko_root_path .. "/bin/lua-language-server",
			"-E",
			sumneko_root_path .. "/extras/main.lua",
		},
		on_attach = on_attach_format,
		settings = { Lua = { diagnostics = { globals = { "vim" } } } },
		telemetry = { enable = false },
	}
end

for lsp, settings in pairs(servers) do
	lspconfig[lsp].setup(settings)
end

lspconfig.efm.setup({
	on_attach = on_attach_format,
	filetypes = { "json", "python", "sh" },
	init_options = { documentFormatting = true },
	settings = {
		languages = {
			json = {
				{ formatCommand = "jq .", formatStdin = true },
			},
			python = {
				{ formatCommand = "black --quiet -", formatStdin = true },
				{ formatCommand = "isort --quiet -", formatStdin = true },
			},
			sh = {
				{ formatCommand = "shfmt -ci -s -bn", formatStdin = true },
				{
					lintCommand = "shellcheck --color=never --format=gcc --external-sources -",
					prefix = "shellcheck",
					lintStdin = true,
					lintFormats = { "%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m", "%f:%l:%c: %tote: %m" },
				},
			},
		},
	},
})
