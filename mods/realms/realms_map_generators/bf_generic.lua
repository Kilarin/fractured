bf_generic={}

--this biome generator should be called once per chunk to build a biome map
--that will provide your landscape generator with

local c_mese = minetest.get_content_id("default:Mese")
local c_dirt = minetest.get_content_id("default:dirt")


--1 octave on both of these so that the noise range is 0 to 1
realms.register_noise("Map2dHeat01",{
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 1,
	persist = 0.2,
	seed = 928349
})


realms.register_noise("Map2dHumid01",{
	offset = 0,
	scale = 1,
	spread = {x=412, y=412, z=412},
	octaves = 1,
	persist = 0.3,
	seed = 2872
})


realms.register_noise("FillerDep01",{
	offset = 0,
	scale = 1,
	spread = {x=30, y=50, z=30},
	octaves = 3,
	seed = 138765212, --this will be added to world seed
	persist = 0.50,
--	flags = "defaults, absvalue"
})

realms.register_noise("TopDep01",{
	offset = 0,
	scale = 1,
	spread = {x=10, y=10, z=10},
	octaves = 1,
	seed = 873423, --this will be added to world seed
	persist = 0.50,
})



--********************************
function bf_generic.map_biome_to_surface(parms,biomemap)
--[[
	--get noise details
	local np_heat=realms.get_noise(parms.noiseheat,"Map2dHeat01",parms.seed)
	local np_humid=realms.get_noise(parms.noisehumid,"Map2dHumid01",parms.seed)
	local np_filler_dep=realms.get_noise(parms.noisefil,"FillerDep01",parms.seed)
	local np_top_dep=realms.get_noise(parms.noisetop,"TopDep01",parms.seed) --will also use for rare cases where top depth is needed

	local heat_map = minetest.get_perlin_map(np_heat, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local humid_map= minetest.get_perlin_map(np_humid, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local filler_noise= minetest.get_perlin_map(np_filler_dep, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local top_noise=minetest.get_perlin_map(np_top_dep, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
--]]

	--NOTE: our default_seed is the realm_seed, so that each realm will have unique noise.
	--If you want two different realm entries to use the same noise, you must set parms.seed
	local heat_map    = realms.get_noise2d(parms.noiseheat ,"Map2dHeat01" ,parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local humid_map   = realms.get_noise2d(parms.noisehumid,"Map2dHumid01",parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local filler_noise= realms.get_noise2d(parms.noisefil  ,"FillerDep01" ,parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local top_noise   = realms.get_noise2d(parms.noisetop  ,"TopDep01"    ,parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)

	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			--compy is the y value we will be comparing y_min and y_max to
			--the minetest wiki says: Limits are relative to y = water_level - 1
			local y=parms.share.surface[z][x].top
			local compy=y-parms.sealevel-1

			local biome
			if biomemap.typ=="MATRIX" then
			--MATRIX uses a 2d array for biomes instead of voronoi mapping because
			--it might make it easier to control the distribution of biomes
			--the 2d noise (x=heat z=humidity) maps directly to the matrix and determines which biome you are in
			--you will notice that because of the cheating way I implemented VORONOI, these two different biomemap
			--types end up working almost the same way.
				local n_heat = math.floor(math.abs(heat_map[nixz])*biomemap.heatrange)+1
				local n_humid = math.floor(math.abs(humid_map[nixz])*biomemap.humidrange)+1
				biome=biomemap.biome[n_heat][n_humid] --set to the primary biome, will change later if y_min/y_max dont fit

				--now we have determined which matrix box we are in, we need to check the y_min/y_max limits
				--if the primary does not match our y range, loop through the alternates until we find one that does
				if biome.alternates~=nil and (compy<biome.y_min or compy>biome.y_max) then
					local i=1
					while ( compy<biome.alternates[i].y_min or compy>biome.alternates[i].y_max )
							and i<#biome.alternates do
						i=i+1
					end--while
				--if it doesnt match anything, you did something very wrong with your biomes
				--but we will just pick up the last item in the list
				biome=biome.alternates[i]
				end--if compy

			elseif biomemap.typ=="VORONOI" then
				--VORONOI gives each biome a heat/humidity point (set in biomemap, NOT in biome definition!)
				--the biome chosen is whichever one has a heat/humidity point that is the closest distance to
				--our 2d noise (x=heat z=humidity)
				--BUT, recalculating the distance to all the biomes is SLOW, so I've cheated and when you
				--register_biomemap it builds a matrix and pre-calculates the distance to each biome from the
				--center of each matrix box.  Its not a bad estimate of a true voronoi, and it pretty fast.
				--
				--get the noise
				local n_heat = math.abs(heat_map[nixz])
				local n_humid = math.abs(humid_map[nixz])
				--get our coords on the voronoi diagram (actually the vbox this coord is in)
				local vx=math.floor(n_heat*realms.vboxsz)
				local vz=math.floor(n_humid*realms.vboxsz)
				local voronoi=biomemap.voronoi[vx][vz]
				--now we have determined which vbox we are in, and we have the list of biomes
				--sorted by distance from the center of that vbox.  We need to find the first
				--one that is in our y range
				local i=1
				while compy<voronoi[i].y_min or compy>voronoi[i].y_max and i<#voronoi do i=i+1 end
				--if it doesnt match anything, you did something very wrong with your biomes
				--but we will just pick up the last item in the list
				biome=voronoi[i]
				--minetest.log("map_biome_to_surface-> "..luautils.pos_to_str_xyz(x,y,z).." compy="..compy.." vx="..vx.." vz="..vz.." biome="..biome.name.." i="..i)
			end --if biomemap.typ

			parms.share.surface[z][x].biome=biome
			
			--if user set flag make_ocean_sand=true in the biomemap, then we ignore biomes below sea level
			--and just make everything into sand.  Its not very versatile, but it makes setting up simple biomes easy
			if biomemap.make_ocean_sand==true and parms.share.surface[z][x].top<=parms.sealevel then
				parms.share.surface[z][x].biome=realms.undefined_underwater_biome
			end --if make_ocean_sand

			--I like these depths to have a bit of variation in them:
			if biome.node_water_top~=nil then
				parms.share.surface[z][x].water_top_depth=realms.randomize_depth(biome.depth_water_top,0.33,top_noise[nixz])
			end --water_top
			parms.share.surface[z][x].top_depth=realms.randomize_depth(biome.depth_top,0.33,top_noise[nixz])
			parms.share.surface[z][x].filler_depth=realms.randomize_depth(biome.depth_filler,0.33,filler_noise[nixz])

			--minetest.log("bf_generic.map_biome_to_surface->    n_heat="..n_heat.." n_humid="..n_humid.." biome="..biome.name)
			nixz=nixz+1
		end --for x
	end --for z


	

minetest.log("bf_generic.map_biome_to_surface-> "..luautils.pos_to_str(parms.isect_minp).." biome map="..biomemap.name.."   END")
end --get_biome





