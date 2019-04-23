local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_air = minetest.get_content_id("air")

np_ground = { 
	offset = 0,
	scale = 1,
	spread = {x=500, y=500, z=500},
	octaves = 5,
	seed = 5342345987, --this will be added to world seed
	persist = 0.63,
	flags = "defaults, absvalue"
}

--********************************
function gen_very_simple(realm_minp,realm_maxp, surfacey, chunk_minp,chunk_maxp, seed)
	--this is just a stupid proof of concept
	--we dont check for overlap because this will ONLY be called where there is an overlap
	local t1 = os.clock()
	--This actually initializes the LVM
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local minp={}
	local maxp={}
	minp,maxp=luautils.box_intersection(realm_minp,realm_maxp, chunk_minp,chunk_maxp)
	minetest.log("rmg gen_very_simple-> realm minp="..luautils.pos_to_str(realm_minp).." maxp="..luautils.pos_to_str(realm_maxp)..
	" chunk minp="..luautils.pos_to_str(chunk_minp).." maxp="..luautils.pos_to_str(chunk_maxp))
	minetest.log("    intersection minp="..luautils.pos_to_str(minp).." maxp="..luautils.pos_to_str(maxp).." surfacey="..surfacey)

	--get noise details
	local chunksize = luautils.box_size(minp,maxp)
	local minposxz = {x=minp.x, y=minp.z}
	minetest.log("rmg gen_very_simple-> chunksize="..luautils.pos_to_str(chunksize).." minposxz x="..minposxz.x.." y="..minposxz.y)
	local noise = minetest.get_perlin_map(np_ground, chunksize):get_2d_map_flat(minposxz)
	--minetest.log("***-> chunksize=")
	--luautils.log_table(chunksize)
	--minetest.log("***-> minposx=")
	--luautils.log_table(minposxz)
	--minetest.log("***-> np_ground=")
	--luautils.log_table(np_ground)
	--if noise==nil minetest.log("***->noise=nil")
	--minetest.log("***-> noise=")
	--luautils.log_table(noise)
	--local noise = minetest.get_perlin_map(np_ground, chunksize):get2dMap(minposxz)
	--for k,v in ipairs(noise) do
	--	minetest.log("***-> k="..k.." v="..v)
	--end--for

	--this is probably innefficent, should I do 3 loops, 
	--miny to surfacy-20 then surfacy-20 to surfacy-1 then surfacey then surfacey to maxy?
	--that seems really complicated and ugly		
	local c_material=c_stone
	local nixz=1
	for z=minp.z, maxp.z do
		for y=minp.y, maxp.y do
			for x=minp.x, maxp.x do
				local top=math.floor(surfacey+(30*noise[nixz]))
				--local top=surfacey+(30*noise[{x=x,y=z}])
				local ns
				if noise[nixz]==nil then ns="nil" else ns=noise[nixz] end
				--minetest.log("gen_very_simple-> x="..x.." y="..y.." z="..z.." nixz="..nixz.." noise="..ns.." top="..top)
				if y<top-20 then c_material=c_stone
				elseif y<top then c_material=c_dirt
				elseif y==top then c_material=c_grass
				elseif y>top then c_material=c_air
				end --if y
				local vi = area:index(x, y, z) -- This accesses the node at a given position
				data[vi]=c_material
				nixz=nixz+1
			end --for x
			nixz=nixz-chunksize.y
		end --for x
		nixz=nixz+chunksize.y
	end --for z

	-- Wrap things up and write back to map
	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("rmg very_simple-> END chunk="..luautils.pos_to_str(minp).." - "..luautils.pos_to_str(maxp).."  "..chugent.." ms") --tell people how long
end -- gen_very_simple

realms.register_rmg("very_simple",gen_very_simple)


