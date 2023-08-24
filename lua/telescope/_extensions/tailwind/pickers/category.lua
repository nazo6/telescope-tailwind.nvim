local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local categorized_data = require("telescope._extensions.tailwind.data.categorized")

local category_previewer = previewers.new_buffer_previewer({
	---@param entry {value: CategoryEntry}
	define_preview = function(self, entry)
		local bufnr = self.state.bufnr
		local lines = {}
		table.insert(lines, "# " .. entry.value.title)
		table.insert(lines, "")
		table.insert(lines, "- " .. entry.value.description)
		table.insert(lines, "")
		vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	end,
})

local item_picker = function(opts, entry)
	return pickers.new(opts, {
		prompt_title = "Search category item: " .. entry.value.title,
		sorter = sorters.get_generic_fuzzy_sorter(),
		previewer = previewers.new_buffer_previewer({
			---@param item_entry {value: CategorizedDataEntry}
			define_preview = function(self, item_entry)
				local bufnr = self.state.bufnr
				local lines = {}
				table.insert(lines, "# " .. entry.value.title)
				table.insert(lines, "")
				table.insert(lines, "- " .. entry.value.description)
				table.insert(lines, "")
				table.insert(lines, [[```css]])
				table.insert(lines, item_entry.value.class .. " {")
				for k, v in pairs(item_entry.value.value) do
					table.insert(lines, "  " .. k .. ": " .. v .. ";")
				end
				table.insert(lines, "}")
				table.insert(lines, [[```]])
				vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
			end,
		}),
		finder = finders.new_table({
			results = entry.value.utilities,
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
				---@type {value:CategorizedDataEntry}
				local item_entry = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				vim.fn.setreg("+", item_entry.value.class:sub(2))
			end)
			return true
		end,
	})
end

local item_previewer = function(title, description) end

return function(opts)
	pickers
		.new(opts, {
			prompt_title = "Search category",
			sorter = sorters.get_generic_fuzzy_sorter(),
			previewer = category_previewer,
			finder = finders.new_table({
				results = categorized_data,
				---@param entry CategoryEntry
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.title,
						ordinal = entry.title,
					}
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					item_picker(opts, entry):find()
				end)
				return true
			end,
		})
		:find()
end
