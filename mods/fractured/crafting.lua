
minetest.register_craft({
	output = 'fractured:esem',
	recipe = {
		{'fractured:esem_crystal', 'fractured:esem_crystal', 'fractured:esem_crystal'},
		{'fractured:esem_crystal', 'fractured:esem_crystal', 'fractured:esem_crystal'},
		{'fractured:esem_crystal', 'fractured:esem_crystal', 'fractured:esem_crystal'},
	}
})

minetest.register_craft({
	output = 'fractured:esem_crystal 9',
	recipe = {
		{'fractured:esem'},
	}
})

minetest.register_craft({
	output = 'fractured:esem_crystal_fragment 9',
	recipe = {
		{'fractured:esem_crystal'},
	}
})


