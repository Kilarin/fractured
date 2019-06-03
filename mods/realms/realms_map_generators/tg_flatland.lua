--[[
flatland is a very boring landscape generator that just generates an absolutely flat surface.  
It DOES utilize biomes if you pass a biomefunc
below is an example of a realms.conf entry that calls flatland:

    tg_flatland      |-33000| 25000|-33000| 33000| 26500| 33000|   26000|bm_mixed_biomes     |
--]]


--********************************
--function gen_tg_flatland(realm_minp,realm_maxp, sealevel, chunk_minp,chunk_maxp, seed)
function gen_tg_flatland(parms)
	--we dont need to check overlap because realms does that for us and passes us our intersect in isect_minp,isect_maxp
	local t1 = os.clock()

	local surface={}

--we generate a surface map so we can use biomes if we want
	local nixz=1
	for z=parms.isect_minp.z, parms.isect_maxp.z do
		surface[z]={}
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			surface[z][x]={}
			surface[z][x].top=parms.sealevel+5
			surface[z][x].bot=parms.sealevel-10
      surface[z][x].biome=realms.undefined_biome
			nixz=nixz+1
		end --for x
	end --for z

	parms.share.surface=surface --got to share it so the biomefunc can update it
	if parms.biomefunc~=nil then realms.rmf[parms.biomefunc](parms) end
	surface=parms.share.surface  --just in case the bf (biome func) replaced it

	for z=parms.isect_minp.z, parms.isect_maxp.z do
		for y=parms.isect_minp.y, parms.isect_maxp.y do
			for x=parms.isect_minp.x, parms.isect_maxp.x do
				local sfc=surface[z][x]
				local biome=sfc.biome
				if y<sfc.bot then luautils.place_node(x,y,z, parms.area, parms.data, biome.node_stone)
				elseif y<sfc.top then luautils.place_node(x,y,z, parms.area, parms.data, biome.node_filler)
				elseif y==sfc.top then 
					luautils.place_node(x,y,z, parms.area, parms.data, biome.node_top)
					if biome.decorate~=nil then biome.decorate(x,y+1,z, biome, parms) end
				end --if y
			end --for x
		end --for y
	end --for z

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("rmg tg_flatland-> END chunk="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_flatland

realms.register_mapgen("tg_flatland",gen_tg_flatland)


