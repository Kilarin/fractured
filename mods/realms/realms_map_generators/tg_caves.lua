--[[

this is a not very good attempt to created caves out of 3d noise.
It needs a lot of improvement.

below is an example of a realms.conf line calling tg_caves:

    tg_caves         |-33000|  5000|-33000| 33000|  6000| 33000|    6000|                    |

--]]
tg_caves={}

local c_stone = minetest.get_content_id("default:stone")
local c_air = minetest.get_content_id("air")

local c_water            = minetest.get_content_id("default:water_source")
local c_water_flow       = minetest.get_content_id("default:water_flowing")
local c_river_water      = minetest.get_content_id("default:river_water_source")
local c_river_water_flow = minetest.get_content_id("default:river_water_flowing")
local c_lava             = minetest.get_content_id("default:lava_source")
local c_lava_flow        = minetest.get_content_id("default:lava_flowing")


tg_caves.np_cavern = {
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
function tg_caves.gen_tg_caves(parms)
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()


	local noisecav = minetest.get_perlin_map(tg_caves.np_cavern, parms.isectsize3d):get_3d_map_flat(parms.isect_minp)
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
				if noisecav[nixyz]<.08 or (noisecav[nixyz]>.56 and noisecav[nixyz]<.6) then 
					local vi = parms.area:index(x, y, z)
					--local bfr=parms.data[vi]
					local node=parms.data[vi]
					if node~=c_water and node~=c_water_flow and node~=c_river_water and node~=c_river_water_flow and node~=c_lava and node~=c_lava_flow then
						parms.data[vi] = c_air
					end --if not water, river, or lava
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


realms.register_mapgen("tg_caves",tg_caves.gen_tg_caves)



