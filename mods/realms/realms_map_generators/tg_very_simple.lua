tg_very_simple={}

local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_dirt_grass = minetest.get_content_id("default:dirt_with_grass")
local c_air = minetest.get_content_id("air")
local c_water_source = minetest.get_content_id("default:water_source")
local c_sand = minetest.get_content_id("default:sand")

tg_very_simple.np_ground_top = {
	offset = 0,
	scale = 1,
	spread = {x=500, y=500, z=500},
	octaves = 5,
	seed = 5342345987, --this will be added to world seed
	persist = 0.63,
--	flags = "defaults, absvalue"
}

tg_very_simple.np_ground_bot = {
	offset = 0,
	scale = 1,
	spread = {x=300, y=500, z=300},
	octaves = 3,
	seed = 138765212, --this will be added to world seed
	persist = 0.50,
--	flags = "defaults, absvalue"
}

--********************************
function tg_very_simple.gen_tg_very_simple(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()

	--get optional parms and set defaults if they dont exist
	local height_base=parms.height_base
	if height_base==nil then height_base=30 end
	local sea_percent=parms.sea_percent
	if sea_percent==nil then sea_percent=25 end
	sea_percent=sea_percent/100



	--we calculate the surface top and bot first
	--because we need to loop through the voxels in z,y,x order for efficency
	--but we only want to do the calculations for top and bot y once per x,z coord
	--the simplest way to do that is to calucate them first
	--we load our perlin noise as flat because, well, quite frankly, because
	--everyone else does it that way, so I assume it's more efficent.  So instead of
	--and x,z array, we have one array that goes from 1 to isectsize2d.x*isectsize2d.y
	--one noise determines our dirt top, the other the dirt bot, so they will be different
	local noisetop = minetest.get_perlin_map(tg_very_simple.np_ground_top, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local noisebot = minetest.get_perlin_map(tg_very_simple.np_ground_bot, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local surface={}
	--local surface_in_this_chunk=false

	--*!*debugging
	local ntlo=999
	local nthi=-999

	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		surface[z]={}
		for x=parms.isect_minp.x, parms.isect_maxp.x do

			--*!*debugging
			if noisetop[nixz]>nthi then nthi=noisetop[nixz] end
			if noisetop[nixz]<ntlo then ntlo=noisetop[nixz] end

			--we are going to set the surface level based on noise (noise should be -1 to +1 but might be -2 to +2)
			--dirt_height is the value for how high the terrain should be at this point.
			--dirt_height should be a spread from a negative low to a positive high
			local dirt_height=height_base*noisetop[nixz]

			--if you just added dirt_height to sea_level you would get a world that was 50% below sea level
			--the user might want a world with a lot less (or more) water, so we figure sea_adj:
			--sea_adj is an offset to sealevel that gives us the percentage water we want (after adding dirt_height)
			--(example if height_base=30, sea_percent=25, and sealevel=0 then sea_adj=15 because
			-- 0+15-30=-15 and 0+15+30=45, so 25% of the world will be below sea level)
			local sea_adj=height_base-2*height_base*sea_percent

			--so final value for top is the sea level, offest by sea_adj, plus dirt_height
			surface[z][x]={}
			surface[z][x].top=math.floor(parms.sealevel+sea_adj+dirt_height)
			surface[z][x].bot=surface[z][x].top-math.floor(math.abs(20*noisebot[nixz]))
			--the below will be overridden if you have a biomefunc
      surface[z][x].biome=realms.undefined_biome

			nixz=nixz+1
		end --for x
	end --for z


	--the below will add surface.biome, node_top, node_filler, and decorate (function)
	parms.share.surface=surface --got to share it so the biomefunc can update it
	if parms.biomefunc~=nil then realms.rmf[parms.biomefunc](parms) end

--*!* so should I just exit here if we know we are above the surface?

--here is where we actually do the work of generating the landscape.
--we loop through as z,y,x because that is way the voxel info is stored, so it is most efficent.
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				--anything lower than our surface bottom is stone
				if y<surface[z][x].bot then luautils.place_node(x,y,z, parms.area, parms.data, c_stone)
				--anything between surface bottom and top (and not under sealevel) gets the under node (biome based)
				elseif y<surface[z][x].top and surface[z][x].top>=parms.sealevel then
				  luautils.place_node(x,y,z, parms.area, parms.data, surface[z][x].biome.node_filler)
				--if we are going to be under water, put sand instead of an under OR top node
				--(could change this with a more complicated biome system later that had underwater biomes)
				elseif y<=surface[z][x].top and surface[z][x].top<parms.sealevel then
					luautils.place_node(x,y,z, parms.area, parms.data, c_sand)
				--if this is the top, set top node (biome based) and ALSO call the decorate function (if it exists)
				elseif y==surface[z][x].top then
					luautils.place_node(x,y,z, parms.area, parms.data, surface[z][x].biome.node_top)
					if surface[z][x].biome.decorate~=nil then surface[z][x].biome.decorate(x,y+1,z, surface[z][x].biome, parms) end
				--and if we are above the top, but under sea level, put water
				elseif y>surface[z][x].top and y<=parms.sealevel then
					luautils.place_node(x,y,z, parms.area, parms.data, c_water_source)
				--putting air just messes up the decorations since we work our way from bot to top
				--elseif y>dirttop[z][x] then luautils.place_node(x,y,z, parms.area, parms.data, c_air)
				end --if y
			end --for x
		end --for y
	end --for z

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("gen_tg_very_simple-> END isect="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms" --) --tell people how long
		.." noise-> ntlo="..ntlo.." nthi="..nthi) --*!*debugging
end -- gen_very_simple

realms.register_mapgen("tg_very_simple",tg_very_simple.gen_tg_very_simple)


