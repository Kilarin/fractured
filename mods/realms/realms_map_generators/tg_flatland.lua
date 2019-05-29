
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_air = minetest.get_content_id("air")



	--we calculate the surface top and bot first




--********************************
--function gen_tg_flatland(realm_minp,realm_maxp, sealevel, chunk_minp,chunk_maxp, seed)
function gen_tg_flatland(parms)
	--we dont need to check overlap because realms does that for us and passes us our intersect in isect_minp,isect_maxp
	local t1 = os.clock()
	--minetest.log("rmg gen_tg_flatland-> realm minp="..luautils.pos_to_str(parms.realm_minp).." maxp="..luautils.pos_to_str(parms.realm_maxp)..
	--" chunk minp="..luautils.pos_to_str(parms.chunk_minp).." maxp="..luautils.pos_to_str(parms.chunk_maxp))
	--minetest.log("    intersection minp="..luautils.pos_to_str(parms.isect_minp).." maxp="..luautils.pos_to_str(parms.isect_maxp).." sealevel="..parms.sealevel)

	local surface={}

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
				--elseif y>parms.sealevel then c_material=c_air
				end --if y
			end --for x
		end --for y
	end --for z

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("rmg tg_flatland-> END chunk="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_flatland

realms.register_mapgen("tg_flatland",gen_tg_flatland)


