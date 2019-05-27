--this was inspired by and takes some code from
--https://github.com/SmallJoker/noisetest WTFPL License

bg_basic_biomes={}

local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_sand = minetest.get_content_id("default:sand")

--local c_snow = minetest.get_content_id("default:snow")                                   --arctic (no trees)
local c_ice = minetest.get_content_id("default:ice")                                     --arctic (no trees)
local c_dirt_snow = minetest.get_content_id("default:dirt_with_snow")                    --cold   (pine trees)
local c_grass = minetest.get_content_id("default:dirt_with_grass")                       --warm   (trees)
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

local heat_params={}
heat_params.arctic=-6.0
heat_params.cold  =-3.0
heat_params.warm  = 2.0
heat_params.hot   = 5.0
--heat_params.desert=   
local biomes = {ARCTIC=1, COLD=2, WARM=3, HOT=4, DESERT=5}

-- arctic  (snow, no trees)
-- cold    (dirt_with_snow, pine trees)
-- warm    (grass, apple trees)
-- hot     (dirt_rainforest, jungle trees)
-- desert  (sand, no trees)


np_heat = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 1,
	persist = 0.2
}
local nvals_heat



function bg_basic_biomes.gen_appletree(x, y, z, area, data)
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

function bg_basic_biomes.gen_jungletree(x, y, z, area, data)
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


function bg_basic_biomes.place_material(x,y,z, area, data, material)
	local vi = area:index(x, y, z)
	data[vi] = material
end --place mateiral

--  m
-- mxm   x=location xyz which is NOT modified
--  m
function bg_basic_biomes.place_compass(x,y,z, area,data, material, distance)
	bg_basic_biomes.place_material(x+distance,y,z, area,data, material)
	bg_basic_biomes.place_material(x-distance,y,z, area,data, material)
	bg_basic_biomes.place_material(x,y,z+distance, area,data, material)
	bg_basic_biomes.place_material(x,y,z-distance, area,data, material)
end--bg_basic_biomes.place_compass

-- mmm
-- mxm x=location xyz which is NOT modified
-- mmm
function bg_basic_biomes.place_surround(x,y,z, area, data, material)
	for j=-1,1 do
		for k=-1,1 do
			if j~=0 or k~=0 then
				bg_basic_biomes.place_material(x+j,y,z+k, area,data, material)
			end --if j
		end --for k
	end --for j
end--place_four_around



function bg_basic_biomes.gen_pinetree(x, y, z, area, data)
	local vi
	for j = -1, 6 do
		bg_basic_biomes.place_material(x,y+j,z, area,data, c_ptree)
		if j==2 or j==4 or j==6 then 
			bg_basic_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 1)
		end --if j 2 4 or 6
		if j==3 then
			bg_basic_biomes.place_surround(x,y+j,z, area,data, c_pleaves)
			for i=-1,1 do 
				bg_basic_biomes.place_material(x+i,y+j,z-2, area,data, c_pleaves)
				bg_basic_biomes.place_material(x+i,y+j,z+2, area,data, c_pleaves)
			end --for i
			for k=-1,1 do
				bg_basic_biomes.place_material(x+2,y+j,z+k, area,data, c_pleaves)
				bg_basic_biomes.place_material(x-2,y+j,z+k, area,data, c_pleaves)
			end --for k
		bg_basic_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 3)
		end --if j=3
		if j==5 then
			bg_basic_biomes.place_surround(x,y+j,z, area,data, c_pleaves) 
			bg_basic_biomes.place_compass(x,y+j,z, area,data, c_pleaves, 2)
		end --if j==5
	end--for j
	bg_basic_biomes.place_material(x,y+7,z, area,data, c_pleaves)
end--bg_basic_biomes.gen_pinetree


local biome={}
biome[biomes.ARCTIC]={}
biome[biomes.ARCTIC].node_top=c_ice
biome[biomes.ARCTIC].node_filler=c_ice
biome[biomes.ARCTIC].tree=nil
biome[biomes.ARCTIC].treechance=0  --treechance is in a thousand

biome[biomes.COLD]={}
biome[biomes.COLD].node_top=c_dirt_snow
biome[biomes.COLD].node_filler=c_dirt
biome[biomes.COLD].tree=bg_basic_biomes.gen_pinetree
biome[biomes.COLD].treechance=15

biome[biomes.WARM]={}
biome[biomes.WARM].node_top=c_grass
biome[biomes.WARM].node_filler=c_dirt
biome[biomes.WARM].tree=bg_basic_biomes.gen_appletree
biome[biomes.WARM].treechance=5

biome[biomes.HOT]={}
biome[biomes.HOT].node_top=c_dirt_rainforest
biome[biomes.HOT].node_filler=c_dirt
biome[biomes.HOT].tree=bg_basic_biomes.gen_jungletree
biome[biomes.HOT].treechance=50

biome[biomes.DESERT]={}
biome[biomes.DESERT].node_top=c_desert_sand
biome[biomes.DESERT].node_filler=c_desert_sand
biome[biomes.DESERT].tree=nil
biome[biomes.DESERT].treechance=0


--********************************
function bg_basic_biomes.get_biome(nixz)
	local n_biome = nvals_heat[nixz] * 10
	local bi
	if n_biome < heat_params.arctic then
		bi = biomes.ARCTIC
	elseif n_biome < heat_params.cold then
		bi = biomes.COLD
	elseif n_biome < heat_params.warm then
		bi = biomes.WARM
	elseif n_biome < heat_params.hot then
		bi = biomes.HOT
	else
		bi = biomes.DESERT
	end --if
	--minetest.log("bg_basic_biomes.get_biome-> nixz="..nixz.." n_biome="..n_biome.." bi="..bi)
	return bi
end --bg_basic_biomes.get_biome


--********************************
function gen_bg_basic_biomes(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	--but we DO need to check if a surface map was sent
	if parms.share.surface~=nil then
		local t1 = os.clock()
		--minetest.log("gen_bg_basic_biomes top isect minp="..luautils.pos_to_str(parms.isect_minp).." maxp="..luautils.pos_to_str(parms.isect_maxp))
	
		nvals_heat = minetest.get_perlin_map(np_heat, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	
		local nixz=1
		for z=parms.isect_minp.z, parms.isect_maxp.z do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				--SOME of the surface should be in this chunk, but not necesarilly all of it
				--we have to check for it because we can end up with strange floating surfaces
				--if we try to update a top that isn't in this chunk
				local srfc=parms.share.surface[z][x].top
				if srfc<=parms.isect_maxp.y and srfc>=parms.isect_minp.y --srfc is in this chunk
				    and srfc>=parms.sealevel then --don't mess with underwater (for this biome generator)
					local bi=bg_basic_biomes.get_biome(nixz)
					local vi = parms.area:index(x, srfc, z) -- This accesses the node at a given position
					parms.data[vi]=biome[bi].node_top
					if math.random(1000)<=biome[bi].treechance then biome[bi].tree(x,srfc+1,z,parms.area,parms.data) end 
				end --if srfc
				--now see if we need to convert the underneath stuff
				if (srfc-1)>=parms.isect_minp.y then --this wont work right, don't have dirtbot yet
					local j=-1
					local vi = parms.area:index(x, srfc+j, z) -- This accesses the node at a given position
					local bi=bg_basic_biomes.get_biome(nixz)
					--minetest.log("gen_bg_basic_biomes-> bi="..bi.." j="..j.." parms.data[vi]="..parms.data[vi].." c_dirt="..c_dirt)
					while parms.data[vi]==c_dirt do  --got to check for end of chunk as well
						local bi=bg_basic_biomes.get_biome(nixz)
						parms.data[vi]=biome[bi].node_filler
						j=j-1
						vi=parms.area:index(x, srfc+j, z) 
						--minetest.log("gen_bg_basic_biomes-> bi="..bi.." j="..j.." parms.data[vi]="..parms.data[vi].." c_dirt="..c_dirt)
					end --while
				end --if
				nixz=nixz+1
			end --for x
		end --for z

	
		local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
		minetest.log("gen_bg_basic_biomes-> END isect="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
	end --if parms.share.surface
end -- gen_very_simple
	
realms.register_mapgen("bg_basic_biomes",gen_bg_basic_biomes)


