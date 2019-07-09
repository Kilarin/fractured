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

this biome map combines biomes from bd_basic and bd_odd

--]]


bm_mixed_biomes={}

bm_mixed_biomes.name="bm basic biomes"
--bm_mixed_biomes.make_ocean_sand=true

local icesheet                = realms.biome.default_icesheet
local icesheet_ocean          = realms.biome.default_icesheet_ocean
local tundra_highland         = realms.biome.default_tundra_highland
local tundra                  = realms.biome.default_tundra
local tundra_beach            = realms.biome.default_tundra_beach
local tundra_ocean            = realms.biome.default_tundra_ocean
local taiga                   = realms.biome.default_taiga
local taiga_ocean             = realms.biome.default_taiga_ocean
local snowy_grassland         = realms.biome.default_snowy_grassland
local snowy_grassland_ocean   = realms.biome.default_snowy_grassland_ocean
local grassland               = realms.biome.default_grassland
local grassland_dunes         = realms.biome.default_grassland_dunes
local grassland_ocean         = realms.biome.default_grassland_ocean
local coniferous_forest       = realms.biome.default_coniferous_forest
local coniferous_forest_dunes = realms.biome.default_coniferous_forest_dunes
local coniferous_forest_ocean = realms.biome.default_coniferous_forest_ocean
local deciduous_forest        = realms.biome.default_deciduous_forest
local deciduous_forest_shore  = realms.biome.default_deciduous_forest_shore
local deciduous_forest_ocean  = realms.biome.default_deciduous_forest_ocean
local desert                  = realms.biome.default_desert
local desert_ocean            = realms.biome.default_desert_ocean
local sandstone_desert        = realms.biome.default_sandstone_desert
local sandstone_desert_ocean  = realms.biome.default_sandstone_desert_ocean
local cold_desert             = realms.biome.default_cold_desert
local cold_desert_ocean       = realms.biome.default_cold_desert_ocean
local savanna                 = realms.biome.default_savanna
local savanna_shore           = realms.biome.default_savanna_shore
local savanna_ocean           = realms.biome.default_savanna_ocean
local rainforest              = realms.biome.default_rainforest
local rainforest_swamp        = realms.biome.default_rainforest_swamp
local rainforest_ocean        = realms.biome.default_rainforest_ocean
local underground             = realms.biome.default_underground
local crystal                 = realms.biome.odd_crystal
local mushroom                = realms.biome.odd_mushroom
local scorched                = realms.biome.odd_scorched
local golden                  = realms.biome.odd_golden
local rainbow                 = realms.biome.odd_rainbow

bm_default_biomes.typ="VORONOI"
bm_default_biomes.list={
		{biome=icesheet                ,heat_point =  0,humidity_point = 73},
		{biome=icesheet_ocean          ,heat_point =  0,humidity_point = 73},
		
		{biome=tundra_highland         ,heat_point =  0,humidity_point = 40},
		{biome=tundra                  ,heat_point =  0,humidity_point = 40},
		{biome=tundra_beach            ,heat_point =  0,humidity_point = 40},
		{biome=tundra_ocean            ,heat_point =  0,humidity_point = 40},
		
		{biome=taiga                   ,heat_point = 25,humidity_point = 70},
		{biome=taiga_ocean             ,heat_point = 25,humidity_point = 70},
		
		{biome=snowy_grassland         ,heat_point = 20,humidity_point = 35},
		{biome=snowy_grassland_ocean   ,heat_point = 20,humidity_point = 35},
		
		{biome=grassland               ,heat_point = 50,humidity_point = 35},
		{biome=grassland_dunes         ,heat_point = 50,humidity_point = 35},
		{biome=grassland_ocean         ,heat_point = 50,humidity_point = 35},
		
		{biome=coniferous_forest       ,heat_point = 45,humidity_point = 70},
		{biome=coniferous_forest_dunes ,heat_point = 45,humidity_point = 70},
		{biome=coniferous_forest_ocean ,heat_point = 45,humidity_point = 70},
		
		{biome=deciduous_forest        ,heat_point = 60,humidity_point = 68},
		{biome=deciduous_forest_shore  ,heat_point = 60,humidity_point = 68},
		{biome=deciduous_forest_ocean  ,heat_point = 60,humidity_point = 68},
		
		{biome=desert                  ,heat_point = 92,humidity_point = 16},
		{biome=desert_ocean            ,heat_point = 92,humidity_point = 16},
		
		{biome=sandstone_desert        ,heat_point = 60,humidity_point =  0},
		{biome=sandstone_desert_ocean  ,heat_point = 60,humidity_point =  0},
		
		{biome=cold_desert             ,heat_point = 40,humidity_point =  0},
		{biome=cold_desert_ocean       ,heat_point = 40,humidity_point =  0},
		
		{biome=savanna                 ,heat_point = 89,humidity_point = 42},
		{biome=savanna_shore           ,heat_point = 89,humidity_point = 42},
		{biome=savanna_ocean           ,heat_point = 89,humidity_point = 42},
		
		{biome=rainforest              ,heat_point = 86,humidity_point = 65},
		{biome=rainforest_swamp        ,heat_point = 86,humidity_point = 65},
		{biome=rainforest_ocean        ,heat_point = 86,humidity_point = 65},
		
		{biome=mushroom                ,heat_point = 48,humidity_point = 60},
		{biome=basic_shore             ,heat_point = 48,humidity_point = 60},
		{biome=basic_ocean             ,heat_point = 48,humidity_point = 60},
		
		{biome=scorched                ,heat_point = 75,humidity_point = 10},
		{biome=basic_shore             ,heat_point = 75,humidity_point = 10},
		{biome=basic_ocean             ,heat_point = 75,humidity_point = 10},
		
		{biome=golden                  ,heat_point = 30,humidity_point = 30},
		{biome=basic_shore             ,heat_point = 30,humidity_point = 30},
		{biome=basic_ocean             ,heat_point = 30,humidity_point = 30},
		
		{biome=rainbow                 ,heat_point = 80,humidity_point = 80},
		{biome=basic_shore             ,heat_point = 80,humidity_point = 80},
		{biome=basic_ocean             ,heat_point = 80,humidity_point = 80},
		
		{biome=underground             ,heat_point = 50,humidity_point = 50},
		

		}


realms.register_biomemap(bm_mixed_biomes)

--********************************
function bm_mixed_biomes.bm_mixed_biomes(parms)
bf_generic.map_biome_to_surface(parms,bm_mixed_biomes)
end -- bf_basic_biomes

realms.register_mapfunc("bm_mixed_biomes",bm_mixed_biomes.bm_mixed_biomes)
