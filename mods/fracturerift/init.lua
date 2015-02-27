-- mods/default/mapgen.lua

---
--- constants
---

local fracrift_width=20                 --how wide the rift will be
local fracrift_depth_air=20             --how deep before the water
local fracrift_depth_water=20           --how deep the water will be
local fracrift_top=100                  --max height to scan for land to remove
local fracrift_bottomsmooth=0.995       --odds of bottom being smooth
local fracrift_waterfallchance=0.997    --odds of NOT having a waterfall hole in wall
local fracrift_material=minetest.get_content_id("default:stone")
                        minetest.get_content_id("default:stone")

--calculated constants
local fracrift_half=fracrift_width/2
local fracrift_edge=fracrift_half+1
local fracrift_depth=-(fracrift_depth_air+fracrift_depth_water)
local fracrift_waterstart=-(fracrift_depth_air+1)

--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")
local c_water = minetest.get_content_id("default:water_source")



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
   if x0 < -fracrift_edge then x0=-fracrift_edge end
   if x1 > fracrift_edge then x1=fracrift_edge end
   if y0 < fracrift_depth then y0=fracrift_depth end
   if y1 > fracrift_top then y1=fracrift_top end

   print ("[fracrift_ure_gen] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

   --This actually initializes the LVM
   local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
   local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
   local data = vm:get_data()

   local changed=false
   for z = z0, z1 do -- for each xy plane progressing northwards
     for y = y0, y1 do -- for each x row progressing upwards
       for x = x0, x1 do -- for each node do
         local vi = area:index(x, y, z) -- This accesses the node at a given position
         if x > -fracrift_edge and x < fracrift_edge then
           if y > fracrift_depth then
             if y < fracrift_waterstart then  -- air or water based on y
               if data[vi] ~= c_water then --not water
                 if y > (fracrift_depth+1) then
                   data[vi]=c_water
                   changed=true
                 --roughen up very bottom layer a little bit
                 elseif math.random() < fracrift_bottomsmooth then
                   --leave a FEW bumps sticking up
                   data[vi]=c_water
                   changed=true
                 end -- if y > (fracrift_depth+1)
               end -- if data[vi] ~= c_water
             elseif y < fracrift_top and data[vi] ~= c_air then
               data[vi]=c_air
               changed=true
             end --if y < fracrift_waterstart
           end -- if y > -fracrift_depth
         end -- if x > -fracrift_edge and x < fracrift_edge
         if x == -fracrift_edge or x == fracrift_edge then  -- x is on edge
           if data[vi] == c_water and math.random() < fracrift_waterfallchance then
             data[vi]=fracrift_material
             changed=true
           end -- change water to stone on edge
         end -- if x == -fracrift_edge or x == fracrift_edge
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



