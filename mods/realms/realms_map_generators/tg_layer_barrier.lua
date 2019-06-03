--[[
Layer Barrier creates a layer of invisble invulnerable nodes to separate layers 
(thank you to Beerholder and his `multi_map` mod for this idea.)  

Passing the parameter "bedrock" to `tg_layer_barrier` will cause it to generate a layer of 
invulnerable (but opaque) nodes as the very top layer of its area.  Very handy for creating 
a "bottom" to a realm in -the sky.

below is an example of a realms.conf line that calls layer barrier

    tg_layer_barrier |-33000|  4900|-33000| 33000|  4999| 33000|       0|                    |bedrock
--]]


dofile(minetest.get_modpath("realms").."/realms_map_generators/layer_barrier_nodes.lua")
local c_layerbarrier = minetest.get_content_id("realms:layer_barrier")
local c_bedrock = minetest.get_content_id("realms:bedrock")


--********************************
function gen_tg_layer_barrier(parms)
	--we dont need to check overlap because realms does that for us and passes us our intersect in isect_minp,isect_maxp
	local t1 = os.clock()

	--minetest.log("layerbarrier-> intersection minp="..luautils.pos_to_str(minp).." maxp="..luautils.pos_to_str(maxp))
	for y=parms.isect_minp.y, parms.isect_maxp.y do
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			for z=parms.isect_minp.z, parms.isect_maxp.z do
				local vi = parms.area:index(x, y, z) -- This accesses the node at a given position
				if parms.bedrock==true and y==parms.realm_maxp.y then parms.data[vi]=c_bedrock
				else parms.data[vi]=c_layerbarrier
				end --if
			end --for z
		end --for x
	end --for y

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("tg_layer_barrier-> END chunk="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_layer_barrier

realms.register_mapgen("tg_layer_barrier",gen_tg_layer_barrier)
