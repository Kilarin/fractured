--Much much much gratitude to TeTpaAka for register_on_punchplayer
--that made this whole exercise trivial!


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


minetest.register_on_punchplayer(
  function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	  if iswild(player:getpos()) then return false
		else return true
		end --if
	end) --register_on_punchplayer





