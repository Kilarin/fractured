--this was inspired by and takes some snippets of code from
--https://github.com/SmallJoker/noisetest WTFPL License


local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")

local c_snow = minetest.get_content_id("default:snow")                                   --arctic (no trees)
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

local heat_params={}
heat_params.arctic=-6.4
heat_params.cold  =-4.0
heat_params.warm  = 4.0
heat_params.hot   = 6.4
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



function gen_appletree(x, y, z, area, data)
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

function gen_jungletree(x, y, z, area, data)
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


local biome={}
biome[biomes.ARCTIC]={}
biome[biomes.ARCTIC].under=c_snow
biome[biomes.ARCTIC].tree=nil
biome[biomes.ARCTIC].treechance=0  --treechance is in a thousand

biome[biomes.COLD]={}
biome[biomes.COLD].under=c_dirt_snow
biome[biomes.COLD].tree=nil
biome[biomes.COLD].treechance=0

biome[biomes.WARM]={}
biome[biomes.WARM].under=c_grass
biome[biomes.WARM].tree=gen_appletree
biome[biomes.WARM].treechance=15

biome[biomes.HOT]={}
biome[biomes.HOT].under=c_dirt_rainforest
biome[biomes.HOT].tree=gen_jungletree
biome[biomes.HOT].treechance=70

biome[biomes.DESERT]={}
biome[biomes.DESERT].under=c_desert_sand
biome[biomes.DESERT].tree=nil
biome[biomes.DESERT].treechance=0


--********************************
function get_biome(nixz)
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
	--minetest.log("get_biome-> nixz="..nixz.." n_biome="..n_biome.." bi="..bi)
	return bi
end --get_biome


--********************************
function gen_bg_basic_biomes(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()
	--minetest.log("gen_bg_basic_biomes top isect minp="..luautils.pos_to_str(parms.isect_minp).." maxp="..luautils.pos_to_str(parms.isect_maxp))

	--get noise details
	local isectsize = luautils.box_sizexz(parms.isect_minp,parms.isect_maxp)
	local minposxz = {x=parms.isect_minp.x, y=parms.isect_minp.z}

	nvals_heat = minetest.get_perlin_map(np_heat, isectsize):get_2d_map_flat(minposxz)

	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			local bi=get_biome(nixz)
			local top=parms.share.surface[z][x]
			local vi = parms.area:index(x, top, z) -- This accesses the node at a given position
			parms.data[vi]=biome[bi].under
			if math.random(1000)<=biome[bi].treechance then biome[bi].tree(x,top+1,z,parms.area,parms.data) end 
			nixz=nixz+1
		end --for x
	end --for z
--store dirttop in parms.share so it can be passed to a decoration/biome generator
parms.share.surface=dirttop


	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("gen_bg_basic_biomes-> END isect="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_very_simple

realms.register_rmg("bg_basic_biomes",gen_bg_basic_biomes)


