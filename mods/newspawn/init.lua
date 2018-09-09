--

---
--- constants
---
local nspawn_pos={x=60,y=5,z=0}
--do not set static_spawn in minetest.conf, this will override it.


local nspawn_radius=5
local nspawn_steps=10
--local nspawn_material=minetest.get_content_id("default:brick")
local nspawn_material=minetest.get_content_id("fractured:dry_dirt")
local nspawn_shape="C"    --"C"=circle "S"=square

--calculated constants
nspawn_pos.y=nspawn_pos.y-1   --surface should be BELOW where player spawns
nspawn_totrad=nspawn_radius+nspawn_steps
local nspawn_min={x=nspawn_pos.x-nspawn_radius,
                     y=nspawn_pos.y-nspawn_steps,
                     z=nspawn_pos.z-nspawn_radius}
local nspawn_max={x=nspawn_pos.x+nspawn_radius,
                     y=nspawn_pos.y,
                     z=nspawn_pos.z+nspawn_radius}
local nspawn_stepmin={x=nspawn_pos.x-nspawn_totrad,
                         y=nspawn_pos.y-nspawn_totrad,
                         z=nspawn_pos.z-nspawn_totrad}
local nspawn_stepmax={x=nspawn_pos.x+nspawn_totrad,
                         y=nspawn_pos.y+nspawn_totrad*2,
                         z=nspawn_pos.z+nspawn_totrad}

--Make spawn match nspawn_pos set above
minetest.setting_set("static_spawnpoint", nspawn_pos.x..","..nspawn_pos.y..","..nspawn_pos.z)
--[[ Saving this just in case I decide I need it.
minetest.register_on_newplayer(
  function(player)
  minetest.after(5, function()player:setpos({x=0, y=1, z=0})end) -- I guess a semi hacky way of making sure the singleplayer lands on obsidian
  end
  )
--]]


--print("**ZZ** nspawn_pos="..dump(nspawn_pos).." min="..dump(nspawn_min).." max="..dump(nspawn_max).." nspawn_stepmin="..dump(nspawn_stepmin).." nspawn_stepmax="..dump(nspawn_stepmax))

--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")

--
-- Aliases for map generator outputs
--




function squarenewspawn(minp, maxp, seed)
    --dont bother if we are not near new spawn
    if minp.x > nspawn_stepmax.x or maxp.x < nspawn_stepmin.x and
       minp.y > nspawn_stepmax.y or maxp.y < nspawn_stepmin.y and
       minp.z > nspawn_stepmax.z or maxp.z < nspawn_stepmin.z then
      --print("rejected: min=("..minp.x..","..minp.y..","..minp.z..") max=("..maxp.x..","..maxp.y..","..maxp.z..")")
      return --quit; otherwise, you'd have wasted resources
    end
    --print("accepted: min=("..minp.x..","..minp.y..","..minp.z..") max=("..maxp.x..","..maxp.y..","..maxp.z..")")

    --easy reference to commonly used values
    local t1 = os.clock()
    local x1 = maxp.x
    local y1 = maxp.y
    local ymax=maxp.y
    local z1 = maxp.z
    local x0 = minp.x
    local y0 = minp.y
    local ymin=minp.y
    local z0 = minp.z



     print ("[newspawn_gen] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

     --This actually initializes the LVM
     local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
     local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
     local data = vm:get_data()

     local changed=false

     for z = z0, z1 do --
       for x = x0, x1 do --
         --calculate distance 2d
         --local dist= math.sqrt((x-nspawn_pos.x)^2+(z-nspawn_pos.z)^2)
         --print("if ("..x.." y "..z..") dist="..dist.." nspawn_totrad="..nspawn_totrad)
         --if dist <= nspawn_totrad then -- x and z inside blast circle radius
           --spawndone=0
           local y = y1
           repeat --loop through y values from top to bottom
             local vi = area:index(x, y, z) -- This accesses the node at a given position
             --print("loop top -> ("..x.." "..y.." "..z..")  vi="..vi)

             --this code tries to make the new spawn usable by ensuring
             --a flat landing space at the specified coords, AND trying to
             --build steps up or down if the landing space is not level with the surface

             --is this the spawn square?
             if x>=nspawn_min.x and x<=nspawn_max.x and
                z>=nspawn_min.z and z<=nspawn_max.z then
               --inside spawn square
               --if y is below newspawn fill it
               --we are moving top down, so we won't fill below spawn
             --print("spawn square: ("..x.." "..y.." "..z..") dist="..dist)
             if y>=nspawn_min.y and y<=nspawn_max.y then
                 --print("   changed to material")
                 data[vi]=nspawn_material
                 changed=true
               --if y is above newspawn and its not air, make it air
               elseif y>nspawn_max.y and data[vi]~=c_air then
                 --print("   changed to air")
                 data[vi]=c_air
                 changed=true
               end --if y>=nspawn_min.y

             --so now we have a nice square landing space, lets build those steps

             --is this the STEPS of the spawn square (where we try to merge it
             --into the background so players can get up or down)
             elseif x>=nspawn_stepmin.x and x<=nspawn_stepmax.x and
                    z>=nspawn_stepmin.z and z<=nspawn_stepmax.z then
               --we are in the steps area, calculate what row out we are from newspawn
               local stepdistx=0
               local stepdistz=0
               if x<nspawn_min.x then stepdistx=math.abs(x-nspawn_min.x)
               elseif x>nspawn_max.x then stepdistx=math.abs(x-nspawn_max.x) end
               if z<nspawn_min.z then stepdistz=math.abs(z-nspawn_min.z)
               elseif z>nspawn_max.z then stepdistz=math.abs(z-nspawn_max.z) end
               local stepdist=stepdistx
               if stepdistz>stepdistx then stepdist=stepdistz end
               --print("steps: ("..x.." "..y.." "..z..") dist="..dist.." stepdistx="..stepdistx.." stepdistz="..stepdistz.." stepdist="..stepdist)
               --so now we know which step around new-spawn we are on.  (stepdist)
               --remove anything above spawn more than spawn.y+stepdist
               if y > nspawn_pos.y+stepdist and data[vi] ~= c_air then
                 data[vi]=c_air
                 --print("   steps: changed to air")
                 changed=true
               --turn to dirt if we find air below spawn more than y-stepdist
               elseif y <= nspawn_pos.y-stepdist and data[vi] == c_air then
                 data[vi]=nspawn_material
                 --print("   steps: changed to material")
                 changed=true
               end -- if y > nspawn_pos.y+stepdist
              end -- if x>=nspawn_min.x and x<=nspawn_max.x
             y=y-1
           until y < y0 or data[vi] == nspawn_material
         --end -- if in new spawn area
       end -- end 'x' loop
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
       --print(">>>saved")
     end --if changed write to map

     local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
     print ("[newspawn_gen] "..chugent.." ms") --tell people how long
  end -- register_on_generated fucntion for square new spawn



function circlenewspawn(minp, maxp, seed)
  --dont bother if we are not near new spawn
  if minp.x > nspawn_stepmax.x or maxp.x < nspawn_stepmin.x and
     minp.y > nspawn_stepmax.y or maxp.y < nspawn_stepmin.y and
     minp.z > nspawn_stepmax.z or maxp.z < nspawn_stepmin.z then
    --print("rejected: min=("..minp.x..","..minp.y..","..minp.z..") max=("..maxp.x..","..maxp.y..","..maxp.z..")")
    return --quit; otherwise, you'd have wasted resources
  end
  --print("accepted: min=("..minp.x..","..minp.y..","..minp.z..") max=("..maxp.x..","..maxp.y..","..maxp.z..")")

  --easy reference to commonly used values
  local t1 = os.clock()
  local x1 = maxp.x
  local y1 = maxp.y
  local ymax=maxp.y
  local z1 = maxp.z
  local x0 = minp.x
  local y0 = minp.y
  local ymin=minp.y
  local z0 = minp.z

  print ("[newspawn_gen] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

  --This actually initializes the LVM
  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
  local data = vm:get_data()

  local changed=false

  for z = z0, z1 do --
    for x = x0, x1 do --
      --calculate distance 2d
      local dist= math.sqrt((x-nspawn_pos.x)^2+(z-nspawn_pos.z)^2)
      --print("top ("..x.." y "..z..") dist="..dist.."nspawn_radius="..nspawn_radius.." nspawn_totrad="..nspawn_totrad)
      if dist <= nspawn_totrad then -- x and z inside new spawn radius
        --print("--if1 ("..x.." y "..z..") dist="..dist.."nspawn_radius="..nspawn_radius.." nspawn_totrad="..nspawn_totrad)
        local y = y1
        repeat --loop through y values from top to bottom
          local vi = area:index(x, y, z) -- This accesses the node at a given position

          --this code tries to make the new spawn usable by ensuring
          --a flat landing space at the specified coords, AND trying to
          --build steps up or down if the landing space is not level with the surface

          --is this the spawn circle?
          if dist<=nspawn_radius then
            --print("if2 ("..x.." "..y.." "..z..") dist="..dist.."nspawn_radius="..nspawn_radius.." nspawn_totrad="..nspawn_totrad)

            --inside spawn circle
            --if y is below newspawn fill it
            --we are moving top down, so we won't fill below spawn
           if y>=nspawn_min.y and y<=nspawn_max.y then
              --print("   changed to material")
              data[vi]=nspawn_material
              changed=true
            --if y is above newspawn and its not air, make it air
            elseif y>nspawn_max.y and data[vi]~=c_air then
              --print("   changed to air")
              data[vi]=c_air
              changed=true
            end --if y>=nspawn_min.y

          --so now we have a nice landing space, lets build those steps

          --is this the STEPS of the spawn area (where we try to merge it
          --into the background so players can get up or down)
          elseif dist<=nspawn_totrad then
            --we are in the steps area, calculate what row out we are from newspawn
            local stepdist=dist-nspawn_radius
            --print("if3 ("..x.." "..y.." "..z..") dist="..dist.."nspawn_radius="..nspawn_radius.." nspawn_totrad="..nspawn_totrad.." stepdist="..stepdist)

            --so now we know which step around new-spawn we are on.  (stepdist)
            --remove anything above spawn more than spawn.y+stepdist
            if y > nspawn_pos.y+stepdist and data[vi] ~= c_air then
              data[vi]=c_air
              --print("   steps: changed to air")
              changed=true
            --turn to dirt if we find air below spawn more than y-stepdist
            elseif y <= nspawn_pos.y-stepdist and data[vi] == c_air then
              data[vi]=nspawn_material
              --print("   steps: changed to material")
              changed=true
            end -- if y > nspawn_pos.y+stepdist
           end -- if x>=nspawn_min.x and x<=nspawn_max.x
          y=y-1
        until y < y0 or data[vi] == nspawn_material
      end -- if dist (in new spawn area)
    end -- end 'x' loop
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
    --print(">>>saved")
  end --if changed write to map

  local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
  print ("[newspawn_gen] "..chugent.." ms") --tell people how long
end -- roundnewspawn


 --NEW SPAWN
if nspawn_shape=="S" then
   minetest.register_on_generated(squarenewspawn)
elseif nspawn_shape=="C" then
   minetest.register_on_generated(circlenewspawn)
end
