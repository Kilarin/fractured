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



-- Dry Dirt  (copied from ethereal)
minetest.register_node("fractured:dry_dirt", {
description = "Dried Dirt",
tiles = {"ethereal_dry_dirt.png"},
is_ground_content = false,
groups = {crumbly=3} --,
--sounds = default.node_sound_dirt_defaults()
})


-- scorched trunk  copied from ethereal
minetest.register_node("fractured:scorched_tree", {
	description = "Scorched Tree",
	tiles = {
		"scorched_tree_top.png",
		"scorched_tree_top.png",
		"scorched_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 1},
	--sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})


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
