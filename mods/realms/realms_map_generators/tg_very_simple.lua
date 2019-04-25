local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_air = minetest.get_content_id("air")

np_ground_top = { 
	offset = 0,
	scale = 1,
	spread = {x=500, y=500, z=500},
	octaves = 5,
	seed = 5342345987, --this will be added to world seed
	persist = 0.63,
	flags = "defaults, absvalue"
}

np_ground_bot = { 
	offset = 0,
	scale = 1,
	spread = {x=300, y=500, z=300},
	octaves = 3,
	seed = 138765212, --this will be added to world seed
	persist = 0.50,
	flags = "defaults, absvalue"
}

--********************************
function gen_tg_very_simple(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()

	--minetest.log("gen_tg_very_simple-> realm minp="..luautils.pos_to_str(parms.realm_minp).." maxp="..luautils.pos_to_str(parms.realm_maxp)..
	--" chunk minp="..luautils.pos_to_str(parms.chunk_minp).." maxp="..luautils.pos_to_str(parms.chunk_maxp))
	--minetest.log("    intersection minp="..luautils.pos_to_str(parms.isect_minp).." maxp="..luautils.pos_to_str(parms.isect_maxp).." surfacey="..parms.surfacey)

	--get noise details
	local isectsize = luautils.box_sizexz(parms.isect_minp,parms.isect_maxp)
	local minposxz = {x=parms.isect_minp.x, y=parms.isect_minp.z}
	--minetest.log("gen_tg_very_simple-> isectsize="..luautils.pos_to_str(isectsize).." minposxz x="..minposxz.x.." y="..minposxz.y)

	--we calculate the surface top and bot first
	--because we need to loop through the voxels in z,y,x order for efficency
	--but we only want to do the calculations for top and bot y once per x,z coord
	--the simplest way to do that is to calucate them first
	--we load our perlin noise as flat because, well, quite frankly, because 
	--everyone else does it that way, so I assume it's more efficent.  So instead of
	--and x,z array, we have one array that goes from 1 to isectsize.x*isectsize.y 
	--one noise determines our dirt top, the other the dirt bot, so they will be different
	local noisetop = minetest.get_perlin_map(np_ground_top, isectsize):get_2d_map_flat(minposxz)
	local noisebot = minetest.get_perlin_map(np_ground_bot, isectsize):get_2d_map_flat(minposxz)	
	local dirttop={}
	local dirtbot={}
	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		dirttop[z]={}
		dirtbot[z]={}
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			dirttop[z][x]=math.floor(parms.surfacey+(30*noisetop[nixz]))
			dirtbot[z][x]=dirttop[z][x]-math.floor(math.abs(20*noisebot[nixz]))
			nixz=nixz+1
		end --for x
	end --for z
--store dirttop in parms.share so it can be passed to a decoration/biome generator
parms.share.surface=dirttop

--here is where we actually do the work of generating the landscape.
--we loop through as z,y,x because that is way the voxel info is stored, so it is most efficent.
	local material=c_stone
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				if y<dirtbot[z][x] then material=c_stone
				elseif y<dirttop[z][x] then material=c_dirt
				elseif y==dirttop[z][x] then material=c_grass
				elseif y>dirttop[z][x] then material=c_air
				end --if y
				local vi = parms.area:index(x, y, z) -- This accesses the node at a given position
				parms.data[vi]=material
			end --for x
		end --for x
	end --for z


	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("gen_tg_very_simple-> END chunk="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_very_simple

realms.register_rmg("tg_very_simple",gen_tg_very_simple)


