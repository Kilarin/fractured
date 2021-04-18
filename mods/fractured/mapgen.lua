--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_esem = minetest.get_content_id("fractured:stone_with_esem")



-- ESEM


minetest.register_ore({
	ore_type       = "scatter",
	ore            = "fractured:stone_with_esem",
	wherein        = "default:stone",
	clust_scarcity = 0.2*18*18*18,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "fractured:stone_with_esem",
	wherein        = "default:stone",
	clust_scarcity = 0.2*14*14*14,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "fractured:esem",
	wherein        = "default:stone",
	clust_scarcity = 0.2*36*36*36,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = -64,
	flags          = "absheight",
})

