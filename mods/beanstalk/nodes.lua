
--this registers the beanstalk node
--in future, we might want different nodes with different colors/patterns
--to be used on different levels?
--also, may want to make this NOT flamable and hard to chop?
minetest.register_node("beanstalk:beanstalk1", {
  description = "Beanstalk Stalk1",
  tiles = {"beanstalk1_top_32.png", "beanstalk1_top_32.png", "beanstalk1_side_32.png"},
  paramtype2 = "facedir",
  is_ground_content = false,
  --climbable = true,
  groups = {snappy=1,level=2,choppy=1,level=2},
  sounds = default.node_sound_wood_defaults(),
  on_place = minetest.rotate_node,
  --end,
})

--this registers the vine node.  later we might want to make this so
--that it only registers a new node if you are not using a mod that
--already has vines.
--copied from ethereal
minetest.register_node("beanstalk:vine1", {
  description = "BeanstalkVine1",
  drawtype = "signlike",
  tiles = {"vine1.png"},
  inventory_image = "vine1.png",
  wield_image = "vine1.png",
  paramtype = "light",
  paramtype2 = "wallmounted",
  walkable = false,
  climbable = true,
  is_ground_content = false,
  selection_box = {
    type = "wallmounted",
  },
  groups = {choppy = 3, oddly_breakable_by_hand = 1, flammable = 2},
  legacy_wallmounted = true,
  sounds = default.node_sound_leaves_defaults(),
})


minetest.register_node("beanstalk:beanstalk2", {
  description = "Beanstalk Stalk2",
  tiles = {"beanstalk2_top_32.png", "beanstalk2_top_32.png", "beanstalk2_side_32.png"},
  paramtype2 = "facedir",
  is_ground_content = false,
  --climbable = true,
  groups = {snappy=1,level=2,choppy=1,level=2},
  sounds = default.node_sound_wood_defaults(),
  on_place = minetest.rotate_node,
  --end,
})


minetest.register_node("beanstalk:vine2", {
  description = "BeanstalkVine2",
  drawtype = "signlike",
  tiles = {"vine2.png"},
  inventory_image = "vine2.png",
  wield_image = "vine2.png",
  paramtype = "light",
  paramtype2 = "wallmounted",
  walkable = false,
  climbable = true,
  is_ground_content = false,
  selection_box = {
    type = "wallmounted",
  },
  groups = {choppy = 3, oddly_breakable_by_hand = 1, flammable = 2},
  legacy_wallmounted = true,
  sounds = default.node_sound_leaves_defaults(),
})



minetest.register_node("beanstalk:beanstalk3", {
  description = "Beanstalk Stalk3",
  tiles = {"beanstalk3_top_32.png", "beanstalk3_top_32.png", "beanstalk3_side_32.png"},
  paramtype2 = "facedir",
  is_ground_content = false,
  --climbable = true,
  groups = {snappy=1,level=2,choppy=1,level=2},
  sounds = default.node_sound_wood_defaults(),
  on_place = minetest.rotate_node,
  --end,
})


minetest.register_node("beanstalk:vine3", {
  description = "BeanstalkVine3",
  drawtype = "signlike",
  tiles = {"vine3.png"},
  inventory_image = "vine3.png",
  wield_image = "vine3.png",
  paramtype = "light",
  paramtype2 = "wallmounted",
  walkable = false,
  climbable = true,
  is_ground_content = false,
  selection_box = {
    type = "wallmounted",
  },
  groups = {choppy = 3, oddly_breakable_by_hand = 1, flammable = 2},
  legacy_wallmounted = true,
  sounds = default.node_sound_leaves_defaults(),
})


minetest.register_node("beanstalk:beanstalk4", {
  description = "Beanstalk Stalk4",
  tiles = {"beanstalk4_top_32.png", "beanstalk4_top_32.png", "beanstalk4_side_32.png"},
  paramtype2 = "facedir",
  is_ground_content = false,
  --climbable = true,
  groups = {snappy=1,level=2,choppy=1,level=2},
  sounds = default.node_sound_wood_defaults(),
  on_place = minetest.rotate_node,
  --end,
})


minetest.register_node("beanstalk:vine4", {
  description = "BeanstalkVine4",
  drawtype = "signlike",
  tiles = {"vine4.png"},
  inventory_image = "vine4.png",
  wield_image = "vine4.png",
  paramtype = "light",
  paramtype2 = "wallmounted",
  walkable = false,
  climbable = true,
  is_ground_content = false,
  selection_box = {
    type = "wallmounted",
  },
  groups = {choppy = 3, oddly_breakable_by_hand = 1, flammable = 2},
  legacy_wallmounted = true,
  sounds = default.node_sound_leaves_defaults(),
})


minetest.register_node("beanstalk:beanstalk5", {
  description = "Beanstalk Stalk5",
  tiles = {"beanstalk5_top_32.png", "beanstalk5_top_32.png", "beanstalk5_side_32.png"},
  paramtype2 = "facedir",
  is_ground_content = false,
  --climbable = true,
  groups = {snappy=1,level=2,choppy=1,level=2},
  sounds = default.node_sound_wood_defaults(),
  on_place = minetest.rotate_node,
  --end,
})


minetest.register_node("beanstalk:vine5", {
  description = "BeanstalkVine5",
  drawtype = "signlike",
  tiles = {"vine5.png"},
  inventory_image = "vine5.png",
  wield_image = "vine5.png",
  paramtype = "light",
  paramtype2 = "wallmounted",
  walkable = false,
  climbable = true,
  is_ground_content = false,
  selection_box = {
    type = "wallmounted",
  },
  groups = {choppy = 3, oddly_breakable_by_hand = 1, flammable = 2},
  legacy_wallmounted = true,
  sounds = default.node_sound_leaves_defaults(),
})



--https://forum.minetest.net/viewtopic.php?f=9&t=2333&hilit=node+box
minetest.register_node("beanstalk:leaf", {
	description = "beanstalk:leaf",
  drawtype = "nodebox",
  tiles = {"beanstalk-leaf-top.png","beanstalk-leaf-top.png","beanstalk-leaf-top.png",
           "beanstalk-leaf-top.png","beanstalk-leaf-top.png","beanstalk-leaf-top.png"},
  paramtype = "light",
  paramtype2 = "facedir",
	inventory_image = "beanstalk-leaf-top.png",
	wield_image = "beanstalk-leaf-top.png",
  groups = {snappy=1,choppy=3,flammable=2},
  sounds = default.node_sound_wood_defaults(),
  walkable = true,
  climbable= false,
  is_ground_content = false,
    node_box = {
      type = "fixed",
      --fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, --makes half block
      --fixed = {-0.5, -0.5, -0.5, 0.5,-0.25, 0.5},--makes quarter block
      --fixed = {-0.5, -0.5, -0.5, 0.5,-0.25, 0.25}, --quarter height, 3/4 length
      --fixed = {-0.5, -0.5, -0.5, -0.25,-0.25, 0.5},  --this makes a 1/4 x 1/4 rectangle!
      --fixed = {-0.5, -0.5, -0.5, -0.25,-0.25, 0.5},
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- NodeBox1
    }
})


minetest.register_node("beanstalk:leaf_edge", {
	description = "beanstalk:leaf edge",
  drawtype = "nodebox",
  tiles = {"beanstalk-leaf-top.png","beanstalk-leaf-top.png","beanstalk-leaf-top.png",
           "beanstalk-leaf-top.png","beanstalk-leaf-top.png","beanstalk-leaf-top.png"},
  paramtype = "light",
  paramtype2 = "facedir",
	inventory_image = "beanstalk-leaf-edge.png",
	wield_image = "beanstalk-leaf-edge.png",
  groups = {snappy=1,choppy=3,flammable=2},
  sounds = default.node_sound_wood_defaults(),
  walkable = true,
  climbable= false,
  is_ground_content = false,
    node_box = {
      type = "fixed",
			fixed={
      {-0.5, -0.5, -0.5, -0.4375, -0.4375, 0.5}, -- NodeBox1
			{-0.4375, -0.5, -0.5, -0.375, -0.4375, 0.4375}, -- NodeBox2
			{-0.375, -0.5, -0.5, -0.3125, -0.4375, 0.375}, -- NodeBox3
			{-0.3125, -0.5, -0.5, -0.25, -0.4375, 0.3125}, -- NodeBox4
			{-0.25, -0.5, -0.5, -0.1875, -0.4375, 0.25}, -- NodeBox5
			{-0.1875, -0.5, -0.5, -0.125, -0.4375, 0.1875}, -- NodeBox6
			{-0.125, -0.5, -0.5, -0.0625, -0.4375, 0.125}, -- NodeBox7
			{-0.0625, -0.5, -0.5, 0, -0.4375, 0.0625}, -- NodeBox8
			{0, -0.5, -0.5, 0.0625, -0.4375, 0}, -- NodeBox9
			{0.0625, -0.5, -0.5, 0.125, -0.4375, -0.0625}, -- NodeBox10
			{0.125, -0.5, -0.5, 0.1875, -0.4375, -0.125}, -- NodeBox11
			{0.1875, -0.5, -0.5, 0.25, -0.4375, -0.1875}, -- NodeBox12
			{0.25, -0.5, -0.5, 0.3125, -0.4375, -0.25}, -- NodeBox13
			{0.3125, -0.5, -0.5, 0.375, -0.4375, -0.3125}, -- NodeBox14
			{0.375, -0.5, -0.5, 0.4375, -0.4375, -0.375}, -- NodeBox15
			{0.4375, -0.5, -0.5, 0.5, -0.4375, -0.4375}, -- NodeBox16
      }
    }
})





minetest.register_node("beanstalk:leaf_point_short", {
	description = "beanstalk:leaf point short",
  drawtype = "nodebox",
  tiles = {"beanstalk-leaf-top.png"},
  paramtype = "light",
  paramtype2 = "facedir",
	inventory_image = "beanstalk-leaf-point-short.png",
	wield_image = "beanstalk-leaf-point-short.png",
  groups = {snappy=1,choppy=3,flammable=2},
  sounds = default.node_sound_wood_defaults(),
  walkable = true,
  climbable= false,
  is_ground_content = false,
    node_box = {
      type = "fixed",
			fixed={
      {-0.5, -0.5, -0.5, -0.4375, -0.4375, -0.4375}, -- NodeBox1
			{-0.4375, -0.5, -0.5, -0.375, -0.4375, -0.375}, -- NodeBox2
			{-0.375, -0.5, -0.5, -0.3125, -0.4375, -0.3125}, -- NodeBox3
			{-0.3125, -0.5, -0.5, -0.25, -0.4375, -0.25}, -- NodeBox4
			{-0.25, -0.5, -0.5, -0.1875, -0.4375, -0.1875}, -- NodeBox5
			{-0.1875, -0.5, -0.5, -0.125, -0.4375, -0.125}, -- NodeBox6
			{-0.125, -0.5, -0.5, -0.0625, -0.4375, -0.0625}, -- NodeBox7
			{-0.0625, -0.5, -0.5, 0, -0.4375, 0}, -- NodeBox8
			{0, -0.5, -0.5, 0.0625, -0.4375, 0}, -- NodeBox9
			{0.0625, -0.5, -0.5, 0.125, -0.4375, -0.0625}, -- NodeBox10
			{0.125, -0.5, -0.5, 0.1875, -0.4375, -0.125}, -- NodeBox11
			{0.1875, -0.5, -0.5, 0.25, -0.4375, -0.1875}, -- NodeBox12
			{0.25, -0.5, -0.5, 0.3125, -0.4375, -0.25}, -- NodeBox13
			{0.3125, -0.5, -0.5, 0.375, -0.4375, -0.3125}, -- NodeBox14
			{0.375, -0.5, -0.5, 0.4375, -0.4375, -0.375}, -- NodeBox15
			{0.4375, -0.5, -0.5, 0.5, -0.4375, -0.4375}, -- NodeBox16
      }
    }
})


minetest.register_node("beanstalk:leaf_stem_join", {
	description = "beanstalk:leaf stem join",
  drawtype = "nodebox",
  tiles = {"beanstalk-leaf-top.png"},
  paramtype = "light",
  paramtype2 = "facedir",
	inventory_image = "beanstalk-leaf-stem-join.png",
	wield_image = "beanstalk-leaf-stem-join.png",
  groups = {snappy=1,choppy=3,flammable=2},
  sounds = default.node_sound_wood_defaults(),
  walkable = true,
  climbable= false,
  is_ground_content = false,
    node_box = {
      type = "fixed",
			fixed={
			{-0.5, -0.5, -0.5, -0.375, -0.4375, -0.4375}, -- NodeBox1
			{-0.5, -0.5, -0.4375, -0.3125, -0.4375, -0.375}, -- NodeBox2
			{-0.5, -0.5, -0.375, -0.1875, -0.4375, -0.3125}, -- NodeBox3
			{-0.0625, -0.5, -0.5, 0.0625, -0.4375, -0.25}, -- NodeBox4
			{0.375, -0.5, -0.5, 0.5, -0.4375, -0.4375}, -- NodeBox5
			{0.3125, -0.5, -0.4375, 0.5, -0.4375, -0.375}, -- NodeBox6
			{0.1875, -0.5, -0.375, 0.5, -0.4375, -0.3125}, -- NodeBox7
			{0.125, -0.5, -0.3125, 0.5, -0.4375, -0.25}, -- NodeBox8
			{-0.5, -0.5, -0.3125, -0.125, -0.4375, -0.25}, -- NodeBox9
			{-0.5, -0.5, -0.25, 0.5, -0.4375, 0.5}, -- NodeBox10
      }
    }
})

minetest.register_node("beanstalk:leaf_stem", {
	description = "beanstalk:leaf stem",
  drawtype = "nodebox",
  tiles = {"beanstalk-leaf-top.png"},
  paramtype = "light",
  paramtype2 = "facedir",
	inventory_image = "beanstalk-leaf-stem.png",
	wield_image = "beanstalk-leaf-stem.png",
  groups = {snappy=1,choppy=3,flammable=2},
  sounds = default.node_sound_wood_defaults(),
  walkable = true,
  climbable= false,
  is_ground_content = false,
    node_box = {
      type = "fixed",
      fixed={-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.5}, -- NodeBox1
    }
})


minetest.register_node("beanstalk:magic_bean", {
  description = "Magic Bean",
  tiles = {"magic_bean.png"},
  paramtype2 = "facedir",
  wield_image ="magic_bean.png",
  inventory_image="magic_bean.png",
  is_ground_content = false,
  --climbable = true,
  groups = {snappy=1,level=2,choppy=1,level=2},
  sounds = default.node_sound_wood_defaults(),
  --on_place = beanstalk.place_magic_bean,
  on_place = function(itemstack, placer, pointed_thing)
    return beanstalk.place_magic_bean(itemstack, placer, pointed_thing)
  end --on_place
})


