-- mods/default/mapgen.lua

fractured = {} --Global container for variables accessed by other mods

---
--- constants
---
fractured.iswild = function(pos)
	if pos.x < 0 then return true
	else return false
	end
end --iswild

fractured.wilddist = function(pos)
	--good programming would use iswild here, but this will be called
	--a LOT, so probably best to save the function call and hard code.
	if pos.x < 0 then
		return math.sqrt((pos.x*2)^2 + pos.y^2 + pos.z^2)
	else
		return -math.sqrt(pos.x^2 + pos.y^2 + pos.z^2)
	end
end --wilddist


local fractured_path = minetest.get_modpath("fractured")
dofile(fractured_path.."/nodes.lua")
dofile(fractured_path.."/craftitems.lua")
dofile(fractured_path.."/crafting.lua")
dofile(fractured_path.."/mapgen.lua")



--local player=minetest.get_player_by_name("singleplayer")
--if player~=nil then give_initial_stuff.give(minetest.get_player_by_name(player)) end

--minetest.register_on_generated(function(minp, maxp, seed)
--  --I want to vary from .5 to .67
--	local dist=wilddist(minp)
--	local
--	--return dist/orethin_maxdist
--
--.67-.5=	0.17
--0.2/32000=0.00000625
