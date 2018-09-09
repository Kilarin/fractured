
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_grass = minetest.get_content_id("default:dirt_with_grass")


--********************************
function gen_realm2(minp, maxp, seed)
  --this is just a stupid proof of concept
  if maxp.y<5000 or minp.y>6000 then return end
  
  local t1 = os.clock()
   
  --This actually initializes the LVM
  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
  local data = vm:get_data()

  
  local miny=minp.y
  if miny<5000 then miny=5000 end
  local maxy=maxp.y
  if maxy>6000 then maxy=6000 end

  for y=miny, maxy do  
    for x=minp.x, maxp.x do
      for z=minp.z, maxp.z do
        vi = area:index(x, y, z) -- This accesses the node at a given position
        if y<5980 then data[vi]=c_stone
        elseif y<6000 then data[vi]=c_dirt
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
  minetest.log("realm2 END chunk="..minp.x..","..minp.y..","..minp.z.." - "..maxp.x..","..maxp.y..","..maxp.z.."  "..chugent.." ms") --tell people how long
end -- gen_realm2


minetest.register_on_generated(gen_realm2)
        