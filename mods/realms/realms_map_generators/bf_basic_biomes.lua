bf_basic_biomes={}
--this was inspired by and takes some code from
--https://github.com/SmallJoker/noisetest WTFPL License


--bf_ = Biome Function  Biome Functions are called by a tg_ Terrain Generator to build a surface map.
--


--this biome generator should be called once per chunk to build a biome map
--that will provide your landscape generator with
--parms.share.surface[z][x].biome       

--I tried a version of this that was called for every node surface top to bot and placed
--the node_top and node_filler itself, as well as doing the decorating.  BUT, it was VERY
--VERY slow.
--I also tried a version that did all the decorating in one loop after you were done with
--the chunk.  it was a smidgen slower than this version.  So sticking with this


local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")

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

bf_basic_biomes.heat_params={}
bf_basic_biomes.heat_params.arctic=-6.0
bf_basic_biomes.heat_params.cold  =-3.0
bf_basic_biomes.heat_params.warm  = 2.0
bf_basic_biomes.heat_params.hot   = 5.0
--heat_params.desert=
bf_basic_biomes.biomes = {ARCTIC=1, COLD=2, WARM=3, HOT=4, DESERT=5}

-- arctic  (snow, no trees)
-- cold    (dirt_with_snow, pine trees)
-- warm    (grass, apple trees)
-- hot     (dirt_rainforest, jungle trees)
-- desert  (sand, no trees)


bf_basic_biomes.np_heat = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 1,
	persist = 0.2
}


function bf_basic_biomes.gen_appletree(x, y, z, area, data)
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


function bf_basic_biomes.gen_jungletree(x, y, z, area, data)
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
function bf_basic_biomes.place_compass(x,y,z, area,data, node, distance)
	luautils.place_node(x+distance,y,z, area,data, node)
	luautils.place_node(x-distance,y,z, area,data, node)
	luautils.place_node(x,y,z+distance, area,data, node)
	luautils.place_node(x,y,z-distance, area,data, node)
end--place_compass

-- mmm
-- mxm x=location xyz which is NOT modified
-- mmm
function bf_basic_biomes.place_surround(x,y,z, area, data, node)
	for j=-1,1 do
		for k=-1,1 do
			if j~=0 or k~=0 then
				luautils.place_node(x+j,y,z+k, area,data, node)
			end --if j
		end --for k
	end --for j
end--place_four_around



function bf_basic_biomes.gen_pinetree(x, y, z, area, data)
	local vi
	for j = -1, 6 do
		luautils.place_node(x,y+j,z, area,data, c_ptree)
		if j==2 or j==4 or j==6 then
			bf_basic_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 1)
		end --if j 2 4 or 6
		if j==3 then
			bf_basic_biomes.place_surround(x,y+j,z, area,data, c_pleaves)
			for i=-1,1 do
				luautils.place_node(x+i,y+j,z-2, area,data, c_pleaves)
				luautils.place_node(x+i,y+j,z+2, area,data, c_pleaves)
			end --for i
			for k=-1,1 do
				luautils.place_node(x+2,y+j,z+k, area,data, c_pleaves)
				luautils.place_node(x-2,y+j,z+k, area,data, c_pleaves)
			end --for k
		bf_basic_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 3)
		end --if j=3
		if j==5 then
			bf_basic_biomes.place_surround(x,y+j,z, area,data, c_pleaves)
			bf_basic_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 2)
		end --if j==5
	end--for j
	luautils.place_node(x,y+7,z, area,data, c_pleaves)
end--gen_pinetree



function bf_basic_biomes.decorate(x,y,z, biome, parms)
--need to add flowers and grass here
	--minetest.log("x="..x.." y="..y.." z="..z.." bi="..bi)
	if math.random(1000)<=biome.treechance then biome.tree(x,y+1,z,parms.area,parms.data) end
	--minetest.log("bf_basic_biomes-> x="..x.." y="..y.." z="..z.." biome="..bi)
end --decorate


bf_basic_biomes.biome={}
bf_basic_biomes.biome[bf_basic_biomes.biomes.ARCTIC]={}
bf_basic_biomes.biome[bf_basic_biomes.biomes.ARCTIC].node_top=c_ice
bf_basic_biomes.biome[bf_basic_biomes.biomes.ARCTIC].node_filler=c_ice
bf_basic_biomes.biome[bf_basic_biomes.biomes.ARCTIC].tree=nil
bf_basic_biomes.biome[bf_basic_biomes.biomes.ARCTIC].treechance=0  --treechance is in a thousand
bf_basic_biomes.biome[bf_basic_biomes.biomes.ARCTIC].decorate=bf_basic_biomes.decorate

bf_basic_biomes.biome[bf_basic_biomes.biomes.COLD]={}
bf_basic_biomes.biome[bf_basic_biomes.biomes.COLD].node_top=c_dirt_snow
bf_basic_biomes.biome[bf_basic_biomes.biomes.COLD].node_filler=c_dirt
bf_basic_biomes.biome[bf_basic_biomes.biomes.COLD].tree=bf_basic_biomes.gen_pinetree
bf_basic_biomes.biome[bf_basic_biomes.biomes.COLD].treechance=15
bf_basic_biomes.biome[bf_basic_biomes.biomes.COLD].decorate=bf_basic_biomes.decorate

bf_basic_biomes.biome[bf_basic_biomes.biomes.WARM]={}
bf_basic_biomes.biome[bf_basic_biomes.biomes.WARM].node_top=c_dirt_grass
bf_basic_biomes.biome[bf_basic_biomes.biomes.WARM].node_filler=c_dirt
bf_basic_biomes.biome[bf_basic_biomes.biomes.WARM].tree=bf_basic_biomes.gen_appletree
bf_basic_biomes.biome[bf_basic_biomes.biomes.WARM].treechance=5
bf_basic_biomes.biome[bf_basic_biomes.biomes.WARM].decorate=bf_basic_biomes.decorate

bf_basic_biomes.biome[bf_basic_biomes.biomes.HOT]={}
bf_basic_biomes.biome[bf_basic_biomes.biomes.HOT].node_top=c_dirt_rainforest
bf_basic_biomes.biome[bf_basic_biomes.biomes.HOT].node_filler=c_dirt
bf_basic_biomes.biome[bf_basic_biomes.biomes.HOT].tree=bf_basic_biomes.gen_jungletree
bf_basic_biomes.biome[bf_basic_biomes.biomes.HOT].treechance=50
bf_basic_biomes.biome[bf_basic_biomes.biomes.HOT].decorate=bf_basic_biomes.decorate

bf_basic_biomes.biome[bf_basic_biomes.biomes.DESERT]={}
bf_basic_biomes.biome[bf_basic_biomes.biomes.DESERT].node_top=c_desert_sand
bf_basic_biomes.biome[bf_basic_biomes.biomes.DESERT].node_filler=c_desert_sand
bf_basic_biomes.biome[bf_basic_biomes.biomes.DESERT].tree=nil
bf_basic_biomes.biome[bf_basic_biomes.biomes.DESERT].treechance=0
bf_basic_biomes.biome[bf_basic_biomes.biomes.DESERT].decorate=bf_basic_biomes.decorate







--********************************
function bf_basic_biomes.map_biome_to_surface(parms)
	--get noise details
	local heat_map = minetest.get_perlin_map(bf_basic_biomes.np_heat, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			local n_biome = heat_map[nixz] * 10
			local bi
			if n_biome < bf_basic_biomes.heat_params.arctic then
				bi = bf_basic_biomes.biomes.ARCTIC
			elseif n_biome < bf_basic_biomes.heat_params.cold then
				bi = bf_basic_biomes.biomes.COLD
			elseif n_biome < bf_basic_biomes.heat_params.warm then
				bi = bf_basic_biomes.biomes.WARM
			elseif n_biome < bf_basic_biomes.heat_params.hot then
				bi = bf_basic_biomes.biomes.HOT
			else
				bi = bf_basic_biomes.biomes.DESERT
			end --if
      parms.share.surface[z][x].biome=bf_basic_biomes.biome[bi]
			nixz=nixz+1
		end --for x
	end --for z
end --get_biome



--********************************
function bf_basic_biomes.bf_basic_biomes(parms)
bf_basic_biomes.map_biome_to_surface(parms)
end -- bf_basic_biomes

realms.register_mapfunc("bf_basic_biomes",bf_basic_biomes.bf_basic_biomes)


