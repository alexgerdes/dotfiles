require("githead"):setup()
require("full-border"):setup()
require("yaziline"):setup({
	separator_style = "liney",
})
require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})
