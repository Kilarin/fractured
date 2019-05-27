bf_generic={}

--this biome generator should be called once per chunk to build a biome map
--that will provide your landscape generator with

local c_mese = minetest.get_content_id("default:Mese")
local c_dirt = minetest.get_content_id("default:dirt")


--1 octave on both of these so that the noise range is 0 to 1
--bf_generic.np_heat = {
realms.register_noise("Map2dHeat01",{
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 1,
	persist = 0.2,
	seed = 928349
})


--bf_generic.np_humid = {
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
	--get noise details
	local np_heat=realms.get_noise(parms.noiseheat,"Map2dHeat01",seed)
	local np_humid=realms.get_noise(parms.noisehumid,"Map2dHumid01",seed)
	local np_filler_dep=realms.get_noise(parms.noisefil,"FillerDep01",seed)
	local np_top_dep=realms.get_noise(parms.noisetop,"TopDep01",seed) --will also use for rare cases where top depth is needed
	
	local heat_map = minetest.get_perlin_map(np_heat, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local humid_map= minetest.get_perlin_map(np_humid, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local filler_noise= minetest.get_perlin_map(np_filler_dep, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	local top_noise=minetest.get_perlin_map(np_top_dep, parms.isectsize2d):get_2d_map_flat(parms.minposxz)
	--*!* consider for future, why have this as two steps?  realms.get_noise2d should return the 2d_map_flat (pass it parms)
	if biomemap.make_ocean_sand==true then parms.share.make_ocean_sand=true end
	
	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			--this function uses a 2d array for biomes instead of voronoi mapping because
			--1: it might make it easier to distribute biomes easily
			--2: voronoi mapping is complex, (unless you just do brute force)  this is lazier.
			--need to implement voronoi version later
			local biome
			if biomemap.typ=="MATRIX" then
				local n_heat = math.floor(math.abs(heat_map[nixz])*biomemap.heatrange)+1
				local n_humid = math.floor(math.abs(humid_map[nixz])*biomemap.humidrange)+1
				biome=biomemap.biome[n_heat][n_humid]
			elseif biomemap.typ=="VORONOI" then
				--get the noise
				local n_heat = math.abs(heat_map[nixz])
				local n_humid = math.abs(humid_map[nixz])
				--get our coords on the voronoi diagram (actually the vbox this coord is in)
				local vx=math.floor(n_heat*realms.vboxsz)
				local vz=math.floor(n_humid*realms.vboxsz)
				local voronoi=biomemap.voronoi[vx][vz]
				--the minetest wiki says: Limits are relative to y = water_level - 1
				local y=parms.share.surface[z][x].top
				local compy=y-parms.sealevel-1
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


--realms.register_mapfunc("bf_generic",bf_basic_biomes.bf_basic_biomes)


