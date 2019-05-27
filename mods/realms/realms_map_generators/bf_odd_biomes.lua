bf_odd_biomes={}

--*!* serious consider deleting this whole thing.  you only need one raw bf to demonstrate it can be done independent of bd and bm

--this biome generator should be called once per chunk to build a biome map
--that will provide your landscape generator with
--parms.share.surface[z][x].biome             *!* out of date
--parms.share.surface[z][x].node_top
--parms.share.surface[z][x].node_filler
--parms.share.surface[z][x].decorate
--use node_filler between surface and stone.  use node_top for the surface, and call
--the decorate(x,y,z, biome, parms) function whenever you use node_top for the surface.

--I tried a version of this that was called for every node surface top to bot and placed
--the node_top and node_filler itself, as well as doing the decorating.  BUT, it was VERY
--VERY slow.
--I also tried a version that did all the decorating in one loop after you were done with
--the chunk.  it was a smidgen slower than this version.  So sticking with this

dofile(minetest.get_modpath("realms").."/realms_map_generators/odd_biomes_nodes.lua")
local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")

local c_crys_dirt = minetest.get_content_id("realms:crystal_dirt_with_grass")
local c_crys_leaves = minetest.get_content_id("realms:frost_leaves")
local c_crys_trunk = minetest.get_content_id("realms:frost_tree")


--local c_snow = minetest.get_content_id("default:snow")                                   --arctic (no trees)
local c_ice = minetest.get_content_id("default:ice")                                     --arctic (no trees)
local c_dirt_snow = minetest.get_content_id("default:dirt_with_snow")                    --cold   (pine trees)
local c_dirt_grass = minetest.get_content_id("default:dirt_with_grass")                       --warm   (trees)
local c_dirt_rainforest = minetest.get_content_id("default:dirt_with_rainforest_litter") --hot    (jungle trees)
local c_desert_sand = minetest.get_content_id("default:desert_sand")                     --desert (no trees)
--local c_dry_grass = minetest.get_content_id("default:dirt_with_dry_grass")  .............--savanna

local c_tree   =minetest.get_content_id("default:tree")
local c_apple  =minetest.get_content_id("default:apple")
local c_leaves =minetest.get_content_id("default:leaves")
local c_jtree  =minetest.get_content_id("default:jungletree")
local c_jleaves=minetest.get_content_id("default:jungleleaves")
local c_ptree  =minetest.get_content_id("default:pine_tree")
local c_pleaves=minetest.get_content_id("default:pine_needles")

bf_odd_biomes.heat_params={}
bf_odd_biomes.heat_params.arctic=-6.0
bf_odd_biomes.heat_params.cold  =-3.0
bf_odd_biomes.heat_params.warm  = 2.0
bf_odd_biomes.heat_params.hot   = 5.0
--heat_params.desert=
bf_odd_biomes.biomes = {ARCTIC=1, COLD=2, WARM=3, HOT=4, DESERT=5}

-- arctic  (snow, no trees)
-- cold    (dirt_with_snow, pine trees)
-- warm    (grass, apple trees)
-- hot     (dirt_rainforest, jungle trees)
-- desert  (sand, no trees)


bf_odd_biomes.np_heat = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 1,
	persist = 0.2
}


function bf_odd_biomes.gen_appletree(x, y, z, area, data)
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


function bf_odd_biomes.gen_jungletree(x, y, z, area, data)
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



--  m
-- mxm   x=location xyz which is NOT modified
--  m
function bf_odd_biomes.place_compass(x,y,z, area,data, node, distance)
	luautils.place_node(x+distance,y,z, area,data, node)
	luautils.place_node(x-distance,y,z, area,data, node)
	luautils.place_node(x,y,z+distance, area,data, node)
	luautils.place_node(x,y,z-distance, area,data, node)
end--place_compass

-- mmm
-- mxm x=location xyz which is NOT modified
-- mmm
function bf_odd_biomes.place_surround(x,y,z, area, data, node)
	for j=-1,1 do
		for k=-1,1 do
			if j~=0 or k~=0 then
				luautils.place_node(x+j,y,z+k, area,data, node)
			end --if j
		end --for k
	end --for j
end--place_four_around



function bf_odd_biomes.gen_pinetree(x, y, z, area, data)
	local vi
	for j = -1, 6 do
		luautils.place_node(x,y+j,z, area,data, c_ptree)
		if j==2 or j==4 or j==6 then
			bf_odd_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 1)
		end --if j 2 4 or 6
		if j==3 then
			place_surround(x,y+j,z, area,data, c_pleaves)
			for i=-1,1 do
				luautils.place_node(x+i,y+j,z-2, area,data, c_pleaves)
				luautils.place_node(x+i,y+j,z+2, area,data, c_pleaves)
			end --for i
			for k=-1,1 do
				luautils.place_node(x+2,y+j,z+k, area,data, c_pleaves)
				luautils.place_node(x-2,y+j,z+k, area,data, c_pleaves)
			end --for k
		bf_odd_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 3)
		end --if j=3
		if j==5 then
			bf_odd_biomes.place_surround(x,y+j,z, area,data, c_pleaves)
			bf_odd_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 2)
		end --if j==5
	end--for j
	luautils.place_node(x,y+7,z, area,data, c_pleaves)
end--gen_pinetree



function bf_odd_biomes.gen_crystree(x, y, z, area, data)
	local vi
	for j = -1, 6 do
		luautils.place_node(x,y+j,z, area,data, c_crys_trunk)
		if j==2 or j==4 or j==6 then
			place_compass(x,y+j,z, area,data, c_crys_leaves, 1)
		end --if j 2 4 or 6
		if j==3 then
			place_surround(x,y+j,z, area,data, c_crys_leaves)
			for i=-1,1 do
				luautils.place_node(x+i,y+j,z-2, area,data, c_crys_leaves)
				luautils.place_node(x+i,y+j,z+2, area,data, c_crys_leaves)
			end --for i
			for k=-1,1 do
				luautils.place_node(x+2,y+j,z+k, area,data, c_crys_leaves)
				luautils.place_node(x-2,y+j,z+k, area,data, c_crys_leaves)
			end --for k
		bf_odd_biomes.place_compass(x,y+j,z, area,data, c_crys_leaves, 3)
		end --if j=3
		if j==5 then
			bf_odd_biomes.place_surround(x,y+j,z, area,data, c_crys_leaves)
			bf_odd_biomes.place_compass(x,y+j,z, area,data, c_crys_leaves, 2)
		end --if j==5
	end--for j
	luautils.place_node(x,y+7,z, area,data, c_crys_leaves)
end--gen_pinetree



function bf_odd_biomes.decorate(x,y,z, biome, parms)
--need to add flowers and grass here
	if math.random(1000)<=biome.treechance then biome.tree(x,y+1,z,parms.area,parms.data) end
	--minetest.log("bf_basic_biomes-> x="..x.." y="..y.." z="..z.." biome="..bi)
end --decorate

bf_odd_biomes.biome={}
bf_odd_biomes.biome[bf_odd_biomes.biomes.ARCTIC]={}
bf_odd_biomes.biome[bf_odd_biomes.biomes.ARCTIC].node_top=c_ice
bf_odd_biomes.biome[bf_odd_biomes.biomes.ARCTIC].node_filler=c_ice
bf_odd_biomes.biome[bf_odd_biomes.biomes.ARCTIC].tree=nil
bf_odd_biomes.biome[bf_odd_biomes.biomes.ARCTIC].treechance=0  --treechance is in a thousand
bf_odd_biomes.biome[bf_odd_biomes.biomes.ARCTIC].decorate=bf_odd_biomes.decorate

bf_odd_biomes.biome[bf_odd_biomes.biomes.COLD]={}
bf_odd_biomes.biome[bf_odd_biomes.biomes.COLD].node_top=c_crys_dirt
bf_odd_biomes.biome[bf_odd_biomes.biomes.COLD].node_filler=c_dirt
bf_odd_biomes.biome[bf_odd_biomes.biomes.COLD].tree=bf_odd_biomes.gen_crystree
bf_odd_biomes.biome[bf_odd_biomes.biomes.COLD].treechance=10
bf_odd_biomes.biome[bf_odd_biomes.biomes.COLD].decorate=bf_odd_biomes.decorate

bf_odd_biomes.biome[bf_odd_biomes.biomes.WARM]={}
bf_odd_biomes.biome[bf_odd_biomes.biomes.WARM].node_top=c_dirt_grass
bf_odd_biomes.biome[bf_odd_biomes.biomes.WARM].node_filler=c_dirt
bf_odd_biomes.biome[bf_odd_biomes.biomes.WARM].tree=bf_odd_biomes.gen_appletree
bf_odd_biomes.biome[bf_odd_biomes.biomes.WARM].treechance=5
bf_odd_biomes.biome[bf_odd_biomes.biomes.WARM].decorate=bf_odd_biomes.decorate

bf_odd_biomes.biome[bf_odd_biomes.biomes.HOT]={}
bf_odd_biomes.biome[bf_odd_biomes.biomes.HOT].node_top=c_dirt_rainforest
bf_odd_biomes.biome[bf_odd_biomes.biomes.HOT].node_filler=c_dirt
bf_odd_biomes.biome[bf_odd_biomes.biomes.HOT].tree=bf_odd_biomes.gen_jungletree
bf_odd_biomes.biome[bf_odd_biomes.biomes.HOT].treechance=50
bf_odd_biomes.biome[bf_odd_biomes.biomes.HOT].decorate=bf_odd_biomes.decorate

bf_odd_biomes.biome[bf_odd_biomes.biomes.DESERT]={}
bf_odd_biomes.biome[bf_odd_biomes.biomes.DESERT].node_top=c_desert_sand
bf_odd_biomes.biome[bf_odd_biomes.biomes.DESERT].node_filler=c_desert_sand
bf_odd_biomes.biome[bf_odd_biomes.biomes.DESERT].tree=nil
bf_odd_biomes.biome[bf_odd_biomes.biomes.DESERT].treechance=0
bf_odd_biomes.biome[bf_odd_biomes.biomes.DESERT].decorate=bf_odd_biomes.decorate



--********************************
function bf_odd_biomes.map_biome_to_surface(parms)
	--get noise details
	local biomes=bf_odd_biomes.biomes
	local heat_map = minetest.get_perlin_map(bf_odd_biomes.np_heat, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			local n_biome = heat_map[nixz] * 10
			local bi
			if n_biome < bf_odd_biomes.heat_params.arctic then
				bi = biomes.ARCTIC
			elseif n_biome < bf_odd_biomes.heat_params.cold then
				bi = biomes.COLD
			elseif n_biome < bf_odd_biomes.heat_params.warm then
				bi = biomes.WARM
			elseif n_biome < bf_odd_biomes.heat_params.hot then
				bi = biomes.HOT
			else
				bi = biomes.DESERT
			end --if
      parms.share.surface[z][x].biome=bf_odd_biomes.biome[bi]
			nixz=nixz+1
		end --for x
	end --for z
end --get_biome



--********************************
function bf_basic_biomes.bf_odd_biomes(parms)
bf_odd_biomes.map_biome_to_surface(parms)
end -- bf_basic_biomes

realms.register_mapfunc("bf_odd_biomes",bf_basic_biomes.bf_odd_biomes)


