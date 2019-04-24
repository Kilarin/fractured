dofile(minetest.get_modpath("realms").."/realms_map_generators/layer_barrier_nodes.lua")
local c_layerbarrier = minetest.get_content_id("realms:layer_barrier")
local c_bedrock = minetest.get_content_id("realms:bedrock")


--********************************
--function gen_layer_barrier(realm_minp,realm_maxp,surfacey, chunk_minp,chunk_maxp,seed)
function gen_layer_barrier(parms)
	--we dont need to check overlap because realms does that for us and passes us our intersect in isect_minp,isect_maxp
	local t1 = os.clock()

	--local minp={}
	--local maxp={}
	--minp,maxp=luautils.box_intersection(realm_minp,realm_maxp, chunk_minp,chunk_maxp)
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
	
	minetest.log("barrier-> parms.test1="..luautils.var_or_nil(parms.test1).." parms.test2="..luautils.var_or_nil(parms.test2))

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("rmg layer_barrier-> END chunk="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_layer_barrier

realms.register_rmg("layer_barrier",gen_layer_barrier)
