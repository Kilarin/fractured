
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_grass = minetest.get_content_id("default:dirt_with_grass")

local realms={ }
realms.count=5
realms[1]={ }
realms[1].bot=5000
realms[1].top=6000
realms[2]={ }
realms[2].bot=10000
realms[2].top=11000
realms[3]={ }
realms[3].bot=15000
realms[3].top=16000
realms[4]={ }
realms[4].bot=20000
realms[4].top=21000
realms[5]={ }
realms[5].bot=25000
realms[5].top=26000


--********************************
function gen_realms(minp, maxp, seed)
	--this is just a stupid proof of concept
	local r=0
	local doit=false
	repeat
		r=r+1
		if minp.y<=realms[r].top and maxp.y>realms[r].bot then doit=true end
	until r==realms.count or doit==true
	if doit==false then return end --dont waste cpu

	local t1 = os.clock()

	--This actually initializes the LVM
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local miny=minp.y
	if miny<realms[r].bot then miny=realms[r].bot end
	local maxy=maxp.y
	if maxy>realms[r].top then maxy=realms[r].top end

	for y=miny, maxy do
		for x=minp.x, maxp.x do
			for z=minp.z, maxp.z do
				local vi = area:index(x, y, z) -- This accesses the node at a given position
				if y<realms[r].top-20 then data[vi]=c_stone
				elseif y<realms[r].top then data[vi]=c_dirt
				else data[vi]=c_grass
				end --if
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
	minetest.log("realms END chunk="..minp.x..","..minp.y..","..minp.z.." - "..maxp.x..","..maxp.y..","..maxp.z.."  "..chugent.." ms") --tell people how long
end -- ge