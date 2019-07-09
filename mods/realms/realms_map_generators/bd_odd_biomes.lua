--[[
This is a collection of unusual/odd/strange biomes.
It needs more biomes, and more decorations
--]]


bd_odd_biomes={}

dofile(minetest.get_modpath("realms").."/realms_map_generators/nodes_odd_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/nodes_chasm.lua")
local c_air = minetest.get_content_id("air")

local realmsschematics=minetest.get_modpath("realms").."/schematics"
local defaultschematics=minetest.get_modpath("default").."/schematics"


upper_limit=33000
ocean_bottom=-800


dofile(realmsschematics.."/frost_tree.lua")

realms.register_biome({
		name="odd_crystal",
		node_top="realms:crystal_dirt_with_grass",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 3,
		y_max = upper_limit,
		y_min = 1,
		alternates={"basic_shore","basic_ocean"},
		dec={
			{chance=1, schematic=bd_odd_biomes.frost_tree, offset_x=-3, offset_z=-3, offset_y=-1}, --center and one underground
			{chance=3,node="realms:crystal_grass"}
			}
		})



-- ---------------------------------------------------------------

dofile(realmsschematics.."/mushroom_giant_fly.lua")
dofile(realmsschematics.."/mushroom_giant_morel.lua")
dofile(realmsschematics.."/mushroom_giant_tall.lua")

realms.register_biome({
		name="odd_mushroom",
		node_top="realms:mushroom_moss",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 3,
		y_max = upper_limit,
		y_min = 1,
		alternates={"basic_shore","basic_ocean"},
		dec={
			{chance=0.75, schematic=bd_odd_biomes.mushroom_giant_fly, offset_x=-3, offset_z=-3, offset_y=-1}, --center and one underground
			{chance=0.15, schematic=bd_odd_biomes.mushroom_giant_morel, offset_x=-3, offset_z=-3, offset_y=-1}, --center and one underground
			{chance=0.05, schematic=bd_odd_biomes.mushroom_giant_tall, offset_x=-9, offset_z=-9, offset_y=-2}, --center and two underground
			{chance=2,node="flowers:mushroom_brown"},
			{chance=2,node="flowers:mushroom_red"},
			{chance=0.5,node="realms:mushroom_white"},
			{chance=1,node="realms:mushroom_milkcap"},
			{chance=1,node="realms:mushroom_shaggy_mane"},
			{chance=1,node="realms:mushroom_parasol"},
			{chance=0.3,node="realms:mushroom_sulfer_tuft"},
--			{chance=2,node="realms:mushroom_sulfer_tuft_128"},
			}
		})


-- -----------------------------------

realms.register_biome({
		name="odd_scorched",
		node_top="realms:dry_dirt",
		depth_top = 1,
		node_filler="realms:dry_dirt",
		depth_filler = 3,
		y_max = upper_limit,
		y_min = 1,
		alternates={"basic_shore","basic_ocean"},
		dec={
			{chance=.1, node="realms:scorched_trunk", height = 2, height_max = 6},
			{chance=.05, node="default:dry_grass_1"},
			{chance=.05, node="default:dry_grass_2"},
			{chance=.05, node="default:dry_grass_3"},
			{chance=.05, node="default:dry_grass_4"},
			{chance=.05, node="default:dry_grass_5"},
			{chance=.1, node="default:dry_shrub"},
			{chance=.001, node="realms:cow_skull",rotate="random"},
			}
		})


-- -----------------------------------

dofile(realmsschematics.."/golden_tree.lua")

realms.register_biome({
		name="odd_golden",
		node_top="realms:dirt_with_golden_grass",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 9,
		y_max = upper_limit,
		y_min = 1,
		alternates={"basic_shore","basic_ocean"},
		dec={
			{chance=.5, schematic=bd_odd_biomes.golden_tree, offset_x=-4, offset_y=-1, offset_z=-4},
			{chance=.5, node="realms:golden_grass_1"},
			{chance=.5, node="realms:golden_grass_2"},
			{chance=.5, node="realms:golden_grass_3"},
			{chance=.5, node="realms:golden_grass_4"},
			{chance=.5, node="realms:golden_grass_5"},
			}
		})


------------------------------------

dofile(realmsschematics.."/rainbow_willow_tree.lua")

realms.register_biome({
		name="odd_rainbow",
		node_top="realms:dirt_with_gray_grass",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 9,
		y_max = upper_limit,
		y_min = 1,
		alternates={"basic_shore","basic_ocean"},
		dec={
			{chance=.5, schematic=bd_odd_biomes.rainbow_willow_tree, offset_x=-6, offset_y=-1, offset_z=-6},
			{chance=.5, node="realms:rainbow_bush"},
			}
		})


--------------------------------------------------

dofile(realmsschematics.."/skeleton.lua")

realms.register_biome({
	name="odd_chasm_bottom",
	node_top="default:sand",
	depth_top = 1,
	node_filler="default:sand",
	depth_filler = 1,
	dec={
		{chance=0.007, schematic=bd_odd_biomes.skeleton},
		{chance=0.007, node="realms:skeleton_head"},
		{chance=0.02,schematic=defaultschematics.."/pine_log.mts"},
		{chance=0.02,schematic=defaultschematics.."/aspen_log.mts"},
		{chance=0.02,schematic=defaultschematics.."/jungle_log.mts"},
		{chance=0.5,node="default:stone",height=1,height_max=2,offset_y=-1},
		{chance=0.5,node="default:gravel",height=1,height_max=2,offset_y=-1},
		{chance=.001, node="realms:cow_skull",rotate="random"},
		}
	})




