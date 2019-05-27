bm_default_biomes={}

bm_default_biomes.name="default_biomes_map"



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

--[[
bm_default_biomes.type="VORONOI"
bm_default_biomes.list={
	{biome=bd_basic_biomes.arctic ,heatp=0.00, humidp=0.00}
	{biome=bd_basic_biomes.cold   ,heatp=0.20, humidp=0.20}
	{biome=bd_odd_biomes.crystal  ,heatp=0.35, humidp=0.35}
	{biome=bd_basic_biomes.warm   ,heatp=0.50, humidp=0.50}
	{biome=bd_odd_biomes.mushroom ,heatp=0.30, humidp=0.80}
	{biome=bd_basic_biomes.hot    ,heatp=0.75, humidp=0.75}
	{biome=bd_odd_biomes.scorched ,heatp=0.99, humidp=0.00}
	{bbiome=bd_basic_biomes.desert,heatp=0.90, humidp=0.10}
	}


bm_default_biomes.type="MATRIX"
--temporary removing ocean/beach/shore until I get y range activated
bm_default_biomes.heatrange=4
bm_default_biomes.humidrange=4
bm_default_biomes.biome={
		{icesheet                ,tundra_highland         ,tundra                  ,taiga                   },
		{snowy_grassland         ,grassland               ,grassland_dunes         ,coniferous_forest       },
		{coniferous_forest_dunes ,deciduous_forest        ,desert                  ,sandstone_desert        },
		{cold_desert             ,savanna                 ,rainforest              ,rainforest_swamp        },
		}
--]]

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
		{biome=underground             ,heat_point = 50,humidity_point = 50},
		}

realms.register_biomemap(bm_default_biomes)



--********************************
function bm_default_biomes.bm_default_biomes(parms)
bf_generic.map_biome_to_surface(parms,bm_default_biomes)
end -- bm_default_biomes

realms.register_mapfunc("bm_default_biomes",bm_default_biomes.bm_default_biomes)
