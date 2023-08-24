local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local previewer = require("telescope._extensions.tailwind.previewer")

---@type FlatDataEntry[]
local flat_data = require("telescope._extensions.tailwind.data.flat")

return function(opts)
	pickers
		.new(opts, {
			prompt_title = "Search by tailwind utility",
			sorter = sorters.get_generic_fuzzy_sorter(),
			previewer = previewer.item_previewer,
			finder = finders.new_table({
				results = flat_data,
				---@param entry FlatDataEntry
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.class,
						ordinal = entry.class,
					}
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					vim.fn.setreg("+", entry.value.class:sub(2))
				end)
				return true
			end,
		})
		:find()
end
