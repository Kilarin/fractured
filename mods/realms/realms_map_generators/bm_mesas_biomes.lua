--[[
A biome map (bm_*) collects a group of biomes from biome definition files (could be all from the
same or could be from different ones) and decides how to map them to the world surface.
A biome map provides a list of biomes, and a biome function that maps those biomes to the surface.
Like most biome maps, this one uses bf_generic.map_biome_to_surface for its biome function.

This biome map is unusual in that it doesnt use MATRIX or VORONOI to distrube the biomes,
instead it picks a biome randomly from a list using chunk_seed as the seed to the random number
generator.  This is used for tg_mesas, and thats probably the only place it will ever be used.

This biome map combines the primary biomes from bd_default with biomes from bd_odd, and doubles 
the chances of getting an odd biome by listing them twice in the array

--]]



bm_mesas_biomes={}

bm_mesas_biomes.name="default_biomes_map"


bm_mesas_biomes.typ="RANDOM"
bm_mesas_biomes.biome={
	realms.biome.default_icesheet_shallow,
	realms.biome.default_tundra,
	realms.biome.default_taiga,
	realms.biome.default_snowy_grassland,
	realms.biome.default_grassland,
	realms.biome.default_grassland_dunes,
	realms.biome.default_coniferous_forest,
	realms.biome.default_coniferous_forest_dunes,
	realms.biome.default_deciduous_forest,
	realms.biome.default_desert,
	realms.biome.default_sandstone_desert,
	realms.biome.default_cold_desert,
	realms.biome.default_savanna,
	realms.biome.default_rainforest,
	realms.biome.odd_crystal,
	realms.biome.odd_mushroom,
	realms.biome.odd_scorched,
	realms.biome.odd_golden,
	realms.biome.odd_rainbow,
	realms.biome.odd_crystal,
	realms.biome.odd_mushroom,
	realms.biome.odd_scorched,
	realms.biome.odd_golden,
	realms.biome.odd_rainbow,
	}


realms.register_biomemap(bm_mesas_biomes)



--********************************
function bm_mesas_biomes.bm_mesas_biomes(parms)
	--bf_generic.map_biome_to_surface(parms,bm_mesas_biomes)
	--not this one, this one we just call ONCE and calculate ONCE and return ONCE
	--I'm not even going to use heat/humidity for it
	math.randomseed(parms.chunk_seed) --will be unique per chunk
	return bm_mesas_biomes.biome[math.random(1,#bm_mesas_biomes.biome)]
end -- bm_mesas_biomes

realms.register_mapfunc("bm_mesas_biomes",bm_mesas_biomes.bm_mesas_biomes)
