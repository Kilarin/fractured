-- mods/default/mapgen.lua

fractured = {} --Global container for variables accessed by other mods

---
--- constants
---
fractured.iswild = function(pos)
	return pos.x < 0
end --iswild

fractured.wilddist = function(pos)
  --good programming would use iswild here, but this will be called
	--a LOT, so probably best to save the function call and hard code.
	if pos.x < 0 then
		return math.sqrt((pos.x*2)^2 + pos.y^2 + pos.z^2)
	end
	return -math.sqrt(pos.x^2 + pos.y^2 + pos.z^2)
end --wilddist


--minetest.register_on_generated(function(minp, maxp, seed)
--  --I want to vary from .5 to .67
--	local dist=wilddist(minp)
--	local
--	--return dist/orethin_maxdist
--
--.67-.5=	0.17
--0.2/32000=0.00000625
