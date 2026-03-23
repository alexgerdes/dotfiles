require("githead"):setup()
require("full-border"):setup()
require("yaziline"):setup({
	color = "#89b4fa",
	secondary_color = "#6c7086",
	default_files_color = "#6c7086", -- color of the file counter when it's inactive
	selected_files_color = "#cdd6f4",
	yanked_files_color = "#94e2d5",
	cut_files_color = "#f38ba8",
	separator_style = "liney",
})
require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})
