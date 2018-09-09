-- mods/default/mapgen.lua

---
--- constants
---

local blastrad_radius=100              --how wide should the blast radius be around 0,0
--this percentage of the outer edge of the blast radius will be scattered with dry
--dirt instead of all dry dirt.  so a scatter of 0.25 means the last 25% of the blast
--radius will gradually become less and less dried dirt
local blastrad_scatter=0.25            --percentage of blastrad to scatter instead of solid
local blastrad_steps=0.30              --percentage of blastrad to start steping up or down to natural height
local blastrad_top=150                 --don't bother blasting higher than this
local blastrad_surface=0               --the blast radius surface
local blastrad_deep=3                  --how deep to change existing material
local blastrad_bot=-20                 --don't bother blasting lower than this.



local c_blastmat = minetest.get_content_id("fractured:dry_dirt")


--caclulated constants
local blastrad_noscatter=1-blastrad_scatter
local blastrad_steprad=blastrad_radius*(1-blastrad_steps)
local blastrad_changebot=blastrad_surface-blastrad_deep



--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")


 --BLAST RADIUS
minetest.register_on_generated(function(minp, maxp, seed)
	--dont bother if we are not near 0,0
	if minp.x > blastrad_radius or maxp.x < -blastrad_radius or
		 minp.y > blastrad_top or maxp.y < blastrad_bot or
		 minp.z > blastrad_radius or maxp.z < -blastrad_radius then
		 return --quit; otherwise, you'd have wasted resources
	end

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

	--no reason to scan outside the y range we are changing.
		if y0 < blastrad_bot then
			y0 = blastrad_bot
		end
		if y1 > blastrad_top then
			y1 = blastrad_top
		end

	print ("[blast_gen] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

	--This actually initializes the LVM
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local changed=false

	for z = z0, z1 do --
		for x = x0, x1 do --
			local dist= math.floor(math.sqrt(x^2+z^2))
			if dist <= blastrad_radius then -- x and z inside blast circle radius
			  --local hitground = false

			  local step=0
				if dist > blastrad_steprad then
				  step = dist - blastrad_steprad
				end
				local local_surface_top = blastrad_surface+step
				local local_surface_bot = blastrad_surface-step

				local ignore = false
				if dist/blastrad_radius >= blastrad_noscatter and math.random() < (((dist/blastrad_radius)-blastrad_noscatter)/blastrad_scatter) then
				  ignore = true
				end

				local local_changebot=blastrad_changebot

				for y = y1, y0, -1 do
					local vi = area:index(x, y, z) -- This accesses the node at a given position
          if y > local_surface_top and y <= blastrad_top and data[vi] ~= c_air then
					  data[vi] = c_air
						changed = true
					elseif (ignore == false) and
					       (y > local_surface_bot and y <= local_surface_top and data[vi] ~= c_air) or
								 (y <= local_surface_bot and y >= blastrad_bot ) then
						if data[vi] == c_air or y >= local_changebot then
							data[vi]=c_blastmat
							changed = true
							if local_changebot == blastrad_changebot then
							  local_changebot = y - (blastrad_deep-1)
							end
						end -- change below
					end --blast
					--blast area if
				end -- for y
			end -- if in blast area
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
	print ("[blast_gen] "..chugent.." ms") --tell people how long
end) -- register_on_generated blast radius

