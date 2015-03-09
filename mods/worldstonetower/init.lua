--

---
--- constants
---
local wst_pos={x=0,y=0,z=0}
local wst_radius=15
local wst_length = fracturerift.width + 20
local wst_floorheight=8
local wst_shrinkheight=20

local wst_floorholeodds=0.1
local wst_wallholeodds=0.01

local c_wall = minetest.get_content_id("default:obsidianbrick")
local c_floor = minetest.get_content_id("default:desert_stonebrick")
local c_stair = minetest.get_content_id("stairs:stair_obsidianbrick")

--local wst_start={x=0,y=0,z=0}  --where to start trying to put the tower.
--local wst_lookdist=100 --distance to look for starting point.


--calculated constants
wst_radiussq=wst_radius^2
--these have to be done later
local wst_min={x=wst_pos.x-math.floor(wst_length/2),
               y=wst_pos.y-wst_radius,
               z=wst_pos.z-wst_radius}
local wst_max={x=wst_pos.x+math.floor(wst_length/2),
               y=wst_pos.y+wst_radius,
               z=wst_pos.z+wst_radius}


--print("**ZZ** nspawn_pos="..dump(nspawn_pos).." min="..dump(nspawn_min).." max="..dump(nspawn_max).." nspawn_stepmin="..dump(nspawn_stepmin).." nspawn_stepmax="..dump(nspawn_stepmax))

--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")

-- 3D noise for tower damage
local np_dmg = {
	offset = 0,
	scale = 1,
	--spread = {x=192, y=512, z=512}, -- squashed 2:1
	--spread = {x=200, y=80, z=80},
	spread = {x=15, y=8, z=8},
	seed = 314159, --everyone loves pi(e)
	octaves = 3,
	persist = 0.67
}
local wst_dmg_lvl=0.7 --threshold for holes in the tower.  Smaller means larger holes



minetest.register_on_generated(function(minp, maxp, seed)
  --dont bother if we are not near new spawn
  --print("[wst] minp="..dump(minp).." maxp="..dump(maxp).." wstmin="..dump(wst_min).." wstmax="..wst_max)
  if minp.x > wst_max.x or maxp.x < wst_min.x and
    minp.y > wst_max.y or maxp.y < wst_min.y and
    minp.z > wst_max.z or maxp.z < wst_min.z then
    --print("rejected: min=("..minp.x..","..minp.y..","..minp.z..") max=("..maxp.x..","..maxp.y..","..maxp.z..")")
    return --quit; otherwise, you'd have wasted resources
  end -- if minp.x
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

  print ("[wst_gen] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk
  --if x0<wst_min.x then x0=wst_min.x end
  --if x1>wst_max.x then x1=wst_max.x end
  --if y0<wst_min.y then y0=wst_min.y end
  --if y1>wst_max.y then y1=wst_max.y end
  --if z0<wst_min.z then z0=wst_min.z end
  --if z1>wst_max.z then z1=wst_max.z end

  --This actually initializes the LVM
  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
  local data = vm:get_data()

  local sidelen = x1 - x0 + 1 --length of a mapblock
  local chulens = {x=sidelen, y=sidelen, z=sidelen} --table of chunk edges
  local minposxyz = {x=x0, y=y0, z=z0} --bottom corner
  local nvals_dmg = minetest.get_perlin_map(np_dmg, chulens):get3dMap_flat(minposxyz) -- Get the noise map for the rift walls

  local nixyz=1
  --print("***---*** "..dump(nvals_dmg))
  --print("***XXX*** "..nvals_dmg[1])
  local xbeg=wst_pos.x-wst_length/2
  local radius=wst_radius
  for z = z0, z1 do --
    for y = y0, y1 do --
      local vi = area:index(x0, y, z) --This accesses the node at a given position.  vi is incremented inside the loop for greater performance.
      for x = x0, x1 do --
        --calculate distance y,z from center of circle
        if x>=wst_min.x and x<=wst_max.x and
           y>=wst_min.y and y<=wst_max.y and
           z>=wst_min.z and z<=wst_max.z then
          local yzdist= math.floor(math.sqrt((y-wst_pos.y)^2+(z-wst_pos.z)^2))
          --print("x="..x.." y="..y.." z="..z.." yzdist="..yzdist.." wst_radius="..wst_radius)
          local xdist=math.abs((x-xbeg))+1
          radius=wst_radius-(math.floor(xdist/wst_shrinkheight))
          if yzdist==radius then
            if math.abs(nvals_dmg[nixyz]) > wst_dmg_lvl then
				data[vi] = c_air
            else       
				data[vi] = c_wall
            end
          elseif yzdist<radius then
            if (xdist/wst_floorheight)== math.floor(xdist/wst_floorheight) and
                math.abs(nvals_dmg[nixyz]) <= wst_dmg_lvl then                     
				data[vi] = c_floor
            else    
				data[vi] = c_air                
            end -- if (xdist/wst_floorheight)
          end --if yzdist
        end --if x>=wst_min.x
		nixyz = nixyz + 1
		vi = vi + 1
      end -- end 'x' loop
    end -- end 'y' loop
  end -- end 'z' loop

  -- Wrap things up and write back to map
  --send data back to voxelmanip
  vm:set_data(data)
  --calc lighting
  vm:set_lighting({day=0, night=0})
  vm:calc_lighting()
  --write it to world
  vm:write_to_map(data)
  --print(">>>saved")

  local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
  print ("[wst_gen] "..chugent.." ms") --tell people how long
end) -- register_on_generated fucntion for wst


