bd_basic_biomes={}

--this was inspired by and takes some code from
--https://github.com/SmallJoker/noisetest WTFPL License

--this biome generator should be called once per chunk to build a biome map
--that will provide your landscape generator with
--parms.share.surface[z][x].biome
--parms.share.surface[z][x].biome.node_top
--parms.share.surface[z][x].biome.node_filler
--parms.share.surface[z][x].biome.decorate    --*!* do I still need this?
--use node_filler between surface and stone.  use node_top for the surface, and call
--the decorate(x,y,z, biome, parms) function whenever you use node_top for the surface.

--I tried a version of this that was called for every node surface top to bot and placed
--the node_top and node_filler itself, as well as doing the decorating.  BUT, it was VERY
--VERY slow.
--I also tried a version that did all the decorating in one loop after you were done with
--the chunk.  it was a smidgen slower than this version.  So sticking with this

dofile(minetest.get_modpath("realms").."/realms_map_generators/basic_biomes_nodes.lua")
local c_air = minetest.get_content_id("air")

local c_tree   =minetest.get_content_id("default:tree")
local c_apple  =minetest.get_content_id("default:apple")
local c_leaves =minetest.get_content_id("default:leaves")

local c_jtree  =minetest.get_content_id("default:jungletree")
local c_jleaves=minetest.get_content_id("default:jungleleaves")

local c_ptree  =minetest.get_content_id("default:pine_tree")

local realmsschematics=minetest.get_modpath("realms").."/schematics"
local defaultschematics=minetest.get_modpath("default").."/schematics"


function bd_basic_biomes.gen_appletree(x, y, z, area, data)
	for j = -1, 6 do
		if j == 5 or j == 6 then
			for i = -3, 3 do
			for k = -3, 3 do
				local vi = area:index(x + i, y + j, z + k)
				local rd = math.random(50)
				if rd == 2 then
					data[vi] = c_apple
				elseif rd >= 10 then
					data[vi] = c_leaves
				end
			end
			end
		elseif j == 4 then
			for i = -2, 2 do
			for k = -2, 2 do
				if math.abs(i) + math.abs(k) == 2 then
					local vi = area:index(x + i, y + j, z + k)
					data[vi] = c_tree
				end
			end
			end
		else
			local vi = area:index(x, y + j, z)
			data[vi] = c_tree
		end
	end
end


function bd_basic_biomes.gen_jungletree(x, y, z, area, data)
	for j = -1, 14 do
		if j == 8 or j == 10 or j == 14 then
			for i = -3, 3 do
			for k = -3, 3 do
				local vil = area:index(x + i, y + j + math.random(0, 1), z + k)
				if math.random(5) ~= 2 then
					data[vil] = c_jleaves
				end
			end
			end
		end
		local vit = area:index(x, y + j, z)
		data[vit] = c_jtree
	end
end






realms.register_biome({
		name="basic_arctic",
		node_top="default:ice",
		depth_top = 1,
		node_filler="default:ice",
		depth_filler = 10,
		dec=nil
		})



dofile(realmsschematics.."/pine_tree.lua")

realms.register_biome({
		name="basic_cold",
		node_top="default:dirt_with_snow",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 6,
		dec={
			{chance=1.0,schematic=bd_basic_biomes.pinetree, offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=1.0,schematic=defaultschematics.."/pine_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.5,schematic=defaultschematics.."/small_pine_tree.mts",offset_x=-2,offset_z=-2,offset_y=-1},
			{chance=0.2,schematic=defaultschematics.."/pine_log.mts"},
			{chance=0.3,schematic=defaultschematics.."/pine_bush.mts",offset_x=-1,offset_z=-1},
			{chance=2,node="realms:snowygrass"},
			{chance=.1,node="default:fern_1"},
			{chance=.1,node="default:fern_2"},
			{chance=.1,node="default:fern_3"},
			}
		})


realms.register_biome({
		name="basic_warm",
		node_top="default:dirt_with_grass",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 4,
		dec={
			{chance=0.25, func=bd_basic_biomes.gen_appletree},
			{chance=0.25,schematic=defaultschematics.."/apple_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.1,schematic=defaultschematics.."/aspen_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
			{chance=0.05,schematic=defaultschematics.."/aspen_log.mts"},
			{chance=0.05,schematic=defaultschematics.."/bush.mts", offset_x=-1,offset_z=-1},
			{chance=5, node="default:grass_1"},
			{chance=5, node="default:grass_2"},
			{chance=5, node="default:grass_3"},
			{chance=5, node="default:grass_4"},
			{chance=5, node="default:grass_5"},
			}
		})


realms.register_biome({
		name="basic_hot",
		node_top="default:dirt_with_rainforest_litter",
		depth_top = 1,
		node_filler="default:dirt",
		depth_filler = 3,
		dec={
			{chance=2.5,func=bd_basic_biomes.gen_jungletree},
			{chance=2.5,schematic=defaultschematics.."/jungle_tree.mts",offset_x=-3,offset_y=-1,offset_z=-3},
			{chance=0.1,schematic=defaultschematics.."/emergent_jungle_tree.mts",offset_x=-4,offset_y=-4,offset_z=-4},
			{chance=0.5,schematic=defaultschematics.."/jungle_log.mts"}, --offset_x=-3,offset_z=-3},
			{chance=5,node="default:junglegrass"},
			}
		})

realms.register_biome({
		name="basic_desert",
		node_top="default:desert_sand",
		depth_top = 1,
		node_filler="default:desert_sand",
		depth_filler = 9,
		dec={
			{chance=.1, node="default:cactus", height=2, height_max=4},
			{chance=0.05,schematic = defaultschematics.."/large_cactus.mts",offset_x=-3,offset_z=-3},
			{chance=.5, node="default:dry_grass_1"},
			{chance=.5, node="default:dry_grass_2"},
			{chance=.5, node="default:dry_grass_3"},
			{chance=.5, node="default:dry_grass_4"},
			{chance=.5, node="default:dry_grass_5"},
			{chance=.3, node="default:dry_shrub"},
			}
		})



