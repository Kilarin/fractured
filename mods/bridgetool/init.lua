-----------------------------
-- Bridge Tool version 2.2 --
-----------------------------

--This code was written by Kilarin (Donald Hines)
--License:CC0, you can do whatever you wish with it.
--The numbers for the modes in the textures for this mode were copied and modified from
--the screwdriver mod by RealBadAngel, Maciej Kasatkin (which were originally licensed
--as CC BY-SA
--Topywo suggested adding wear, correcting down stair orientation, and using not_in_creative_inventory=1
--Sokomine suggested adding width so that you could build 2 or 3 wide.
--

local enable_chat_warn="YES"  --set to "NO" to turn off all chat error messages from this mod


local bridgetool = {
  --set this value to something higher than zero if you want bridge tool to wear out
	WEAR_PER_USE=0
}

local mode_text = {
	{"Forward"},
	{"Down"},
	{"Up"}
  }


function yaw_in_degrees(player)
  local yaw = player:get_look_yaw()*180/math.pi-90
  while yaw < 0 do yaw=yaw+360 end
  while yaw >360 do yaw=yaw-360 end
  return yaw
  end

function rotate_yaw(yaw,rotate)
  local newyaw=yaw+rotate
  if newyaw>360 then newyaw=newyaw-360 end
  if newyaw<0 then newyaw=newyaw+360 end
  return newyaw
end --rotate_yaw


--returns a node that has been offset in the indicated direction
--0+z,90-x,180-z,270+x: and <0 down -y,    >360 up +y
--I really could have, and probably should have, done this in radians.
--But I've always liked degrees better.
function offset_pos(posin,yaw)
  --print("** offset_pos yaw=",yaw," posin=",pos_to_string(posin))
  local posout = {x=posin.x,y=posin.y,z=posin.z}
  if yaw<0 then                  --DOWN
    posout.y=posout.y-1
  elseif yaw>360 then            --UP
    posout.y=posout.y+1
  elseif yaw>315 or yaw<45 then  --FORWARD
    posout.z=posout.z+1
  elseif yaw<135 then            --RIGHT
    posout.x=posout.x-1
  elseif yaw<225 then            --BACK
    posout.z=posout.z-1
  else                           --LEFT
    posout.x=posout.x+1
  end --yaw
  return posout
end --offset_pos



--because built in pos_to_string doesn't handle nil
function pos_to_string(pos)
  if pos==nil then return "(nil)"
  else return minetest.pos_to_string(pos)
  end --poss==nill
end --pos_to_string


--attempts to place the item and update inventory
function item_place(stack,player,pointed,inv,idx,mode,firststairface)
  if firststairface==nil then firststairface=-2 end
  local player_name = player:get_player_name()
  --minetest.chat_send_player(player_name,"--placing pointed.type="..pointed.type.." above "..pos_to_string(pointed.above).." under "..pos_to_string(pointed.under).." stack="..stack:to_string())
  local success
  stack, success = minetest.item_place(stack, player, pointed)
  if success then  --if item was placed, put modified stack back in inv
    inv:set_stack("main", idx, stack)
    --also check for rotation of stairs
    local itemname=stack:get_name()
    --minetest.chat_send_player(player_name,"name="..itemname.." gig="..minetest.get_item_group(itemname,"stairs"))
    --should be able to do this with get_item_group but I cant make it work
    if itemname~=nil and string.len(itemname)>7 and
         string.sub(itemname,1,7)=="stairs:" then      --and item is stairs
      local node = minetest.get_node(pointed.above)
      --if firststairface is set, then make all other stairs match same direction
      if firststairface>-1 and node.param2~=firststairface then
        node.param2=firststairface
        minetest.swap_node(pointed.above, node)
      elseif mode~=nil and mode==1 or mode==2 then   -- if mode=1(fwd) or 2(down) need to rotate stair
        node.param2=node.param2+2
        if node.param2>3 then node.param2=node.param2-4 end
        minetest.swap_node(pointed.above, node)
      end
      firststairface=node.param2
    end --stair
  end --success
  return stack,success,firststairface
end --item_place


-- add wear and tear to the bridge tool
function bridgetool_wear(item)
  if bridgetool.WEAR_PER_USE > 0 then
    local item_wear = tonumber(item:get_wear())
  	item_wear = item_wear + bridgetool.WEAR_PER_USE
    if item_wear > 65535 then
  		item:clear()
  		return item
  	end
  	item:set_wear(item_wear)
  	return item
  else
    return item
  end
end --bridgetool_wear


--This function is for use when the bridge tool is right clicked
--it finds the inventory item stack immediatly to the right of the bridge tool
--and then places THAT stack (if possible)
function bridgetool_place(item, player, pointed)
   local player_name = player:get_player_name()  --for chat messages
  --find index of item to right of wielded tool
  --(could have gotten this directly from item I suppose, but this works fine)
  local idx = player:get_wield_index() + 1
  local inv = player:get_inventory()
  local stack = inv:get_stack("main", idx) --stack=stack to right of tool
  if stack:is_empty() then
    if enable_chat_warn=="YES" then
      minetest.chat_send_player(player_name,"bridge tool: no more material to place in stack to right of bridge tool")
    end --chat_warn
  end --stack:is_empty
  if stack:is_empty()==false and pointed ~= nil then
    local success
    local yaw = yaw_in_degrees(player)  --cause degrees just work better for my brain
    --------------
    local mode
    local width
    mode,width=get_bridgetool_meta(item)
    if not mode then
      item=bridgetool_switchmode(item,player,pointed)
      mode,width=get_bridgetool_meta(item)
    end

    --minetest.chat_send_player(player_name, "pointed.type="..pointed.type.." above "..pos_to_string(pointed.above).." under "..pos_to_string(pointed.under).." yaw="..yaw.." mode="..mode)
    if pointed.type=="node" and pointed.under ~= nil then
      --all three modes start by placing a block forward in the yaw direction
      --under does not change, but above is altered to point to node forward(yaw) from under
      pointed.above=offset_pos(pointed.under,yaw)
      local holdforward=pointed.above   --store for later deletion in mode 2 and 3
      local firststairface
      stack,success,firststairface=item_place(stack,player,pointed,inv,idx,mode,-1)  --place the forward block
      if not success then
        if enable_chat_warn=="YES" then
          minetest.chat_send_player(player_name, "bridge tool: unable to place Forward at "..pos_to_string(pointed.above))
        end --chat_warn
      elseif mode==2 or mode==3 then --elseif means successs=true, check Mode up or down
        --mode 2 and 3 then add another block either up or down from the forward block
        --and remove the forward block
        ---move pointed under to the new block you just placed
        pointed.under=pointed.above
        if mode==2 then
          --try to place beneath the new block
          pointed.above=offset_pos(pointed.under,-1)
        else --mode==3
          --try to place above the new block
          pointed.above=offset_pos(pointed.under,999)
        end --mode 2 - 3
        stack,success=item_place(stack,player,pointed,inv,idx,mode,firststairface)
        if not success then
          if enable_chat_warn=="YES" then
            minetest.chat_send_player(player_name, "bridge tool: unable to place "..mode_text[mode][1].." at "..pos_to_string(pointed.above))
          end --chat_warn
        end --if not success block 2
        --remove the extra stone whether success on block 2 or not
        minetest.node_dig(holdforward,minetest.get_node(holdforward),player)
      end -- if not success block 1 elseif succes block 1 and mode 2 or 3

      --now try for the width
      if success then  --only proceed with width if last block placed was a success
        item=bridgetool_wear(item)
        for w=2,width do
          pointed.under=pointed.above --block 2 is now the under block
          local right90=rotate_yaw(yaw,-90)
          pointed.above=offset_pos(pointed.under,right90)
          --minetest.chat_send_player(player_name, " yaw="..yaw.." right90="..right90.." under="..pos_to_string(pointed.under).." above="..pos_to_string(pointed.above))
          stack,success=item_place(stack,player,pointed,inv,idx,mode,firststairface)
          if not success then
            if enable_chat_warn=="YES" then
              minetest.chat_send_player(player_name, "bridge tool: unable to place width "..w.." at "..pos_to_string(pointed.above))
            end --chat_warn
            break
          else
            item=bridgetool_wear(item)
          end --if not success
        end --for
      end --if success

    end --pointed.type="node" and pointed.under~=nil
  end --pointed ~= nil
return item
end --function bridgetool_place


--returns mode and width
function get_bridgetool_meta(item)
  local metadata = item:get_metadata()
  if not metadata or string.len(metadata)<3 then
    --not metadata means mode and width have never been set
    --metadata<3 means tool was created with a bridgetool 1.0 and doesn't have width set
    return nil, nil
  else --valid metadata
    local mode=tonumber(string.sub(metadata,1,1))
    local width=tonumber(string.sub(metadata,3,3))
    return mode, width
  end  -- if not metadata
end --get_bridgetool_meta


--on left click switch the mode of the bridge tool
--also deals with sneak-leftclick which sets width
function bridgetool_switchmode(item, player, pointed) --pointed is ignored
  local player_name = player:get_player_name()  --for chat messages
  local mode
  local width
  mode,width=get_bridgetool_meta(item)
  if mode==nil or width==nil then
    --if item has not been used and mode not set yet,
    --or a pre-width item that needs to have width added
    minetest.chat_send_player(player_name, "Left click to change mode between 1:Forward, 2:Down, 3:Up,  Leftclick+Sneak to change width, Right click to place, uses inventory stack directly to right of bridge tool")
    mode=1
    width=1
  else --valid mode and width
  	local keys = player:get_player_control()
    if keys["sneak"] == true then
      width=width+1
      if width>3 then width=1 end
    else
      mode=mode+1
      if mode>3 then mode=1 end
    end --if sneak
  end --not mode==nil
  --minetest.chat_send_player(player_name, "bridge tool mode : "..mode.." - "..mode_text[mode][1].."  width="..width)
	item:set_name("bridgetool:bridge_tool"..mode..width)
  item:set_metadata(mode..":"..width)
  return item
  end --bridgetool_switchmode


--we put the recipie inside an if checking for default so that
--in the unlikely case someone is running this without default,
--they still could.  they would just have to use /giveme or creative
--mode to get the tools
if minetest.get_modpath("default") then
  minetest.register_craft({
          output = 'bridgetool:bridge_tool',
    recipe = {
      {'default:steel_ingot', '', 'default:steel_ingot'},
      {'', 'default:steel_ingot', ''},
      {'', 'default:mese_crystal_fragment', ''},
    }
  })
end --if default


--this one appears in crafting lists and when you first craft the item
  minetest.register_tool("bridgetool:bridge_tool", {
    description = "Bridge Tool",
    inventory_image = "bridgetool_wield.png",
    wield_image = "bridgetool_wield.png^[transformR90",
    on_place = bridgetool_place,
    on_use = bridgetool_switchmode
  })

--these are the different tools for all 3 differen modes and widths
--bridgetool:bridge_tool11 12 13 21 22 23 31 32 33
--the reason for having different tools defined is so they can have
--an inventory image telling which mode/width the tool is in
--note that we set these to NOT show up in the creative inventory (Thanks Topywo for that advice!)
for m = 1, 3 do
  for w = 1, 3 do
    minetest.register_tool("bridgetool:bridge_tool"..m..w, {
      description = "Bridge Tool mode "..m.." width "..w,
      inventory_image = "bridgetool_m"..m..".png^bridgetool_w"..w..".png",
      wield_image = "bridgetool_wield.png^[transformR90",
      groups = {not_in_creative_inventory=1},
      on_place = bridgetool_place,
      on_use = bridgetool_switchmode
    })
  end --for w
end --for m


--temporary for backwards compatibility, remove this after a version or two
--since previously made tools will be named bridgetool_1 2 or 3, leaving this
--here ensures they will load and switch to bridgetool_11 etc on the first left click
for m = 1, 3 do
    minetest.register_tool("bridgetool:bridge_tool"..m, {
      description = "Bridge Tool mode "..m,
      inventory_image = "bridgetool_m"..m..".png",
      wield_image = "bridgetool_wield.png^[transformR90",
      groups = {not_in_creative_inventory=1},
      on_place = bridgetool_place,
      on_use = bridgetool_switchmode
    })
end --for m