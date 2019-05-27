
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
			surface[z][x].top=parms.sealevel
			surface[z][x].bot=parms.sealevel-20
      surface[z][x].biome=realms.dflt_biome
			nixz=nixz+1
		end --for x
	end --for z
	parms.share.surface=surface

  --*!* this should call a biome func!

	--this should loop z,x,y to be more efficient
	local c_material=c_stone
	for y=parms.isect_minp.y, parms.isect_maxp.y do
		--doing check here saves a little cpu (because we only check once per y) and isn't as ugly as 4 loops
		if y<parms.sealevel-20 then c_material=c_stone
		elseif y<parms.sealevel then c_material=c_dirt
		elseif y==parms.sealevel then c_material=c_grass
		elseif y>parms.sealevel then c_material=c_air
		end --if y
		for x=parms.isect_minp.x, parms.isect_maxp.x do
			for z=parms.isect_minp.z, parms.isect_maxp.z do
				local vi = parms.area:index(x, y, z) -- This accesses the node at a given position
				parms.data[vi]=c_material
			end --for z
		end --for x
	end --for y

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("rmg tg_flatland-> END chunk="..luautils.pos_to_str(parms.isect_minp).." - "..luautils.pos_to_str(parms.isect_maxp).."  "..chugent.." ms") --tell people how long
end -- gen_flatland

realms.register_mapgen("tg_flatland",gen_tg_flatland)


