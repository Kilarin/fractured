--[[
I have not taken the time to learn how to make natural looking landscapes with 3d noise yet.
Or even how you map the surface with overhangs so that biomes can be generated/decorated.

So this is just sort of here to say "hey, someday I want floating islands, but not like
these..."


--]]


tg_stupid_islands={}

local c_stone = minetest.get_content_id("default:stone")
local c_air = minetest.get_content_id("air")


tg_stupid_islands.np_cavern = {
	offset      = 0,
	scale       = 1,
	spread      = {x=384, y=128, z=384},
	seed        = 723,
	octaves     = 5,
	persistence = 0.63,
	lacunarity  = 2.0,
	flags = "defaults, absvalue"
 }

--why so many ranges?  with one range you just get bigger and bigger caves
--I want MORE caves, so more ranges
--local cave_range={[1]={a=0,b=.2},[2]={a=.7,b=.8},[3]={a=1.25,b=1.4}}
local cave_range={[1]={a=0,b=.2},[2]={a=1.25,b=1.4}}


--********************************
function tg_stupid_islands.gen_tg_stupid_islands(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()


	local noisecav = minetest.get_perlin_map(tg_stupid_islands.np_cavern, parms.isectsize3d):get_3d_map_flat(parms.isect_minp)
	local surface = {}

	--*!*debugging
	local ncvlo=999
	local ncvhi=-999

--here is where we actually do the work of generating the landscape.
--we loop through as z,y,x because that is way the voxel info is stored, so it is most efficent.
local nixyz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				if noisecav[nixyz]>ncvhi then ncvhi=noisecav[nixyz] end --*!*debugging
				if noisecav[nixyz]<ncvlo then ncvlo=noisecav[nixyz] end --*!*debugging

				--the ceildist logic is an attempt to make the cave roofs less square at the top of the realm
				--local ceildist=parms.realm_maxp.y-y
				--if ceildist<10 then b=b-((b-a)/2)*y end
				--if noisecav[nixyz]<.5 or noisecav[nixyz]>1.2 then 
				--if noisecav[nixyz]<.18 or (noisecav[nixyz]>.55 and noisecav[nixyz]<.6) then --or noisecav[nixyz]>1.3 then
				--if noisecav[nixyz]<.05 then --or (noisecav[nixyz]>.55 and noisecav[nixyz]<.6) then --or noisecav[nixyz]>1.3 then
				--if (noisecav[nixyz]>.55 and noisecav[nixyz]<.6) then --or noisecav[nixyz]>1.3 then
				if (noisecav[nixyz]>.58 and noisecav[nixyz]<.6) then 
					local vi = parms.area:index(x, y, z)
					--local bfr=parms.data[vi]
					parms.data[vi] = c_stone
					--minetest.log("  tg_caves-> changed "..luautils.pos_to_str_xyz(x,y,z).." to air.  vi="..vi.." before="..bfr.." after="..parms.data[vi].." air="..c_air)
					--any way to determine the surface? for biomes?  probably just have to make a biome that hunts for air over stone
					--I tried checking for is_ground_content, it slowed this function WAY down
				end --if noisecav
				--end --for
			nixyz=nixyz+1
			end --for x
		end --for y
	end --for z


	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	ncvlo=luautils.round_digits(ncvlo,3)  --*!*debugging
	ncvhi=luautils.round_digits(ncvhi,3)  --*!*debugging
	minetest.log("gen_caves-> END isect="..luautils.pos_to_str(parms.isect_minp).."-"..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms" --) --tell people how long
			.."   noise-> ncvlo="..ncvlo.." ncvhi="..ncvhi) --*!*debugging
end -- gen_tg_caves


realms.register_mapgen("tg_stupid_islands",tg_stupid_islands.gen_tg_stupid_islands)



