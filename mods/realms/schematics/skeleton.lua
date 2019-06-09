
--golden tree schematic straight from ethereal healing tree

local _ = {name = "air", prob = 0}
local H = {name = "realms:skeleton_head", prob = 255}
local B = {name = "realms:skeleton_body", prob = 255}


bd_odd_biomes.skeleton = {

	size = {x = 1, y = 1, z = 2},

	yslice_prob = {
		{ypos = 0, prob = 255},
	},

	data = {

	B,H,

	}
}

