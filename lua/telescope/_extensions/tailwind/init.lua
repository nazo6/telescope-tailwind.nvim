---@class FlatDataEntry
---@field class string
---@field description string
---@field value table<string, string>
---@field title string

---@class CategorizedDataEntry
---@field class string
---@field value table<string, string>

---@class CategoryEntry
---@field title string
---@field description string
---@field utilities CategorizedDataEntry[]

return require("telescope").register_extension({
	exports = {
		utility = require("telescope._extensions.tailwind.pickers.utility"),
		css = require("telescope._extensions.tailwind.pickers.css"),
		category = require("telescope._extensions.tailwind.pickers.category"),
	},
})
