dofile(minetest.get_modpath("realms").."/realms_map_generators/layer_barrier_nodes.lua")
local c_layerbarrier = minetest.get_content_id("realms:layer_barrier")

--********************************
function gen_layer_barrier(realm_minp,realm_maxp,surfacey, chunk_minp,chunk_maxp,seed)
	--continue only if we are in the right realm
	--minetest.log("layerbarrier-> start realm_minp="..luautils.pos_to_str(realm_minp).." maxp="..luautils.pos_to_str(realm_maxp)
	    --.." chunk_minp="..luautils.pos_to_str(chunk_minp).." maxp="..luautils.pos_to_str(chunk_maxp))
	if luautils.check_overlap(realm_minp,realm_maxp, chunk_minp,chunk_maxp)==true then
		--minetest.log("layerbarrier-> inside")
		local t1 = os.clock()
		--This actually initializes the LVM
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()

		local minp={}
		local maxp={}
		minp,maxp=luautils.box_intersection(realm_minp,realm_maxp, chunk_minp,chunk_maxp)
		--minetest.log("layerbarrier-> intersection minp="..luautils.pos_to_str(minp).." maxp="..luautils.pos_to_str(maxp))
		for y=minp.y, maxp.y do
			for x=minp.x, maxp.x do
				for z=minp.z, maxp.z do
					local vi = area:index(x, y, z) -- This accesses the node at a given position
					data[vi]=c_layerbarrier
				end --for z
			end --for x
		end --for y

	-- Wrap things up and write back to map
	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("rmg layer_barrier-> END chunk="..luautils.pos_to_str(minp).." - "..luautils.pos_to_str(maxp).."  "..chugent.." ms") --tell people how long
	end --if check_overlap
end -- gen_layer_barrier

realms.register_rmg("layer_barrier",gen_layer_barrier)
