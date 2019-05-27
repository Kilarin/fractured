bm_basic_biomes={}
bm_basic_biomes.name="bm basic biomes"
bm_basic_biomes.make_ocean_sand=true

bm_basic_biomes.typ="MATRIX"
bm_basic_biomes.heatrange=5
bm_basic_biomes.humidrange=5
local arctic=realms.biome.basic_arctic
local cold  =realms.biome.basic_cold
local warm  =realms.biome.basic_warm
local hot   =realms.biome.basic_hot
local desert=realms.biome.basic_desert
bm_basic_biomes.biome={
		{arctic, arctic, cold  , cold  , warm  },
		{arctic, cold  , cold  , warm  , warm  },
		{cold  , cold  , warm  , warm  , warm  },
		{hot   , hot   , hot   , hot   , warm  },
		{desert, desert, desert, hot   , hot   }
		}


--********************************
function bm_basic_biomes.bm_basic_biomes(parms)
bf_generic.map_biome_to_surface(parms,bm_basic_biomes)
end -- bf_basic_biomes

realms.register_mapfunc("bm_basic_biomes",bm_basic_biomes.bm_basic_biomes)
