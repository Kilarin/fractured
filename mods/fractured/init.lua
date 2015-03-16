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
