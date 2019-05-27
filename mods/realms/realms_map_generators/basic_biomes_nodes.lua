-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  S = intllib.Getter()
else
  S = function ( s ) return s end
end

-- Grey Shrub (not Flammable - too cold to burn)
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

