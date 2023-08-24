local previewers = require("telescope.previewers")

return {
	item_previewer = previewers.new_buffer_previewer({
		---@param entry {value: FlatDataEntry}
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
	}),
}
