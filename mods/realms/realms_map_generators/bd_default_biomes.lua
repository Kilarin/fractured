bd_default_biomes={}

upper_limit=33000
ocean_bottom=-800


--this is just the default biomes from minetest game converted to realms biomes

--heat_point and humidity_point are set in the biome map, not in the biome definition
 
	-- Icesheet

realms.register_biome({
		name = "default_icesheet",
		node_dust = "default:snowblock",
		node_top = "default:snowblock",
		depth_top = 1,
		node_filler = "default:snowblock",
		depth_filler = 3,
		node_stone = "default:cave_ice",
		node_water_top = "default:ice",
		depth_water_top = 10,
		node_river_water = "default:ice",
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = -8,
		--heat_point = 0,
		--humidity_point = 73,
	})

	realms.register_biome({
		name = "default_icesheet_ocean",
		node_dust = "default:snowblock",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_water_top = "default:ice",
		depth_water_top = 10,
		y_max = -9,
		y_min = ocean_bottom,
		--heat_point = 0,
		--humidity_point = 73,
	})

	-- Tundra

	realms.register_biome({
		name = "default_tundra_highland",
		node_dust = "default:snow",
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 47,
		--heat_point = 0,
		--humidity_point = 40,
		dec={
			{chance=1,node="default:permafrost_with_moss",offset_y=-1},
			}
	})

	realms.register_biome({
		name = "default_tundra",
		node_top = "default:permafrost_with_stones",
		depth_top = 1,
		node_filler = "default:permafrost",
		depth_filler = 1,
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		vertical_blend = 4,
		y_max = 46,
		y_min = 2,
		--heat_point = 0,
		--humidity_point = 40,
		dec={
			{chance=5,node="default:snow"},
			}
	})

	realms.register_biome({
		name = "default_tundra_beach",
		node_top = "default:gravel",
		depth_top = 1,
		node_filler = "default:gravel",
		depth_filler = 2,
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 1,
		y_min = -3,
		--heat_point = 0,
		--humidity_point = 40,
		dec={
			{chance=5,node="default:snow"},
			}
	})

	realms.register_biome({
		name = "default_tundra_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = -4,
		y_min = ocean_bottom,
		--heat_point = 0,
		--humidity_point = 40,
	})

	-- Taiga

	realms.register_biome({
		name = "default_taiga",
		node_dust = "default:snow",
		node_top = "default:dirt_with_snow",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 4,
		--heat_point = 25,
		--humidity_point = 70,
		dec={
			{chance=1.0,schematic=minetest.get_modpath("default").."/schematics/pine_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.5,schematic=minetest.get_modpath("default").."/schematics/small_pine_tree.mts",offset_x=-2,offset_z=-2,offset_y=-1},
			{chance=0.5,schematic=minetest.get_modpath("default").."/schematics/pine_log.mts"},
			{chance=0.3,schematic=minetest.get_modpath("default").."/schematics/pine_bush.mts",offset_x=-1,offset_z=-1},
			{chance=0.2,node="default:dry_shrub"},
			}
	})

	realms.register_biome({
		name = "default_taiga_ocean",
		node_dust = "default:snow",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 25,
		--humidity_point = 70,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Snowy grassland

	realms.register_biome({
		name = "default_snowy_grassland",
		node_dust = "default:snow",
		node_top = "default:dirt_with_snow",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 1,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 4,
		--heat_point = 20,
		--humidity_point = 35,
		dec={
			{chance=0.3,schematic=minetest.get_modpath("default").."/schematics/pine_bush.mts",offset_x=-1,offset_z=-1},
			{chance=0.2,node="default:dry_shrub"},
			}
	})

	realms.register_biome({
		name = "default_snowy_grassland_ocean",
		node_dust = "default:snow",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 20,
		--humidity_point = 35,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Grassland

	realms.register_biome({
		name = "default_grassland",
		node_top = "default:dirt_with_grass",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 1,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 6,
		--heat_point = 50,
		--humidity_point = 35,
		dec={
			{chance=0.5,schematic=minetest.get_modpath("default").."/schematics/apple_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.05,schematic=minetest.get_modpath("default").."/schematics/bush.mts", offset_x=-1,offset_z=-1},
			{chance=5, node="default:grass_1"},
			{chance=5, node="default:grass_2"},
			{chance=5, node="default:grass_3"},
			{chance=5, node="default:grass_4"},
			{chance=5, node="default:grass_5"},
			}
	})

	realms.register_biome({
		name = "default_grassland_dunes",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 2,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 5,
		y_min = 4,
		--heat_point = 50,
		--humidity_point = 35,
		dec={
			{chance=1, node="default:marram_grass_1"},
			{chance=1, node="default:marram_grass_2"},
			{chance=1, node="default:marram_grass_3"},
			}
	})

	realms.register_biome({
		name = "default_grassland_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 50,
		--humidity_point = 35,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Coniferous forest

	realms.register_biome({
		name = "default_coniferous_forest",
		node_top = "default:dirt_with_coniferous_litter",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 6,
		--heat_point = 45,
		--humidity_point = 70,
		dec={
			{chance=1.0,schematic=minetest.get_modpath("default") .. "/schematics/pine_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.5,schematic=minetest.get_modpath("default") .. "/schematics/small_pine_tree.mts",offset_x=-2,offset_z=-2,offset_y=-1},
			{chance=0.5,schematic= minetest.get_modpath("default") .. "/schematics/pine_log.mts"},
			{chance=.1,node="default:fern_1"},
			{chance=.1,node="default:fern_2"},
			{chance=.1,node="default:fern_3"},
			}
	})

	realms.register_biome({
		name = "default_coniferous_forest_dunes",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 5,
		y_min = 4,
		--heat_point = 45,
		--humidity_point = 70,
		dec={
			{chance=1, node="default:marram_grass_1"},
			{chance=1, node="default:marram_grass_2"},
			{chance=1, node="default:marram_grass_3"},
			}
	})

	realms.register_biome({
		name = "default_coniferous_forest_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 45,
		--humidity_point = 70,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Deciduous forest

	realms.register_biome({
		name = "default_deciduous_forest",
		node_top = "default:dirt_with_grass",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 1,
		--heat_point = 60,
		--humidity_point = 68,
		dec={
			{chance=0.5,schematic=minetest.get_modpath("default").."/schematics/apple_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.1,schematic=minetest.get_modpath("default").."/schematics/aspen_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.05,schematic=minetest.get_modpath("default").."/schematics/aspen_log.mts"},
			{chance=0.05,schematic=minetest.get_modpath("default").."/schematics/bush.mts", offset_x=-1,offset_z=-1},
			{chance=5, node="default:grass_1"},
			{chance=5, node="default:grass_2"},
			{chance=5, node="default:grass_3"},
			{chance=5, node="default:grass_4"},
			{chance=5, node="default:grass_5"},
			}
	})

	realms.register_biome({
		name = "default_deciduous_forest_shore",
		node_top = "default:dirt",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = 0,
		y_min = -1,
		--heat_point = 60,
		--humidity_point = 68,
	})

	realms.register_biome({
		name = "default_deciduous_forest_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = -2,
		y_min = ocean_bottom,
		--heat_point = 60,
		--humidity_point = 68,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Desert

	realms.register_biome({
		name = "default_desert",
		node_top = "default:desert_sand",
		depth_top = 1,
		node_filler = "default:desert_sand",
		depth_filler = 1,
		node_stone = "default:desert_stone",
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 4,
		--heat_point = 92,
		--humidity_point = 16,
		dec={
			{chance=0.05,schematic = minetest.get_modpath("default").."/schematics/large_cactus.mts",offset_x=-3,offset_z=-3},
			{chance=0.1,node="default:cactus",height=2,height_max=5},
			{chance=0.1,node="default:dry_shrub"},
			}
	})

	realms.register_biome({
		name = "default_desert_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_stone = "default:desert_stone",
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 92,
		--humidity_point = 16,
--		dec={
--			{chance=0.5,schematic = minetest.get_modpath("default") .. "/schematics/corals.mts",y_max = -2,y_min = -8},
--			}
--coral looks goofy without the y limits keeping it under water
	})

	-- Sandstone desert

	realms.register_biome({
		name = "default_sandstone_desert",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 1,
		node_stone = "default:sandstone",
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 4,
		--heat_point = 60,
		--humidity_point = 0,
		dec={
			{chance=0.2,node="default:dry_shrub"},
			}
	})

	realms.register_biome({
		name = "default_sandstone_desert_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_stone = "default:sandstone",
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 60,
		--humidity_point = 0,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Cold desert

	realms.register_biome({
		name = "default_cold_desert",
		node_top = "default:silver_sand",
		depth_top = 1,
		node_filler = "default:silver_sand",
		depth_filler = 1,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 4,
		--heat_point = 40,
		--humidity_point = 0,
		dec={
			{chance=0.2,node="default:dry_shrub"},
			}
	})

	realms.register_biome({
		name = "default_cold_desert_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 3,
		y_min = ocean_bottom,
		--heat_point = 40,
		--humidity_point = 0,
--		dec={
--			{chance=0.5,node="default:sand_with_kelp",y_max = -5,y_min = -10},
--			}
--kelp just isn't working for some reason
	})

	-- Savanna

	realms.register_biome({
		name = "default_savanna",
		node_top = "default:dirt_with_dry_grass",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 1,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 1,
		--heat_point = 89,
		--humidity_point = 42,
		dec={
			{chance=0.10, schematic=minetest.get_modpath("default").."/schematics/acacia_tree.mts",offset_x=-3,offset_y=-1,offset_z=-3},
			{chance=0.05, schematic=minetest.get_modpath("default").."/schematics/acacia_log.mts"},
			{chance=0.05, schematic=minetest.get_modpath("default").."/schematics/acacia_bush.mts",offset_x=-1,offset_z=-1},
			{chance=0.10, node="default:cactus", height=2, height_max=4},
			{chance=0.50, node="default:dry_grass_1"},
			{chance=0.50, node="default:dry_grass_2"},
			{chance=0.50, node="default:dry_grass_3"},
			{chance=0.50, node="default:dry_grass_4"},
			{chance=0.50, node="default:dry_grass_5"},
		}
	})

	realms.register_biome({
		name = "default_savanna_shore",
		node_top = "default:dirt",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = 0,
		y_min = -1,
		--heat_point = 89,
		--humidity_point = 42,
	})

	realms.register_biome({
		name = "default_savanna_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = -2,
		y_min = ocean_bottom,
--		dec={
--			{chance=0.5,schematic = minetest.get_modpath("default") .. "/schematics/corals.mts",y_max = -2,y_min = -8},
--			}
--coral looks goofy without the y limits keeping it under water
		--heat_point = 89,
		--humidity_point = 42,
	})

	-- Rainforest

	realms.register_biome({
		name = "default_rainforest",
		node_top = "default:dirt_with_rainforest_litter",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = upper_limit,
		y_min = 1,
		--heat_point = 86,
		--humidity_point = 65,
		dec={
			--note: original register_decoration said of emergent_jungle_tree: "Due to 32 node height, altitude is limited and prescence depends on chunksize"
			--so it looks like I may need some more logic to allow that kind of limit?
			{chance=0.1,schematic=minetest.get_modpath("default").."/schematics/emergent_jungle_tree.mts",offset_x=-4,offset_y=-4,offset_z=-4},
			{chance=5.0,schematic=minetest.get_modpath("default").."/schematics/jungle_tree.mts",offset_x=-3,offset_y=-1,offset_z=-3},
			{chance=0.5,schematic=minetest.get_modpath("default") .. "/schematics/jungle_log.mts"}, --offset_x=-3,offset_z=-3},
			{chance=5.0,node="default:junglegrass"}
			}
	})

	realms.register_biome({
		name = "default_rainforest_swamp",
		node_top = "default:dirt",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		y_max = 0,
		y_min = -1,
		--heat_point = 86,
		--humidity_point = 65,
		dec={
			{chance=5 ,schematic=minetest.get_modpath("default").."/schematics/jungle_tree.mts",offset_x=-3,offset_y=-1,offset_z=-3},
			{chance=0.3,schematic=minetest.get_modpath("default") .. "/schematics/jungle_log.mts",offset_x=-3,offset_z=-3},
			}
	})

	realms.register_biome({
		name = "default_rainforest_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = -2,
		y_min = ocean_bottom,
		--heat_point = 86,
		--humidity_point = 65,
--		dec={
--			{chance=0.5,schematic = minetest.get_modpath("default") .. "/schematics/corals.mts",y_max = -2,y_min = -8},
--			}
--coral looks goofy without the y limits keeping it under water
	})

	-- Underground

	realms.register_biome({
		name = "default_underground",
		y_max = -113,
		y_min = -31000,
		--heat_point = 50,
		--humidity_point = 50,
	})


