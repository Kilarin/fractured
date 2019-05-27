tg_with_mountains={}

local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_dirt_grass = minetest.get_content_id("default:dirt_with_grass")
local c_air = minetest.get_content_id("air")
local c_water_source = minetest.get_content_id("default:water_source")
local c_sand = minetest.get_content_id("default:sand")


realms.register_noise("Map2dTop01",{
	offset = 0,
	scale = 1,
	spread = {x=500, y=500, z=500},
	octaves = 5,
	seed = 5342345987, --this will be added to world seed
	persist = 0.63,
--	flags = "defaults, absvalue"
})


realms.register_noise("Map2dExt01",{
	offset = 0,
	scale = 1,
	spread = {x=200, y=600, z=200},
	octaves = 3,
	seed = 762643748, --this will be added to world seed
	persist = 0.40,
	flags = "defaults, absvalue"
}) --range on this should be about 1.56


realms.register_noise("Map2dCan01",{
	offset = 0,
	scale = 1,
	spread = {x=100, y=100, z=100},
	octaves = 4,
	seed = 129384110, --this will be added to world seed
	persist = 0.75,
	lacunarity  = 2.0,
	flags = "defaults, absvalue"
})





--********************************
function tg_with_mountains.gen_tg_with_mountains(parms)
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
	
	--NOTE: we pass the realm_seed, so that each realm will have unique noise.
	--If you want two different realm entries to use the same noise, you must set the seed parameter.
	local seed=parms.seed
	if seed==nil then seed=parms.realm_seed end
	local np_ground_top=realms.get_noise(parms.noisetop,"Map2dTop01",seed)
	local np_extremes=realms.get_noise(parms.noiseext,"Map2dExt01",seed)
	local np_canyons=realms.get_noise(parms.noisecan,"Map2dCan01",seed)

	
	--local np_ground_top=realms.get_noise(parms.noisetop,"Map2dTop01")
	--local np_ground_bot=realms.get_noise(parms.noisebot,"Map2dBot01")
	--local np_extremes=realms.get_noise(parms.noiseext,"Map2dExt01")
	--local np_canyons=realms.get_noise(parms.noisecan,"Map2dCan01")
	
	local noisetop = minetest.get_perlin_map(np_ground_top, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	--local noisebot = minetest.get_perlin_map(np_ground_bot, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local noiseext = minetest.get_perlin_map(np_extremes, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local noiseCan = minetest.get_perlin_map(np_canyons, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	--local noiseDep = minetest.get_perlin_map(np_depth, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local surface = {}


	--*!*debugging
	local ntlo=999
	local nthi=-999
	local nmlo=999
	local nmhi=-999
	local nclo=999
	local nchi=-999

	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		surface[z]={}
		for x=parms.isect_minp.x, parms.isect_maxp.x do

			--*!*debugging
			if noisetop[nixz]>nthi then nthi=noisetop[nixz] end
			if noisetop[nixz]<ntlo then ntlo=noisetop[nixz] end
			if noiseext[nixz]>nmhi then nmhi=noiseext[nixz] end
			if noiseext[nixz]<nmlo then nmlo=noiseext[nixz] end
			if noiseCan[nixz]>nchi then nchi=noiseCan[nixz] end
			if noiseCan[nixz]<nclo then nclo=noiseCan[nixz] end

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

			--this creates a multiplier that creates plains and valleys by multiplying the base by another layer of noise
			local mult=1
			if parms.extremes~=nil then
				local ext=parms.extremes
				if type(ext)~="number" then ext=2 end
				local nm=noiseext[nixz]
				mult=(ext*nm)^2
			end --if parms.plains


			--so final value for top is the sea level, offest by sea_adj, plus dirt_height times mountain multiplier
			surface[z][x]={}
			surface[z][x].top=math.floor(parms.sealevel+sea_adj+dirt_height*mult)

			if parms.canyons==true then
				--BUT, now we are going to try and add canyons.
				--this does NOT make great canyons, but it does make sorta canyons, and interesting terrain.  And odd small deep holes.
				local can=noiseCan[nixz]
				local edge=0.5 --change this to play with different canyon shapes
				if can<edge and surface[z][x].top>parms.sealevel then --make a canyon/river
					local t=surface[z][x].top --just to make this more readable
					--so first .05 of the area is a sharp drop
					if can>=(edge-.05) then surface[z][x].top=t-(t-parms.sealevel)*(edge-can)*20
					--the bottom of the canyon should be made more dependent on noise, currently its just deepest at 0
					elseif can<(edge-.05) then surface[z][x].top=parms.sealevel-(10-((10/(edge-.05)*can)))
					end--if can>=(edge-.05)
					--minetest.log("***canyon-> x="..x.." z="..z.." was "..t.." now ".. surface[z][x].top)
				end--if can<edge
			end --if parms.canyons

			--surface[z][x].bot=surface[z][x].top-(3+math.floor(math.abs(20*noisebot[nixz]))) --*!* this should use filler_depth
			--*!* BUT there is a big problem, how can I use filler_depth when I haven't determined the biome yet!
			--mess with it later, other things more important right now
			
			--the below will be overridden if you have a biomefunc
      surface[z][x].biome=realms.dflt_biome
			nixz=nixz+1
		end --for x
	end --for z

	--the below will add surface.biome, node_top, node_filler, and decorate (function)
	parms.share.surface=surface --got to share it so the biomefunc can update it
	if parms.biomefunc~=nil then realms.rmf[parms.biomefunc](parms) end
	surface=parms.share.surface  --just in case the bf (biome func) replaced it
	--minetest.log("tg_with_mountains-> surface["..z.."]["..x.."].biome.node_top="..surface[z][x].biome.node_top.."   name="..surface[z][x].biome.name)

--here is where we actually do the work of generating the landscape.
--we loop through as z,y,x because that is way the voxel info is stored, so it is most efficent.
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				local sfc=surface[z][x]
				local biome=sfc.biome
				local sealevel=parms.sealevel
				if sfc.top_depth==nil then sfc.top_depth=1 end
				if sfc.filler_depth==nil then sfc.filler_depth=6 end
				sfc.top_bot=sfc.top+(sfc.top_depth-1)
				sfc.fil_bot=sfc.top_bot-sfc.filler_depth 
				if sfc.water_top_depth==nil then sfc.water_top_depth=9999 end

				--anything lower than our surface filler bottom gets node_stone from biome
				if y<sfc.fil_bot then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_stone)

				--for biome maps that do not provide underwater biomes (parms.share.make_ocean_sand==true)
				--if we are going to be under water, put sand instead of an under OR top node
				elseif parms.share.make_ocean_sand==true and y<=sfc.top and sfc.top<sealevel then
					luautils.place_node(x,y,z, parms.area, parms.data, c_sand)

				--anything between filler bottom and top bottom (and not under sealevel) gets the filler node (biome based)
				elseif y<sfc.top_bot then 
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)

				--for those rare cases where top_depth>1
				elseif y<sfc.top then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)

				--if this is the top, set top node (biome based) and ALSO call the decorate function (if it exists)
				elseif y==sfc.top then
					--minetest.log("tg_with_mountains->TOP surface["..z.."]["..x.."].biome.node_top="..biome.node_top.."   name="..biome.name)
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_top)
					if biome.decorate~=nil then biome.decorate(x,y+1,z, biome, parms) end

				--if we are at top+1 apply dust node (if it exists)
				elseif y==sfc.top+1 and sfc.top>sealevel and biome.node_dust~=nil then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_dust)

				--and if we are above the top, but under sea level, put water
				elseif y>sfc.top and y<=sealevel then
					local water_node=c_water_source
					if biome.node_water_top~=nil then
--						local nixz=luautils.xzcoords_to_flat(x,z, parms.isect_minp, parms.isectsize2d)
--						minetest.log("biome.node_water_top-> z="..z.." x="..x.." nixz="..nixz)
						--local depth_water_top=realms.randomize_depth(biome.depth_water_top,0.33,noiseDep,x,z,parms.isect_minp,parms.isectsize2d)
						if y>=sealevel-sfc.water_top_depth then water_node=biome.node_water_top end
					end --if biome.node_water_top~=nil
					luautils.place_node(x,y,z, parms.area, parms.data, water_node)
					
				--putting air just messes up the decorations since we work our way from bot to top
				--elseif y>dirttop[z][x] then luautils.place_node(x,y,z, parms.area, parms.data, c_air)
				end --if y
			end --for x
		end --for y
	end --for z


	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	ntlo=luautils.round_digits(ntlo,3)
	nthi=luautils.round_digits(nthi,3)
	nmlo=luautils.round_digits(nmlo,3)
	nmhi=luautils.round_digits(nmhi,3)
	nclo=luautils.round_digits(nclo,3)
	nchi=luautils.round_digits(nchi,3)
	minetest.log("gen_tg_with_mountains-> END isect="..luautils.pos_to_str(parms.isect_minp).."-"..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
	minetest.log("   noise-> ntlo="..ntlo.." nthi="..nthi.." : nmlo="..nmlo.." nmhi="..nmhi.." : nclo="..nclo.." nchi="..nchi) --*!*debugging
end -- gen_with_mountains

realms.register_mapgen("tg_with_mountains",tg_with_mountains.gen_tg_with_mountains)


