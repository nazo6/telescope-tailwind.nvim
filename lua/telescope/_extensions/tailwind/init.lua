local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")

local flat_data = require("telescope._extensions.tailwind.data.flat")

local flat_previewer = previewers.new_buffer_previewer({
	define_preview = function(self, entry)
		local bufnr = self.state.bufnr
		local lines = {}
		table.insert(lines, "# " .. entry.value.title)
		table.insert(lines, "")
		table.insert(lines, "- " .. entry.value.description)
		table.insert(lines, "")
		table.insert(lines, [[```css]])
		table.insert(lines, entry.value.class .. " {")
		for k, v in pairs(entry.value.value) do
			table.insert(lines, "  " .. k .. ": " .. v .. ";")
		end
		table.insert(lines, "}")
		table.insert(lines, [[```]])
		vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	end,
})

return require("telescope").register_extension({
	exports = {
		utility = function(opts)
			pickers
				.new(opts, {
					prompt_title = "Search by tailwind utility",
					sorter = sorters.get_generic_fuzzy_sorter(),
					previewer = flat_previewer,
					finder = finders.new_table({
						results = flat_data,
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.class,
								ordinal = entry.class,
							}
						end,
					}),
					attach_mappings = function(prompt_bufnr, map)
						return true
					end,
				})
				:find()
		end,
		css = function(opts)
			pickers
				.new(opts, {
					prompt_title = "Search by css property",
					sorter = sorters.get_generic_fuzzy_sorter(),
					previewer = flat_previewer,
					finder = finders.new_table({
						results = flat_data,
						entry_maker = function(entry)
							local properties = table.concat(vim.tbl_keys(entry.value), ", ")
							return {
								value = entry,
								display = entry.class .. " (" .. properties .. ")",
								ordinal = properties,
							}
						end,
					}),
					attach_mappings = function(prompt_bufnr, map)
						return true
					end,
				})
				:find()
		end,
	},
})
