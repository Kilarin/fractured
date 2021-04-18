

-- Dry Dirt  (copied from ethereal)
minetest.register_node("fractured:dry_dirt", {
	description = "Dried Dirt",
	tiles = {"ethereal_dry_dirt.png"},
	is_ground_content = false,
	groups = {crumbly=3} --,
	--sounds = default.node_sound_dirt_defaults()
})


-- scorched trunk  copied from ethereal
minetest.register_node("fractured:scorched_tree", {
	description = "Scorched Tree",
	tiles = {
		"scorched_tree_top.png",
		"scorched_tree_top.png",
		"scorched_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 1},
	--sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})


minetest.register_node("fractured:stone_with_esem", {
	description = "Esem Ore",
	tiles = {"default_stone.png^fractured_mineral_esem.png"},
	is_ground_content = true,
	groups = {cracky=1},
	drop = "fractured:esem_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("fractured:esem", {
	description = "Esem Block",
	tiles = {"fractured_esem_block.png"},
	is_ground_content = true,
	groups = {cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_alias("fractured:esem_block", "fractured:esem")
