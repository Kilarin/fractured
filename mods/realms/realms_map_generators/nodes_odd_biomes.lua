--[[
This defines the nodes used by bd_basic_biomes.lua
--]]

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  S = intllib.Getter()
else
  S = function ( s ) return s end
end



-- frost tree leaves
minetest.register_node("realms:frost_leaves", {
	description = S("Frost Leaves"),
	drawtype = "plantlike",
	visual_scale = 1.4,
	tiles = {"ethereal_frost_leaves.png"},
	inventory_image = "ethereal_frost_leaves.png",
	wield_image = "ethereal_frost_leaves.png",
	paramtype = "light",
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, puts_out_fire = 1},
	light_source = 9,
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})

-- frost trunk
minetest.register_node("realms:frost_tree", {
	description = S("Frost Tree"),
	tiles = {
		"ethereal_frost_tree_top.png",
		"ethereal_frost_tree_top.png",
		"ethereal_frost_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, put_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})

-- frost wood
minetest.register_node("realms:frost_wood", {
	description = S("Frost Wood"),
	tiles = {"frost_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, put_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("realms:crystal_dirt_with_grass", {
	description = S("Crystal Dirt"),
	tiles = {
		"ethereal_grass_crystal_top.png",
		"default_dirt.png",
		{name = "default_dirt.png^ethereal_grass_crystal_side.png",
				tileable_vertical = false}
	},
	is_ground_content = true,
	groups = {crumbly = 3, soil = 1},
	--drop = "realms:crystal_dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})




-- Crystal Shrub (not Flammable - too cold to burn)
minetest.register_node("realms:crystal_grass", {
	description = S("Crystal Grass"),
	drawtype = "plantlike",
	visual_scale = 0.9,
	tiles = {"ethereal_crystalgrass.png"},
	inventory_image = "ethereal_crystalgrass.png",
	wield_image = "ethereal_crystalgrass.png",
	paramtype = "light",
	sunlight_propagates = true,
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-5 / 16, -0.5, -5 / 16, 5 / 16, 5 / 16, 5 / 16},
	},
})

------------------------------------------------------------------------------------------

--mushroom dirt with "grass"
minetest.register_node("realms:mushroom_moss", {
	description = S("Mushroom Moss"),
	tiles = {"ethereal_grass_mushroom_top.png"},
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.4}})
})

-- mushroom trunk
minetest.register_node("realms:mushroom_trunk", {
	description = S("Mushroom"),
	tiles = {
		"mushroom_trunk_top.png",
		"mushroom_trunk_top.png",
		"mushroom_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})


-- mushroom pore (spongelike material found inside giant shrooms)
minetest.register_node("realms:mushroom_pore", {
	description = S("Mushroom Pore"),
	tiles = {"mushroom_pore.png"},
	groups = {
		snappy = 3, cracky = 3, choppy = 3, oddly_breakable_by_hand = 3,
		flammable = 2, disable_jump = 1, fall_damage_add_percent = -100
	},
	sounds = default.node_sound_dirt_defaults(),
})

-- mushroom tops
minetest.register_node("realms:mushroom_cap", {
	description = S("Mushroom Cap"),
	tiles = {"mushroom_block.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
--	drop = {
--		max_items = 1,
--		items = {
--			{items = {"ethereal:mushroom_sapling"}, rarity = 20},
--			{items = {"ethereal:mushroom"}}
--		}
--	},
	sounds = default.node_sound_wood_defaults(),
})


------------------------------------------------

minetest.register_node("realms:dry_dirt", {
	description = S("Dried Dirt"),
	tiles = {"ethereal_dry_dirt.png"},
	is_ground_content = true,
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults()
})

-- scorched trunk
minetest.register_node("realms:scorched_trunk", {
	description = S("Scorched Tree"),
	tiles = {
		"scorched_tree_top.png",
		"scorched_tree_top.png",
		"scorched_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})


--------------------------------------------------------


minetest.register_node("realms:golden_grass_1", {
	description = "Golden Grass",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"realms_golden_grass_1.png"},
	inventory_image = "realms_golden_grass_3.png",
	wield_image = "realms_golden_grass_3.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flammable = 3, flora = 1,
		attached_node = 1, dry_grass = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -3 / 16, 6 / 16},
	},

	on_place = function(itemstack, placer, pointed_thing)
		-- place a random dry grass node
		local stack = ItemStack("realms:golden_grass_" .. math.random(1, 5))
		local ret = minetest.item_place(stack, placer, pointed_thing)
		return ItemStack("realms:golden_grass_1 " ..
			itemstack:get_count() - (1 - ret:get_count()))
	end,
})

for i = 2, 5 do
	minetest.register_node("realms:golden_grass_" .. i, {
		description = "Dry Grass",
		drawtype = "plantlike",
		waving = 1,
		tiles = {"realms_golden_grass_" .. i .. ".png"},
		inventory_image = "realms_golden_grass_" .. i .. ".png",
		wield_image = "realms_golden_grass_" .. i .. ".png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1,
			not_in_creative_inventory=1, dry_grass = 1},
		drop = "realms:golden_grass_1",
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -1 / 16, 6 / 16},
		},
	})
end


minetest.register_node("realms:dirt_with_golden_grass", {
	description = "Dirt with Golden Grass",
	tiles = {"realms_golden_grass_top.png",
		"default_dirt.png",
		{name = "default_dirt.png^realms_golden_grass_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	--drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.4},
	}),
})

minetest.register_node("realms:golden_trunk", {
	description = S("Golden Tree Trunk"),
	tiles = {
		"golden_tree_top.png",
		"golden_tree_top.png",
		"golden_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, put_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})




minetest.register_node("realms:golden_wood", {
	description = S("Golden Tree Wood"),
	tiles = {"golden_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, put_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("realms:goldenleaves", {
	description = S("Golden Tree Leaves"),
	drawtype = "plantlike",
	visual_scale = 1.4,
	tiles = {"golden_leaves.png"},
	inventory_image = "golden_leaves.png",
	wield_image = "golden_leaves.png",
	paramtype = "light",
	--walkable = ethereal.leafwalk,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			--{items = {"realms:golden_tree_sapling"}, rarity = 50},
			{items = {"realms:goldenleaves"}}
		}
	},
	-- one leaf heals half a heart when eaten
	on_use = minetest.item_eat(1),
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
	light_source = 9,
})



-- Golden Apple (Found on golden Tree, heals all 10 hearts)
minetest.register_node("realms:golden_apple", {
	description = S("Golden Apple"),
	drawtype = "plantlike",
	tiles = {"realms_apple_gold.png"},
	inventory_image = "realms_apple_gold.png",
	wield_image = "realms_apple_gold.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.37, -0.2, 0.2, 0.31, 0.2}
	},
	groups = {
		fleshy = 3, dig_immediate = 3,
		leafdecay = 3,leafdecay_drop = 1
	},
	drop = "realms:golden_apple",
--	on_use = minetest.item_eat(20),
	on_use = function(itemstack, user, pointed_thing)
		if user then
			user:set_hp(20)
			return minetest.do_item_eat(2, nil, itemstack, user, pointed_thing)
		end
	end,
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = function(pos, placer, itemstack)
		if placer:is_player() then
			minetest.set_node(pos, {name = "realms:golden_apple", param2 = 1})
		end
	end,
})

--------------------------------------

minetest.register_node("realms:dirt_with_gray_grass", {
	description = "Dirt with Grey Grass",
	tiles = {"ethereal_grass_gray_top.png",
		"default_dirt.png",
		{name = "default_dirt.png^ethereal_grass_gray_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	--drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.4},
	}),
})

minetest.register_node("realms:rainbow_willow_trunk", {
	description = S("Rainbow Willow Trunk"),
	tiles = {
		"rainbow_willow_trunk_top.png",
		"rainbow_willow_trunk_top.png",
		"rainbow_willow_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, put_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})



--[[ gotta set this up
minetest.register_node("realms:golden_wood", {
	description = S("Golden Tree Wood"),
	tiles = {"golden_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, put_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),

})
--]]


minetest.register_node("realms:rainbow_willow_leaves", {
	description = S("Rainbow Willow Leaves"),
	drawtype = "plantlike",
	tiles = {"rainbow_willow_leaves.png"},
	inventory_image = "rainbow_willow_leaves.png",
	wield_image = "rainbow_willow_leaves.png",
	paramtype = "light",
--	walkable = ethereal.leafwalk,
	visual_scale = 1.4,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
--			{items = {"ethereal:willow_sapling"}, rarity = 50},
			{items = {"realms:rainbow_willow_leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})


-- rainbow bush
minetest.register_node("realms:rainbow_bush", {
	description = S("Rainbow Bush"),
	drawtype = "plantlike",
	visual_scale = 1.2,
	tiles = {"rainbow_bush.png"},
	inventory_image = "rainbow_bush.png",
	wield_image = "rainbow_bush.png",
	paramtype = "light",
	sunlight_propagates = true,
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-5 / 16, -0.5, -5 / 16, 5 / 16, 5 / 16, 5 / 16},
	},
})

