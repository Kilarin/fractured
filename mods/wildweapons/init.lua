
--if fractured exists, get iswild and wilddist from there
--otherwise default to west is wild
local iswild;
if minetest.get_modpath("fractured") then
  iswild = fractured.iswild
else
  iswild = function(pos)
    if pos.x < 0 then return true
    else return false
    end
  end --iswild
end --if fractured mod exists



--this function does damage if and ONLY if player is on the
--wild side of the world.  needs to deal with armor.
function wildweapon_onuse(itemstack, user, pointed_thing)
	if pointed_thing and pointed_thing.type == "object" then
		local obj = pointed_thing.ref
		if obj ~= nil then
			if iswild(obj:getpos()) then
				if obj:get_player_name() ~= nil then
					-- Player
					local cap = itemstack:get_tool_capabilities();
					obj:set_hp(obj:get_hp()-cap.damage_groups.fleshy)
				end--playername
			end--iswild
		end--obj ~= nil
	end--object
end



--loop through all defined tools, if it does fleshy dmg:
--change it's on_use function to be wildweapon_onuse,
--then the original on_use
for cou,def in pairs(minetest.registered_tools) do
  local old_on_use = def.on_use
	local cap = def.tool_capabilities
	--if this tool can damage someon
	if cap and cap.damage_groups and cap.damage_groups.fleshy then
	  --this basically creates a little stack so that we run the
		--new wildweapon_onuse first, then run whatever on_use
		--function was before.
		--this works because of the way lua handles scope, the old_on_use
		--variable will be stored in each new function we create with
		--the value it had at the time we created the function.
    minetest.override_item(def.name, {on_use =
		  function(itemstack, user, pointed_thing)
		    wildweapon_onuse(itemstack, user, pointed_thing)
				if old_on_use then
				  old_on_use(itemstack, user, pointed_thing)
				end
			end})
  end --if
end--for



