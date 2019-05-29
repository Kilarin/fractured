tg_shattered={}

local c_water_source = minetest.get_content_id("default:water_source")


realms.register_noise("MapShatteredTop01",{
	offset = 0,
	scale = 1,
	spread = {x=50, y=50, z=50},
	octaves = 3,
	seed = 324587, --this will be added to world seed
	persist = 0.63,
--	flags = "defaults, absvalue"
})


realms.register_noise("MapShatteredRad01",{
	offset = 0,
	scale = 1,
	spread = {x=10, y=10, z=10},
	octaves = 3,
	seed = 4311, --this will be added to world seed
	persist = 0.63,
	flags = "defaults, absvalue"
})


--********************************
function tg_shattered.gen_tg_shattered(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()

	--later I should parameterize the base_height and radius???  multiple numbers, not intuitive.


	--NOTE: our default_seed is the realm_seed, so that each realm will have unique noise.
	--If you want two different realm entries to use the same noise, you must set parms.seed
	local noisetop = realms.get_noise2d(parms.noisesht,"MapShatteredTop01",parms.seed,parms.realm_seed, parms.isectsize2d,parms.minposxz)
	--note that for the radius noise we only need a single row of 80, so I set the size manualy
	local noiserad = realms.get_noise2d(parms.noiserad,"MapShatteredRad01",parms.seed,parms.realm_seed, {x=80, y=1} ,parms.minposxz)

	--we calculate the surface top and bot first
	--because we need to loop through the voxels in z,y,x order for efficency
	--but we only want to do the calculations for top and bot y once per x,z coord
	--the simplest way to do that is to calucate them first
	--we load our perlin noise as flat because, well, quite frankly, because
	--everyone else does it that way, so I assume it's more efficent.  So instead of
	--and x,z array, we have one array that goes from 1 to isectsize2d.x*isectsize2d.y
	--we determine surface[x][z].top here.  
	
	local surface = {}
	
	local minp=parms.isect_minp
	local maxp=parms.isect_maxp
	--get the center of the chunk (could be strange if the isect doesnt completely overlap the chunk?)
	local cx=minp.x+math.floor((maxp.x-minp.x)/2)
	local cz=minp.z+math.floor((maxp.z-minp.z)/2)
	
	local nixz
	local biometop=realms.undefined_biome
	--note that this expect a DIFFERENT kind of biome func than most of the other generators
	--it is not expecting the biome func to map surface[z][x].top and .biome for all of the chunk.
	--instead it expects the biome func to just return one random biome.
	if parms.biomefunc~=nil then biometop=realms.rmf[parms.biomefunc](parms) end
	local biomebot=realms.undefined_underwater_biome
	
	minetest.log("shattered-> biometop="..biometop.name)
	minetest.log("shattered-> biomebot="..biomebot.name)

	--the below should always be 1 I think
	--nixz=luautils.xzcoords_to_flat(minp.x,minp.z, minp, parms.isectsize2d)
	
	--determine the height based on the first noise in the noisemap (its as good as any of them for this purpose)
	local h=10+math.abs(noisetop[1])*50  

	
	nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		surface[z]={}
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			--normal distance formula involves taking a square root, but processing square roots is expensive,
			--so we just leave the distance valued squared and we will compare to that.
			--so dont get confused by the distance numbers, remember the distance AND radius are squares of 
			--actual numbers we are comparing.
			local dist=luautils.distance2d_sq(cx,cz, x,z)
			--now, here is the strange part.  We are going to make the mesas of the shattered plains by
			--by putting stone for all locations whos distance is less than the chosen radius from the center.
			--but that makes a very unnatural and boring perfect circle mesa.  What we REALLY want is to vary
			--the radius as we go around the circle.  But not randomly, that would look goofy, we want it to
			--change gradually using perlin noise.  BUT, how do we translate our perin noise map into a 
			--circle???  Like this:
			--first we use the atan2 function to get the angle from the center of our circle to the point
			--we are examining.  This gives us a number that varies from -pi to +pi as it goes around.
			local angle=math.atan2(x-cx,z-cz)
			--now, add pi to the angle, that gives us a number from 0 to 2pi.  We want to map that 
			--onto 1 to 80 (could have picked any number, but 80 is the size of a chunk and so minetest
			--code is probably designed to be highly efficent at that, and 80 gives us plenty fine
			--granularity)  so we multiply by 80/2pi and add one more
			local noisecoord=math.floor((angle+math.pi)*(80/(2*math.pi)))+1  --now we have 1 to 81 (can just barely nudge over into 81)
			--now we have 1-81.  it can just barely nudge over into 81, and we dont want 81, so if it happens 
			--to do that, we just set it back to 80.
			if noisecoord>80 then noisecoord=80 end --shouldn't really be 81
			--We use our number from 1 to 80 as an index into our perlin noise,
			local radnoise=noiserad[noisecoord]
			--and, voila!  We have perlin noise that changes our radius as we go around the circle!! 
			local radius=625+(900*radnoise)  --remember the 625 and 900 are squared and really represent 25 and 30
			surface[z][x]={}
			local sfc=surface[z][x]
			--we check to make certain our mesa doesn't ACTUALLY reach the edges of the chunk.  We want 
			--gaps between them.  I tried just adjusting the radius to 39, but that meant the mesa 
			--couldnt expand as far into the corners.  this results in a shape that is sometimes more squarish,
			--but for right now, I prefer having less of that huge gap at the corners, and this does that.
			if (dist<=radius) and (x<maxp.x) and (x>minp.x) and (z<maxp.z) and (z>minp.z) then
				sfc.top=math.floor(parms.sealevel+h+3*noisetop[nixz])
				sfc.biome=biometop
			else
				sfc.top=math.floor((parms.sealevel-5)+3*noisetop[nixz])
				sfc.biome=biomebot
			end
			--minetest.log("shattered-> sfc["..z.."]["..x.."].biome="..sfc.biome.name.."  sfc.top="..sfc.top)
			
			--the below will be overridden if you have a biomefunc
			--surface[z][x].biome=realms.undefined_biome
			nixz=nixz+1
		end --for x
	end --for z

	parms.share.surface=surface --even though our biomefunc doesn't use this, best to share anyway, some other function might need it.

--*!* this zyx loop is an exact duplicate of tg_2dMap loop.  Perhaps I should turn it into a function?

--here is where we actually do the work of generating the landscape.
--we loop through as z,y,x because that is way the voxel info is stored, so it is most efficent.
	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				local sfc=surface[z][x]
				local biome=sfc.biome
				--minetest.log("shattered2-> sfc["..z.."]["..x.."].biome="..biome.name.." sfc.top="..sfc.top)
				local sealevel=parms.sealevel
				if sfc.top_depth==nil then sfc.top_depth=1 end
				if sfc.filler_depth==nil then sfc.filler_depth=6 end
				sfc.top_bot=sfc.top+(sfc.top_depth-1)
				sfc.fil_bot=sfc.top_bot-sfc.filler_depth 
				if sfc.water_top_depth==nil then sfc.water_top_depth=9999 end

				--anything lower than our surface filler bottom gets node_stone from biome
				if y<sfc.fil_bot then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_stone)

				--anything between filler bottom and top bottom (and not under sealevel) gets the filler node (biome based)
				elseif y<sfc.top_bot then 
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)

				--for those rare cases where top_depth>1
				elseif y<sfc.top then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)

				--if this is the top, set top node (biome based) and ALSO call the decorate function (if it exists)
				elseif y==sfc.top then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_top)
					if biome.decorate~=nil then biome.decorate(x,y+1,z, biome, parms) end

				--if we are at top+1 apply dust node (if it exists)
				elseif y==sfc.top+1 and sfc.top>sealevel and biome.node_dust~=nil then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_dust)

				--and if we are above the top, but under sea level, put water
				elseif y>sfc.top and y<=sealevel then
					local water_node=c_water_source
					if biome.node_water_top~=nil then
--						local nixz=luautils.xzcoords_to_flat(x,z, parms.isect_minp, parms.isectsize2d)
--						minetest.log("biome.node_water_top-> z="..z.." x="..x.." nixz="..nixz)
						--local depth_water_top=realms.randomize_depth(biome.depth_water_top,0.33,noiseDep,x,z,parms.isect_minp,parms.isectsize2d)
						if y>=sealevel-sfc.water_top_depth then water_node=biome.node_water_top end
					end --if biome.node_water_top~=nil
					luautils.place_node(x,y,z, parms.area, parms.data, water_node)
					
				--putting air just messes up the decorations since we work our way from bot to top
				--elseif y>dirttop[z][x] then luautils.place_node(x,y,z, parms.area, parms.data, c_air)
				end --if y
			end --for x
		end --for y
	end --for z


	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("gen_tg_shattered-> END isect="..luautils.pos_to_str(parms.isect_minp).."-"..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_with_mountains

realms.register_mapgen("tg_shattered",tg_shattered.gen_tg_shattered)


