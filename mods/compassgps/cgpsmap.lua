--original code for storing bookmarks outside of the compass by TeTpaAka
--modifications by Kilarin and Miner59

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end


local selected_cgpsmap = {}
local textlist_bookmark = {}
local selected_bookmark = {}

function write_to_cgpsmap(itemstack, user)
  --print("write_to_cgpsmap")
	selected_cgpsmap[user:get_player_name()] = itemstack
	local list,bkmrkidx=compassgps.bookmark_loop("M", user:get_player_name())
	if list == "" then
		return nil
	end
	textlist_bookmark[user:get_player_name()] = list
	local formspec = "size[9,10;]"..
			"button_exit[2,2;5,0.5;write;"..S("Write to cgpsmap").."]"..
			"textlist[0,3.0;9,6;bookmark_list;"..list..";"..bkmrkidx.."]"
	minetest.show_formspec(user:get_player_name(), "compassgps:write", formspec)
  --print("write_to_cgpsmap end")
end


function read_from_cgpsmap(itemstack, user, meta)
  --print("read_from_cgpsmap")
	selected_cgpsmap[user:get_player_name()] = itemstack
	if not meta then  --marked map from creative or /giveme has no meta!
    meta={bkmrkname="default",x=0,y=0,z=0}
    itemstack:set_metadata(minetest.serialize(meta))
	end

	local formspec = "size[9,5]"..
      "label[2,0.5;"..S("bookmark pos:").." ("..meta["x"]..","..meta["y"]..","..meta["z"]..")]"..
      "field[2,2;5,0.5;name;"..S("bookmark name:")..";"..meta["bkmrkname"].."]"..
			"button_exit[2,3;5,0.5;read;"..S("copy bookmark to your compassgps").."]"

	minetest.show_formspec(user:get_player_name(), "compassgps:read", formspec)
  --print("read_from_cgpsmap end")
end



minetest.register_craft({
	output = 'compassgps:cgpsmap',
	recipe = {
		{'default:paper', '', 'default:paper'},
		{'', 'default:paper', ''},
		{'default:paper', '', 'default:paper'}
	}
})

minetest.register_craft({
	output = 'compassgps:cgpsmap',
	recipe = {
		{'compassgps:cgpsmap_marked'},
	}
})

minetest.register_craftitem("compassgps:cgpsmap", {
	description = S("CompassGPS Map (blank)"),
	inventory_image = "cgpsmap-blank.png",
	--group = {book = 1},
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		write_to_cgpsmap(itemstack, user)
		return
	end
})

minetest.register_craftitem("compassgps:cgpsmap_marked", {
	description = S("CompassGPS Map (marked)"),
	inventory_image = "cgpsmap-marked.png",
  groups = {not_in_creative_inventory=1},
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local meta = minetest.deserialize(itemstack:get_metadata())
		read_from_cgpsmap(itemstack, user, meta)
		return nil
	end
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if (formname == "compassgps:write") then
		if not player then
			return
		end
		local playername = player:get_player_name();
		if (playername ~= "") then
			if (selected_cgpsmap[playername] == nil) then
				return
			end
			if fields["bookmark_list"] then
				-- to get the currently selected
				local id = minetest.explode_textlist_event(fields["bookmark_list"])
				selected_bookmark[playername] = id.index
			end
			if fields["write"] then
        --print("***cgpsmap fields=write***")
				if selected_bookmark[playername] == nil then
					return nil
				end
        local bkmrk=textlist_bkmrks[playername][selected_bookmark[playername]]
        local write = { ["bkmrkname"] = bkmrk.bkmrkname,
                        x = bkmrk.x,
                        y = bkmrk.y,
                        z = bkmrk.z}
        --print("dump(write)="..dump(write))
      	selected_cgpsmap[playername]:set_name("compassgps:cgpsmap_marked")
				selected_cgpsmap[playername]:set_metadata(minetest.serialize(write))
				player:set_wielded_item(selected_cgpsmap[playername])
			end
		end
	end
	if (formname == "compassgps:read") then
		if not player then
			return
		end
		if (fields["read"]) then
      --print("***cgpsmap fields=read***")
			local meta = minetest.deserialize(selected_cgpsmap[player:get_player_name()]:get_metadata())
      --print("dump(meta)="..dump(meta))
      local bkmrkname = fields["name"]
      --print("bkmrkname from fields[name]="..bkmrkname)
			local pos = {	x = meta["x"] + 0,
					y = meta["y"] + 0,
					z = meta["z"] + 0 }
			local playername = player:get_player_name()
			--print(bkmrkname)
			compassgps.set_bookmark(playername, bkmrkname, "P", pos)
		end
	end

end)


