bm_shattered_biomes={}

bm_shattered_biomes.name="default_biomes_map"





bm_shattered_biomes.typ="RANDOM"
bm_shattered_biomes.biome={
	realms.biome.default_icesheet,
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


realms.register_biomemap(bm_shattered_biomes)



--********************************
function bm_shattered_biomes.bm_shattered_biomes(parms)
	--bf_generic.map_biome_to_surface(parms,bm_shattered_biomes)
	--not this one, this one we just call ONCE and calculate ONCE and return ONCE
	--I'm not even going to use heat/humidity for it
	math.randomseed(parms.chunk_seed) --will be unique per chunk
	return bm_shattered_biomes.biome[math.random(1,#bm_shattered_biomes.biome)]
end -- bm_shattered_biomes

realms.register_mapfunc("bm_shattered_biomes",bm_shattered_biomes.bm_shattered_biomes)
