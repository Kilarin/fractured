--[[
tg_2dMap  (Terrain Generator)
This Terrain Generator uses 2d Noise to generate Terrain.
possible paramaters:

tg_2dMap takes the standard realms paramters, plus the following:

height_base=#
   The height_base is the base value the noise manipulates to generate the terrain, so higher
   values generate taller and deeper features.  It defaults to 30 if you do not include it in
   realms.conf
sea_percent=#
   This sets aproximately what percentage of the world will be below sea level.  The landscape
   is actually shifted up (or down) to accomplish this.  It defaults to 25% if you do not include
   it in realms.conf
extremes  or extremes=#
   this turns on (and optionaly sets the multiplier for) extremes in the terrain.  It creates
   regions of tall mountains and flatter plains.  The value defaults to 4 if you just set it as a
   flag |extremes| but you can specify a value like |extremes=5|
   when extremes are on, the generator uses a second layer of 2d noise and the surface calculation
   is multiplied by extval*(noise_ext^2)
canyons
   passing this flag in realms.conf will cause to terrain generator to use another layer of
   2d noise to generate "canyons"  They aren't very canyon like yet, but do create some
   interesting terrain

noise:
  tg_2dMap uses 3 different noises.
    noisetop (for determining the surface)
    noiseext (for making extremes, high mountains, plains, deep valleys and seas)
    noisecan (for making canyons, this doesnt work very well yet, but is at least interesting)
    you can change any of these by passing a paramater on the realms.conf line such as
    |noisetop=newnoise42| (this assumes, of course, that you have registered that noise somwhere)

biome function:
  tg_2dMap can take a biome function in the biome collumn.
  the biome function is called after the surface is determined, and is passed in parms.share.surface
  it is assumed that the biome function has been registered with register_mapfunc() and will return
  (in parms.share) surface[z][x].biome
  important elements expected to be in the biome table are:
    node_top = what node to use for the surface of the biome
    depth_top = how deep the top layer is (usually 1).
    node_filler = what node to fill in under the surface (usually dirt)
    depth_filler = how deep should the filler be
    node_water_top = only specify if you want something besides water (like ice)
    depth_water_top = how deep should the node_water_top be
    node_dust = specify if you want something (like snow) on top of the surface
    decorate = the function that will place decorations.  Usually this is not defined in the biome
        and register_biome() sets it to realms.decorate which works for all biomes in standard
        realms format
  if the biome function sets parms.share.make_ocean_sand to true, then tg_2dMap will default all
  areas under sealevel to sand with no biome.  (helps when setting up simple biomes)

  below is an example of a realms.conf line defining a realm using tg_2dMap

  RMG Name         :min x :min y :min z :max x : max y: max z:sealevel:biome func       :other parms
  -----------------:------:------:------:------:------:------:--------:-----------------:----------
  tg_2dMap         |-33000| 15000|-33000| 33000| 16500| 33000|   16000|bm_default_biomes|height_base=60|sea_percent=35|extremes=5|canyons

--]]



tg_2dMap={}

--local c_air = minetest.get_content_id("air")
--local c_water_source = minetest.get_content_id("default:water_source")


realms.register_noise("Map2dTop01",{
	offset = 0,
	scale = 1,
	spread = {x=500, y=500, z=500},
	octaves = 5,
	seed = 5342345987, --this will be added to world seed
	persist = 0.63,
--	flags = "defaults, absvalue"
})


realms.register_noise("Map2dExt01",{
	offset = 0,
	scale = 1,
	spread = {x=200, y=600, z=200},
	octaves = 3,
	seed = 762643748, --this will be added to world seed
	persist = 0.40,
	flags = "defaults, absvalue"
}) --range on this should be about 1.56


realms.register_noise("Map2dCan01",{
	offset = 0,
	scale = 1,
	spread = {x=100, y=100, z=100},
	octaves = 4,
	seed = 129384110, --this will be added to world seed
	persist = 0.75,
	lacunarity  = 2.0,
	flags = "defaults, absvalue"
})





--********************************
function tg_2dMap.gen_tg_2dMap(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()

	--get optional parms and set defaults if they dont exist
	local height_base=parms.height_base
	if height_base==nil then height_base=30 end
	local sea_percent=parms.sea_percent
	if sea_percent==nil then sea_percent=25 end
	sea_percent=sea_percent/100


	--NOTE: our default_seed is the realm_seed, so that each realm will have unique noise.
	--If you want two different realm entries to use the same noise, you must set parms.seed
	local noisetop = realms.get_noise2d(parms.noisetop,"Map2dTop01",parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local noiseext = realms.get_noise2d(parms.noiseext,"Map2dExt01",parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	local noisecan = realms.get_noise2d(parms.noisecan,"Map2dCan01",parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	--*!* should modify this to look for noisename_seed

	--we calculate the surface top and bot first
	--because we need to loop through the voxels in z,y,x order for efficency
	--but we only want to do the calculations for top and bot y once per x,z coord
	--the simplest way to do that is to calucate them first
	--we load our perlin noise as flat because, well, quite frankly, because
	--everyone else does it that way, so I assume it's more efficent.  So instead of
	--and x,z array, we have one array that goes from 1 to isectsize2d.x*isectsize2d.y
	--we determine surface[x][z].top here.  surface[x][z].bot and other stuff generally processed in biome

	local surface = {}

	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		surface[z]={}
		for x=parms.isect_minp.x, parms.isect_maxp.x do

			--we are going to set the surface level based on noise (noise should be -1 to +1 but might be -2 to +2)
			--dirt_height is the value for how high the terrain should be at this point.
			--dirt_height should be a spread from a negative low to a positive high
			local dirt_height=height_base*noisetop[nixz]

			--if you just added dirt_height to sea_level you would get a world that was 50% below sea level
			--the user might want a world with a lot less (or more) water, so we figure sea_adj:
			--sea_adj is an offset to sealevel that gives us the percentage water we want (after adding dirt_height)
			--(example if height_base=30, sea_percent=25, and sealevel=0 then sea_adj=15 because
			-- 0+15-30=-15 and 0+15+30=45, so 25% of the world will be below sea level)
			local sea_adj=height_base-2*height_base*sea_percent

			--this creates a multiplier that creates plains and valleys by multiplying the base by another layer of noise
			local mult=1
			if parms.extremes~=nil then
				local extval=parms.extremes
				if type(extval)~="number" then extval=4 end
				local noise_ext=noiseext[nixz]
				mult=extval*(noise_ext^2)
			end --if parms.plains


			--so final value for top is the sea level, offest by sea_adj, plus dirt_height times mountain multiplier
			surface[z][x]={}
			surface[z][x].top=math.floor(parms.sealevel+sea_adj+dirt_height*mult)

			if parms.canyons==true then
				--BUT, now we are going to try and add canyons.
				--this does NOT make great canyons, but it does make sorta canyons, and interesting terrain.  And odd small deep holes.
				local can=noisecan[nixz]
				--[ [
				local edge=0.5 --change this to play with different canyon shapes
				if can<edge and surface[z][x].top>parms.sealevel then --make a canyon/river
					local t=surface[z][x].top --just to make this more readable
					--so first .05 of the area is a sharp drop
					if can>=(edge-.05) then surface[z][x].top=t-(t-parms.sealevel)*(edge-can)*20
					--the bottom of the canyon should be made more dependent on noise, currently its just deepest at 0
					elseif can<(edge-.05) then surface[z][x].top=parms.sealevel-(10-((10/(edge-.05)*can)))
					end--if can>=(edge-.05)
					--minetest.log("***canyon-> x="..x.." z="..z.." was "..t.." now ".. surface[z][x].top)
				end--if can<edge
			--] ]
			--if can>0.5 and can<0.6 then surface[z][x].top=parms.sealevel-3 end
			end --if parms.canyons

			--the below will be overridden if you have a biomefunc
			if surface[z][x].top>parms.sealevel then surface[z][x].biome=realms.undefined_biome
			else surface[z][x].biome=realms.undefined_underwater_biome
			end --if top>parms.sealevel

			nixz=nixz+1
		end --for x
	end --for z

	--the below will add surface.biome, node_top, node_filler, and decorate (function)
	parms.share.surface=surface --got to share it so the biomefunc can update it
	if parms.biomefunc~=nil then realms.rmf[parms.biomefunc](parms) end
	--surface=parms.share.surface  --just in case the bf (biome func) replaced it
	--minetest.log("tg_2dMap-> surface["..z.."]["..x.."].biome.node_top="..surface[z][x].biome.node_top.."   name="..surface[z][x].biome.name)

	--now that the surface map has been generated, we run generic_2dMap_loop
	--here is where we actually do the work of generating the landscape.
	--this is in a "generic" terrain function because it is used in multiple places
	--and I hate duplicate code
	tf_generic_2dMap_loop(parms)

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("gen_tg_2dMap-> END isect="..luautils.pos_to_str(parms.isect_minp).."-"..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_with_mountains

realms.register_mapgen("tg_2dMap",tg_2dMap.gen_tg_2dMap)


