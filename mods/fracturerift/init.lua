-- mods/default/mapgen.lua

fracturerift = {} --Global container for variables accessed by other mods

---
--- constants
---

fracturerift.width = 80        --how wide the rift will be		--fracrift. prefix added so that it can be referenced by other mods (e.g. worldstonetower)

local fracrift_depth_air=33000          --how deep before the water
local fracrift_depth_water=20           --how deep the water will be
local fracrift_top=100                  --max height to scan for land to remove
local fracrift_bottomsmooth=0.995       --odds of bottom being smooth
local fracrift_waterfallchance=0.997    --odds of NOT having a waterfall hole in wall
local c_fracrift_material=minetest.get_content_id("default:sandstone") -- Makes more sense, no?
                        minetest.get_content_id("default:sandstone")

--calculated constants
local fracrift_half = fracturerift.width/2
local fracrift_edge = fracrift_half+1
local fracrift_depth = -(fracrift_depth_air+fracrift_depth_water)
local fracrift_waterstart=-(fracrift_depth_air+1)

--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")
local c_water = minetest.get_content_id("default:water_source")

-- 3D noise for rift walls
local np_walls = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=512, z=512}, -- squashed 2:1
	seed = 133742, --a LEET answer to life, the universe, and everything
	octaves = 3,
	persist = 0.67
}

--FRACTURE GENERATION
minetest.register_on_generated(function(minp, maxp, seed)
  if maxp.x < -fracrift_edge or minp.x > fracrift_edge or
     maxp.y < fracrift_depth or minp.y > fracrift_top then
     return --quit; otherwise, you'd have wasted resources
  end

  --easy reference to commonly used values
  local t1 = os.clock()
  local x1 = maxp.x
  local y1 = maxp.y
  local z1 = maxp.z
  local x0 = minp.x
  local y0 = minp.y
  local z0 = minp.z

  --no need to scan outside the rift
  --if x0 < -fracrift_edge then x0=-fracrift_edge end
  --if x1 > fracrift_edge then x1=fracrift_edge end
  --if y0 < fracrift_depth then y0=fracrift_depth end
  --if y1 > fracrift_top then y1=fracrift_top end

  print ("[fracrift_ure_gen] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

  --This actually initializes the LVM
  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
  local data = vm:get_data()

  local sidelen = x1 - x0 + 1 --length of a mapblock
  local chulens = {x=sidelen, y=sidelen, z=sidelen} --table of chunk edges
  local minposxyz = {x=x0, y=y0, z=z0} --bottom corner

  local nvals_walls = minetest.get_perlin_map(np_walls, chulens):get3dMap_flat(minposxyz) -- Get the noise map for the rift walls

  local changed=false

  local nixyz = 1 --3D node index

  for z = z0, z1 do -- for each xy plane progressing northwards
    for y = y0, y1 do -- for each x row progressing upwards
      local vi = area:index(x0, y, z) --This accesses the node at a given position.  vi is incremented inside the loop for greater performance.
      for x = x0, x1 do -- for each node do
      --local vi = area:index(x, y, z) -- This accesses the node at a given position
      local grad = math.abs(x / fracrift_edge) * (10^(math.abs(x / fracrift_edge)) / 10) -- Density gradient.  This controls how much to offset the noise value as x approaches the walls of the chasm.

      if x > -fracrift_edge and x < fracrift_edge then  -- If within chasm-generating limits

        if ((math.abs(nvals_walls[nixyz]) - grad) > 0) then -- Check the value of the perlin noise at this position with respect to distance from center
          if data[vi] ~= c_air then
            data[vi] = c_air -- Hollow out the chasm with smooth walls
          end
        else
          if (x < -fracrift_edge/3 or x > fracrift_edge/3) then -- Put limits in to make sure the chasm always stays at least some ways open
            if data[vi] == c_water then -- If there's water, make it wall material so as not to drain the oceans :P
              data[vi] = c_fracrift_material
            end
          else
            if (x > -fracrift_edge/3 or x < fracrift_edge/3) then -- In the limits, always hollow this
              data[vi] = c_air
            end
          end
        end
      changed = true
      end -- if x > -fracrift_edge and x < fracrift_edge

      if x == -fracrift_edge or x == fracrift_edge then  -- x is on edge
        if data[vi] == c_water and math.random() < fracrift_waterfallchance and (math.abs(nvals_walls[nixyz]) - grad) > -0.1 then
          data[vi]=c_fracrift_material
          changed=true
        end -- change water to stone on edge
      end -- if x == -fracrift_edge or x == fracrift_edge

      nixyz = nixyz + 1
      vi = vi + 1

      end -- end 'x' loop
    end -- end 'y' loop
  end -- end 'z' loop

  if changed==true then
    -- Wrap things up and write back to map
    --send data back to voxelmanip
    vm:set_data(data)
    --calc lighting
    vm:set_lighting({day=0, night=0})
    vm:calc_lighting()
    --write it to world
    vm:write_to_map(data)
  end --if changed write to map

  local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
  print ("[fracrift_ure_gen] "..chugent.." ms") --tell people how long
end) --register_on_generated fracture generation



