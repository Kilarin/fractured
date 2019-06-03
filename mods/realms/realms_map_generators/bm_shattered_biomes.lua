--[[
A biome map (bm_*) collects a group of biomes from biome definition files (could be all from the
same or could be from different ones) and decides how to map them to the world surface.
A biome map provides a list of biomes, and a biome function that maps those biomes to the surface.

There are two primary biome map types.  "MATRIX" and "VORONOI"  this is an example of MATRIX.

MATRIX is very simple to implement, you just build a matrix and populate it with the biomes you
want.  It gives you complete and easy control over what percentage of the world will be what biome.
The disadvantage is that it does not create as natural of a distribution as VORONOI, and your biomes
have to set up "alternate" lists of repalcement biomes if the primary biome is outside of its y 
range.

this biome maps does NOT use the generic biome function.  Because this one sort of cheats.
it detects if the noise comes near the edge of a biome, and changes top to turn it into
a chasm.  This creates a strange looking world of isolated biomes separated by deep chasms,
somewhat remenicent of Sanderson's "Shattered Plains"  (only very somewhat)

My first approach at making a shatterds plane generator was tg_mesas.  Which I thought
looked pretty cool.  My son looked at it, said, "yes, it does look cool, but it would look a lot
more like the shattered plains if you did..." and described this functionality.  I said, "Nah, that
wouldnt... hmmm, let me see"  I tried it, and well, I think it DOES look better.  

So now I have two generators that create landscapes with deep chasms.  The world is big, it can
handle two of them.

--]]



bm_shattered_biomes={}

bm_shattered_biomes.name="shattered biomes map"

local icesheet    = realms.biome.default_icesheet
local tundra      = realms.biome.default_tundra
local taiga       = realms.biome.default_taiga
local snowy_grass = realms.biome.default_snowy_grassland
local grassland   = realms.biome.default_grassland
local grassland_d = realms.biome.default_grassland_dunes
local conif_for   = realms.biome.default_coniferous_forest
local conif_dune  = realms.biome.default_coniferous_forest_dunes
local decid_for   = realms.biome.default_deciduous_forest
local desert      = realms.biome.default_desert
local sandstone_d = realms.biome.default_sandstone_desert
local cold_desert = realms.biome.default_cold_desert
local savanna     = realms.biome.default_savanna
local rainforest  = realms.biome.default_rainforest
local crystal     = realms.biome.odd_crystal  
local mushroom    = realms.biome.odd_mushroom 
local scorched    = realms.biome.odd_scorched 
local golden      = realms.biome.odd_golden   
local rainbow     = realms.biome.odd_rainbow  


bm_shattered_biomes.heatrange=5
bm_shattered_biomes.humidrange=5
bm_shattered_biomes.typ="MATRIX"
bm_shattered_biomes.biome={
	{icesheet   ,crystal    ,tundra     ,mushroom   ,taiga      },
	{scorched   ,snowy_grass,grassland  ,rainbow    ,grassland_d},
	{golden     ,conif_for  ,crystal    ,conif_dune ,rainforest },
	{decid_for  ,desert     ,mushroom   ,sandstone_d,rainbow    },
	{cold_desert,golden     ,savanna    ,rainbow    ,scorched   },
	}



realms.register_noise("Map2dHeat02",{
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
--spread = {x=128, y=128, z=128},
	octaves = 3,
	persist = 0.6,
	seed = 928349
})


realms.register_noise("Map2dHumid02",{
	offset = 0,
	scale = 1,
--spread = {x=256, y=256, z=256},
	spread = {x=412, y=412, z=412},
	octaves = 3,
	persist = 0.6,
	seed = 2872
})



realms.register_biomemap(bm_shattered_biomes)



--********************************
function bm_shattered_biomes.bm_shattered_biomes(parms)
	biomemap=bm_shattered_biomes
	local edge=0.08
	local edgehe=(1/biomemap.heatrange)*edge
	local edgehu=(1/biomemap.humidrange)*edge
	--minetest.log(" edgehe="..edgehe.." edgehu="..edgehu)
	local changeheight=20

	--bf_generic.map_biome_to_surface(parms,bm_shattered_biomes)
	--this biome map does some strange stuff, so it can't use bf_generic
	--NOTE: our default_seed is the realm_seed, so that each realm will have unique noise.
	--If you want two different realm entries to use the same noise, you must set parms.seed
	local heat_map    = realms.get_noise2d(parms.noiseheat ,"Map2dHeat02" ,parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local humid_map   = realms.get_noise2d(parms.noisehumid,"Map2dHumid02",parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local filler_noise= realms.get_noise2d(parms.noisefil  ,"FillerDep01" ,parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local top_noise   = realms.get_noise2d(parms.noisetop  ,"TopDep01"    ,parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)

	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			local srfc=parms.share.surface[z][x]
			local biome

			local noisehe=math.abs(heat_map[nixz])
			local noisehu=math.abs(humid_map[nixz])
			if noisehe>=1 then noisehe=1-(noisehe-1) end
			if noisehu>=1 then noisehu=1-(noisehu-1) end
			local n_heat = math.floor(noisehe*biomemap.heatrange)+1
			local n_humid = math.floor(noisehu*biomemap.humidrange)+1
			--minetest.log("shattered->>> heat="..heat_map[nixz].." humd="..humid_map[nixz].." n_heat="..n_heat.." n_humid="..n_humid)
			local bfr=srfc.top
			if math.floor((noisehe+edgehe)*biomemap.heatrange)+1~=n_heat or math.floor((noisehe-edgehe)*biomemap.heatrange)+1~=n_heat
					or math.floor((noisehu+edgehu)*biomemap.humidrange)+1~=n_humid or math.floor((noisehu-edgehu)*biomemap.humidrange)+1~=n_humid then
				srfc.biome=realms.undefined_underwater_biome
				srfc.top=srfc.top-changeheight
			else
				srfc.biome=biomemap.biome[n_heat][n_humid]
				srfc.top=srfc.top+changeheight
			end --if math.floor
			--minetest.log("shattered -> srfc.top.bfr="..bfr.." aft="..srfc.top.." biome="..srfc.biome.name)

			--I like these depths to have a bit of variation in them:
			if srfc.biome.node_water_top~=nil then
				srfc.water_top_depth=realms.randomize_depth(srfc.biome.depth_water_top,0.33,top_noise[nixz])
			end --water_top
			srfc.top_depth=realms.randomize_depth(srfc.biome.depth_top,0.33,top_noise[nixz])
			srfc.filler_depth=realms.randomize_depth(srfc.biome.depth_filler,0.33,filler_noise[nixz])

			--minetest.log("bf_generic.map_biome_to_surface->    n_heat="..n_heat.." n_humid="..n_humid.." biome="..biome.name)
			nixz=nixz+1
		end --for x
	end --for z

minetest.log("bm_shattered -> "..luautils.pos_to_str(parms.isect_minp).." biome map="..biomemap.name.."   END")
end -- bm_shattered_biomes

realms.register_mapfunc("bm_shattered_biomes",bm_shattered_biomes.bm_shattered_biomes)
