local c_water_source = minetest.get_content_id("default:water_source")

--this is a generic function for looping through a 2dMap and applying details from surface
--it expects the surface map to be in parms.share.surface
--and it expects each surface[z][x] element to have a top, and a biome
--********************************
function tf_generic_2dMap_loop(parms)
--here is where we actually do the work of generating the landscape.
--we loop through as z,y,x because that is way the voxel info is stored, so it is most efficent.
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				local sfc=parms.share.surface[z][x]
				local biome=sfc.biome
				local sealevel=parms.sealevel
				--set some default values 
				if sfc.top_depth==nil then sfc.top_depth=1 end
				if sfc.filler_depth==nil then sfc.filler_depth=6 end
				sfc.top_bot=sfc.top+(sfc.top_depth-1)
				sfc.fil_bot=sfc.top_bot-sfc.filler_depth 
				if sfc.water_top_depth==nil then sfc.water_top_depth=99999 end

				--anything lower than our surface filler bottom gets node_stone from biome
				if y<sfc.fil_bot then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_stone)

				--anything between filler bottom and top bottom (and not under sealevel) gets the filler node from biome
				elseif y<sfc.top_bot then 
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)

				--for those rare cases where top_depth>1
				elseif y<sfc.top then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)

				--if this is the top, set top node from biome, and ALSO call the decorate function (if it exists)
				elseif y==sfc.top then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_top)
					if biome.decorate~=nil then biome.decorate(x,y+1,z, biome, parms) end

				--if we are at top+1 apply dust node from biome (if it exists)
				elseif y==sfc.top+1 and sfc.top>sealevel and biome.node_dust~=nil then
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_dust)

				--and if we are above the top, but under sea level, put water
				elseif y>sfc.top and y<=sealevel then
					local water_node=c_water_source
					if biome.node_water_top~=nil then
						if y>=sealevel-sfc.water_top_depth then water_node=biome.node_water_top end
					end --if biome.node_water_top~=nil
					luautils.place_node(x,y,z, parms.area, parms.data, water_node)
					
				--putting air just messes up the decorations since we work our way from bot to top
				--elseif y>dirttop[z][x] then luautils.place_node(x,y,z, parms.area, parms.data, c_air)
				end --if y
			end --for x
		end --for y
	end --for z
end --tf_generic_2dMap_loop




