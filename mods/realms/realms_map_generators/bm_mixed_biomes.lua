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

bm_mixed_biomes.typ="MATRIX"
bm_mixed_biomes.heatrange=5
bm_mixed_biomes.humidrange=5
local arctic  =realms.biome.basic_arctic --2
local cold    =realms.biome.basic_cold   --4
local warm    =realms.biome.basic_warm   --4
local hot     =realms.biome.basic_hot    --4
local desert  =realms.biome.basic_desert --2
local crystal =realms.biome.odd_crystal  --3
local mushroom=realms.biome.odd_mushroom --3
local scorched=realms.biome.odd_scorched --2
local golden  =realms.biome.odd_golden   --3
local rainbow =realms.biome.odd_rainbow  --3
bm_mixed_biomes.biome={
		{arctic  , arctic  , cold      ,cold     ,rainbow  ,crystal },--+humid
		{cold    , cold    , crystal   ,crystal  ,golden   ,mushroom},
		{warm    , warm    , warm      ,golden   ,mushroom ,mushroom},
		{desert  , scorched, warm      ,rainbow  ,hot      ,hot     },
		{desert  , scorched, golden    ,rainbow  ,hot      ,hot     }
	} --+hot


--[[
bm_mixed_biomes.type="VORONOI"
bm_mixed_biomes.list={
	{biome=arctic ,heatp=0.00, humidp=0.00}
	{biome=cold   ,heatp=0.20, humidp=0.20}
	{biome=crystal  ,heatp=0.35, humidp=0.35}
	{biome=warm   ,heatp=0.50, humidp=0.50}
	{biome=mushroom ,heatp=0.30, humidp=0.80}
	{biome=hot    ,heatp=0.75, humidp=0.75}
	{biome=scorched ,heatp=0.99, humidp=0.00}
	{bbiome=desert,heatp=0.90, humidp=0.10}
	}
--]]

realms.register_biomemap(bm_mixed_biomes)

--********************************
function bm_mixed_biomes.bm_mixed_biomes(parms)
bf_generic.map_biome_to_surface(parms,bm_mixed_biomes)
end -- bf_basic_biomes

realms.register_mapfunc("bm_mixed_biomes",bm_mixed_biomes.bm_mixed_biomes)
