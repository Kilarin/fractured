minetest.register_node("realms:layer_barrier", 
{
	description = "Layer Barrier",
	drawtype = "airlike",
	drop = "",
	groups = {unbreakable = 1, not_in_creative_inventory = 1},
	is_ground_content = false,
	sunlight_propagates = true,	
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("realms:bedrock", {
	description = "Bedrock",
	tiles = {"bedrock.png"},
	groups = {immortal=1, not_in_creative_inventory=1, },
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	on_blast = function() end,
	on_destruct = function () end,
	can_dig = function() return false end,
	diggable = false,
	drop = "",
})
