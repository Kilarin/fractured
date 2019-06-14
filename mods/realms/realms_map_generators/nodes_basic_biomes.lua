--[[
This defines the nodes used by bd_basic_biomes.lua
--]]


-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  S = intllib.Getter()
else
  S = function ( s ) return s end
end

-- borrowed from ethereal
minetest.register_node("realms:snowygrass", {
	description = S("Snowy Grass"),
	drawtype = "plantlike",
	visual_scale = 0.9,
	tiles = {"ethereal_snowygrass.png"},
	inventory_image = "ethereal_snowygrass.png",
	wield_image = "ethereal_snowygrass.png",
	paramtype = "light",
	sunlight_propagates = true,
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-5 / 16, -0.5, -5 / 16, 5 / 16, 5 / 16, 5 / 16},
	},
})


-- created using Node Box Editor, version 0.9.0
minetest.register_node("realms:cow_skull", {
	tiles = {
		"bones_cow_skull_top.png",
		"bones_skeleton_side.png",
		"bones_cow_skull_side.png^[transformFX",
		"bones_cow_skull_side.png",
		"bones_skeleton_side.png",
		"bones_cow_skull_top.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	--paramtype2 = "wallmounted",
	paramtype2="facedir",
	param2=3,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, 0.4375, 0.125, -0.3125, 0.5}, -- NodeBox1
			{-0.3125, -0.4375, 0.3125, 0.3125, -0.25, 0.4375}, -- NodeBox2
			{-0.1875, -0.5, 0.1875, 0.1875, -0.1875, 0.375}, -- NodeBox3
			{-0.125, -0.4375, 0, 0.125, -0.1875, 0.1875}, -- NodeBox4
			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0}, -- NodeBox5
			{-0.125, -0.5, -0.3125, 0.125, -0.25, -0.1875}, -- NodeBox6
			{-0.125, -0.5, -0.5, 0.125, -0.4375, -0.3125}, -- NodeBox9
			{-0.1875, -0.5, 0, 0.1875, -0.4375, 0.1875}, -- NodeBox11
			{-0.125, -0.5, -0.5, -0.0625, -0.3125, -0.3125}, -- NodeBox12
			{0.0625, -0.5, -0.5, 0.125, -0.3125, -0.3125}, -- NodeBox13
			{-0.4375, -0.375, 0.25, -0.3125, -0.125, 0.375}, -- NodeBox14
			{-0.5, -0.1875, 0.1875, -0.375, -0.0625, 0.3125}, -- NodeBox15
			{-0.5, -0.125, 0, -0.4375, -0.0625, 0.1875}, -- NodeBox16
			{0.3125, -0.375, 0.25, 0.4375, -0.125, 0.375}, -- NodeBox17
			{0.375, -0.1875, 0.1875, 0.5, -0.0625, 0.3125}, -- NodeBox18
			{0.4375, -0.125, 0, 0.5, -0.0625, 0.1875}, -- NodeBox19
			{-0.125, -0.1875, 0.1875, 0.125, -0.125, 0.375}, -- NodeBox19
			{-0.1875, -0.5, 0.375, 0.1875, -0.4375, 0.4375}, -- NodeBox21
		}
	}
})


