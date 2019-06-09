--[[
This is "in progress"  I hope to add decorations to the bottom of chasms, including skeletons.  
But I need to figure out how to rotate this skull and skelton so they default to laying
down instead of standing up
--]]



-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  S = intllib.Getter()
else
  S = function ( s ) return s end
end



--this code from "bones" 
--Authors of source code:
-------------------------
--Original Author(s):
--	PlizAdam (LGPL v2.1)
--		https://github.com/minetest/minetest_game
--LOTT Modifications By:
--	fishyWET (LGPL v2.1)
--	Amaz (LGPL v2.1)
--
--Authors of media files
-------------------------
--Bad_Command_ (CC BY-SA 3.0)
--
--fishyWET (CC BY-SA 3.0)
--	bones_bone.png
--	bones_skeleton.png
--	bones_skeleton_bottom.png
--	bones_skeleton_front.png
--	bones_skeleton_rear.png
--	bones_skeleton_side.png
--	bones_skeleton_top.png

	
minetest.register_node("realms:skeleton_head", {
	description = "Skeleton Head",
	drawtype = "nodebox",
	tiles = {
		--"bones_skeleton_top.png",
		--"bones_skeleton_bottom.png",
		--"bones_skeleton_side.png",
		--"bones_skeleton_side.png",
		--"bones_skeleton_rear.png",
		--"bones_skeleton_front.png"
		"bones_skeleton_front.png",
		"bones_skeleton_rear.png",
		"bones_skeleton_side.png",
		"bones_skeleton_side.png",
		"bones_skeleton_top.png",
		"bones_skeleton_bottom.png",
	},
	paramtype2 = "facedir",
--	paramtype2 = "wallmounted",
--	param2=3,
	paramtype = "light",
	groups = {dig_immediate=2},
	node_box = {
		type = "fixed",
		fixed = {
			--{-0.3125,0.3125,-0.3125,0.3125,0.5,0.3125},
			--{ -0.5,0.25,-0.5,0.5,0.415385,0.5},
			--{-0.5,-0.1875,-0.5,0.5,0.375,0.5},
			--{-0.375,-0.5,-0.3125,0.375,0.125,0.3125},
			{-0.3125,-0.3125,0.3125, 0.3125,0.3125,0.5},
			{ -0.5,-0.5,0.25,0.5,0.5,0.415385},
			{-0.5,-0.5,-0.1875,0.5,0.5,0.375},
			{-0.375,-0.3125,-0.5,0.375,0.3125,0.125},
		},
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.5},
		dug = {name="default_gravel_footstep", gain=1.0},
	}),
})




minetest.register_node("realms:skeleton_body", {
	description = "Skeleton Body",
	drawtype = "nodebox",
	tiles = {"bones_skeleton_top.png"},
	inventory_image = "bones_skeleton_body.png",
	wield_image = "bones_skeleton_body.png",
	paramtype2 = "facedir",
	paramtype = "light",
	groups = {dig_immediate=2},
	node_box = {
		type = "fixed",
		fixed = {
			--{-0.0625,-0.0625,-0.0625,0.125,0.5,0.0625},
			--{-0.25,-0.3125,-0.25,0.3125,-0.0625,0.25},
			--{-0.25,-0.5,-0.0625,-0.125,-0.0625,0.125},
			--{0.3125,-0.5,-0.0625,0.1875,-0.0625,0.125},
			--{-0.3125,0,-0.375,0.375,0.125,0.375},
			--{-0.3125,0.375,-0.375,0.375,0.5,0.375},
			--{-0.3125,0.1875,-0.375,0.375,0.3125,0.375},
			--{0.375,-0.0625,-0.0625,0.5,0.5,0.1875},
			--{-0.3125,-0.0625,-0.0625,-0.4375,0.5,0.1875},
			{-0.0625,-0.0625,-0.0625,  0.125, 0.0625, 0.5   },
			{-0.25,  -0.25,  -0.3125,  0.3125,0.25,  -0.0625},
			{-0.25,  -0.0625,-0.5,    -0.125, 0.125, -0.0625},
			{0.3125, -0.0625,-0.5,     0.1875,0.125, -0.0625},
			{-0.3125,-0.375,  0,       0.375, 0.375,  0.125 },
			{-0.3125,-0.375,  0.375,   0.375, 0.375,  0.5   },
			{-0.3125,-0.375,  0.1875,  0.375, 0.375,  0.3125},
			{0.375,  -0.0625,-0.0625,  0.5,   0.1875, 0.5   },
			{-0.3125,-0.0625,-0.0625, -0.4375,0.1875, 0.5   }, 
		},
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.5},
		dug = {name="default_gravel_footstep", gain=1.0},
	}),
})


