--Explorer Tools All version 1.1

--The original Explorer Tools code was written by Kilarin (Donald Hines) and
--his son Jesse Hines. 4aiman then created a version that instead of creating
--special explorer tools with their own recipie, gave this "place on rightclick"
--ability to every pick, axe, and shovel in the game.  This version is a slight
--modification of his version.
--License:GPLv3 http://gplv3.fsf.org/

---
---Function
---

--This function is for use when an explorertool is right clicked
--it finds the inventory item immediatly to the right of the explorertool
--and then places THAT item (if possible)
--
function explorertools_place(item, player, pointed)
  --find index of item to right of wielded tool
  --(could have gotten this directly from item I suppose, but this works fine)
  local idx = player:get_wield_index() + 1
  local inv = player:get_inventory()
  local stack = inv:get_stack("main", idx) --stack=stack to right of tool
  if pointed ~= nil then
    --attempt to place stack where tool was pointed
    stack = minetest.item_place(stack, player, pointed)
    inv:set_stack("main", idx, stack)
  end --pointed ~= nil
end --function explorertools_place


--loop through all defined tools, and if it is a pick, axe, shovel, or spade,
--change it's on_place function to be explorertools_place
for cou,def in pairs(minetest.registered_tools) do
  if def.name:find('pick')
    or def.name:find('axe')
    or def.name:find('shovel')
    or def.name:find('spade')
  then
    minetest.override_item(def.name, {on_place = explorertools_place,})
  end
end
