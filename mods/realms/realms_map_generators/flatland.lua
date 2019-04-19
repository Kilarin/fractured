
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_air = minetest.get_content_id("air")



--********************************
function gen_flatland(realm_minp,realm_maxp, surfacey, chunk_minp,chunk_maxp, seed)
	--this is just a stupid proof of concept
	--*!* Do I need this check here, or should it be in realms and only call here when we KNOW we have an overlap?
	if luautils.check_overlap(realm_minp,realm_maxp, chunk_minp,chunk_maxp)==true then
		local t1 = os.clock()
		--This actually initializes the LVM
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()

		local minp={}
		local maxp={}
		--*!* also, I could send the intersection, to save time.
		minp,maxp=luautils.box_intersection(realm_minp,realm_maxp, chunk_minp,chunk_maxp)
		minetest.log("rmg gen_flatland-> realm minp="..luautils.pos_to_str(realm_minp).." maxp="..luautils.pos_to_str(realm_maxp)..
		" chunk minp="..luautils.pos_to_str(chunk_minp).." maxp="..luautils.pos_to_str(chunk_maxp))
		minetest.log("    intersection minp="..luautils.pos_to_str(minp).." maxp="..luautils.pos_to_str(maxp).." surfacey="..surfacey)

		--this is probably innefficent, should I do 3 loops, 
		--miny to surfacy-20 then surfacy-20 to surfacy-1 then surfacey then surfacey to maxy?
		--that seems really complicated and ugly		
		local c_material=c_stone
		for y=minp.y, maxp.y do
			--doing check here saves a little cpu (because we only check once per y) and isn't as ugly as 4 loops
			if y<surfacey-20 then c_material=c_stone
			elseif y<surfacey then c_material=c_dirt
			elseif y==surfacey then c_material=c_grass
			elseif y>surfacey then c_material=c_air
			end --if y
			for x=minp.x, maxp.x do
				for z=minp.z, maxp.z do
					local vi = area:index(x, y, z) -- This accesses the node at a given position
					data[vi]=c_material
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
		minetest.log("rmg flatland-> END chunk="..luautils.pos_to_str(minp).." - "..luautils.pos_to_str(maxp).."  "..chugent.." ms") --tell people how long
	end --if overlap
end -- gen_flatland

realms.register_rmg("flatland",gen_flatland)


