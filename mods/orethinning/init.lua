---
--- constants
---
--this is the distance from spawn where ore will be at max density
--anything past that will still be at max density.  it's best to have
--the max density of ore back from the edge of the world a bit.
--remember this distance is calculated in 3d, if you set it at 30000
--then a player at -20000,-10000,-20000 will reach the max density point
--with 45000 max density will be reached at -26000,-26000,-26000
--still might need to be bigger than that.
local orethin_maxdist=45000
local orethin_maxheight=100
local orethin_mindensity=0.05
local orethin_eastadj=0.5   --remember this is chance to THIN, so bigger numbers mean less ore
local orethin_westadj=1
--this needs to be further parameterized, allow the east west border to be parameterized, etc.





--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_water = minetest.get_content_id("default:water_source")
local c_lava = minetest.get_content_id("default:lava_source")
local c_iron = minetest.get_content_id("default:stone_with_iron")
local c_coal = minetest.get_content_id("default:stone_with_coal")
local c_copper = minetest.get_content_id("default:stone_with_copper")
local c_mese = minetest.get_content_id("default:stone_with_mese")
local c_meseblock = minetest.get_content_id("default:mese")
local c_esem = minetest.get_content_id("default:stone_with_esem")
local c_esemblock = minetest.get_content_id("default:esem")
local c_diamond = minetest.get_content_id("default:stone_with_diamond")
local c_goldblock = minetest.get_content_id("default:goldblock")
local c_diamondblock = minetest.get_content_id("default:diamondblock")
local c_drydirt =  minetest.get_content_id("default:dry_dirt")

--I would love to do these as const arrays, but I'm afraid
--it would slow the logic down.
local orethin_thinlist={minetest.get_content_id("default:stone_with_iron"),
                       minetest.get_content_id("default:stone_with_coal"),
                       minetest.get_content_id("default:stone_with_copper"),
                       minetest.get_content_id("default:stone_with_mese"),
                       minetest.get_content_id("default:mese"),
                       minetest.get_content_id("default:stone_with_esem"),
                       minetest.get_content_id("default:esem"),
                       minetest.get_content_id("default:stone_with_diamond"),
                       minetest.get_content_id("default:goldblock"),
                       minetest.get_content_id("default:diamondblock")
                       }
--print("thinlist="..dump(orethin_thinlist))

--the list of ores that will appear in the west only
local orethin_westlist={minetest.get_content_id("default:stone_with_mese"),
                       minetest.get_content_id("default:mese"),
                       minetest.get_content_id("default:stone_with_esem"),
                       minetest.get_content_id("default:esem")
                       }
--print("westlist="..dump(orethin_westlist))

--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_stone = minetest.get_content_id("default:stone")
local c_goldblock = minetest.get_content_id("default:goldblock")
local c_diamondblock = minetest.get_content_id("default:diamondblock")


--thins linearly over the whole range to maxdist
function orethin_adj_linear(dist)
  return dist/orethin_maxdist
  end
  
--algorithm by HeroOfTheWinds that heavily thins for the
--first 1000 nodes before rapidly becoming abundant. 
function orethin_adj_exponental(dist)
  return (orethin_maxdist/(1+(orethin_maxdist-1)* math.exp(-.0075*dist))) / orethin_maxdist
  end
    
          
--chose the algorithm for ore thinning (comment out all others)
local orethin_adj_algorithm=orethin_adj_linear
--local orethin_adj_algorithm=orethin_adj_exponental


---ORE THINNING
minetest.register_on_generated(function(minp, maxp, seed)
   --if out of range of ore_gen limits (will need to change this when skylands implemented
   if minp.y > orethin_maxheight then
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

   print ("[ore_thin] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

   --This actually initializes the LVM
   local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
   local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
   local data = vm:get_data()

   --we do NOT need to recalculate adj for each and every node!
   --calculate it once for the entire cluster
   local dist = math.sqrt(x0^2 + y0^2 + z0^2)
   if dist > orethin_maxdist then
     dist=orethin_maxdist
   end --orethin_maxdist

   --local adj= (orethin_maxdist/(1+(orethin_maxdist-1)* math.exp(-.0075*dist))) / orethin_maxdist --(dist/orethin_maxdist)--original code.
   local adj=orethin_adj_algorithm(dist)
   
		--New code makes ore thin until about 1000 nodes away, and then it rapidly gets more common.  To adjust distribution, change the value currently at -.0075. Closer to 0 is more thinning, greater negative numbers are less thinning.
   if adj < orethin_mindensity then
     adj=orethin_mindensity    --because we don't want spawn completely bare
    end --min adj
   --adj for east
   if x0 > 0 then
     adj=adj*orethin_eastadj
   else
     adj=adj*orethin_westadj
   end
   print("[orethin] ("..x0..","..y0..","..z0..") dist="..dist.." orethin_maxdist="..orethin_maxdist.." adj="..adj)


   local changed=false
   for z = z0, z1 do -- for each xy plane progressing northwards
      for y = y0, y1 do -- for each x row progressing upwards
         --local vi = area:index(x0, y, z) -- This accesses the node at a given position
		 local vi = area:index(x0, y, z) --Switched to incrementing form for slight speed increase.
         for x = x0, x1 do -- for each node do
            --local vi = area:index(x, y, z) -- This accesses the node at a given position
            --x>0 is east, so we exclude ores in the west only list
            --cant search arrays that way when the elements are numbers.
            --if x > 0 and orethin_westlist.data[vi] then
            if x > 0 and (data[vi] == c_mese or
                          data[vi] == c_meseblock or
                          data[vi] == c_esem or
                          data[vi] == c_esemblock ) then
               data[vi] = c_stone  -- remove the ore
               --data[vi] = c_diamondblock  --*VIEWTHINNING* uncomment this line to make it easy to see removal
               changed=true
            -- Now test the node if it's an ore that needs to be potentially thinned out
            --elseif orethin_thinlist[data[vi]] then
            elseif data[vi] == c_iron or
                   data[vi] == c_copper or
                   data[vi] == c_diamond or
                   data[vi] == c_mese or
                   data[vi] == c_meseblock or
                   data[vi] == c_esem or
                   data[vi] == c_esemblock then
               -- it is, so now thin it based on distance from center
               -- note the bigger adj is, the smaller the chance of thinning.
               if math.random() > adj then
                  data[vi] = c_stone  -- remove the ore
                  --data[vi] = c_goldblock --*VIEWTHINNING* uncomment this line to make it easy to see thinning
                  changed=true
               end
            end -- end ore existence check
			vi = vi + 1 --increment the LVM index
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
   end

   local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
   print ("[ore_thin] "..chugent.." ms") --tell people how long
end) --register_on_generated ore thinning

