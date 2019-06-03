--[[
A biome map (bm_*) collects a group of biomes from biome definition files (could be all from the
same or could be from different ones) and decides how to map them to the world surface.
A biome map provides a list of biomes, and a biome function that maps those biomes to the surface.
Like most biome maps, this one uses bf_generic.map_biome_to_surface for its biome function.

There are two primary biome map types.  "MATRIX" and "VORONOI"  this is an example of MATRIX.

MATRIX is very simple to implement, you just build a matrix and populate it with the biomes you
want.  It gives you complete and easy control over what percentage of the world will be what biome.
The disadvantage is that it does not create as natural of a distribution as VORONOI, and your biomes
have to set up "alternate" lists of repalcement biomes if the primary biome is outside of its y 
range.

--]]


bm_basic_biomes={}
bm_basic_biomes.name="basic biomes map"

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


realms.register_biomemap(bm_basic_biomes)


--********************************
function bm_basic_biomes.bm_basic_biomes(parms)
bf_generic.map_biome_to_surface(parms,bm_basic_biomes)
end -- bf_basic_biomes

realms.register_mapfunc("bm_basic_biomes",bm_basic_biomes.bm_basic_biomes)

