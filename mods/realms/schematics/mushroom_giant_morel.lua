--By Kilarin, copyright CC0, no rights reserved
--and no, its not really very much like a morel mushroom, but it will do

local _ = {name = "air", prob = 0}
local M = {name = "default:coral_brown", prob = 255}
local T = {name = "realms:mushroom_trunk", prob = 255}


bd_odd_biomes.mushroom_giant_morel = {

	size = {x = 4, y = 8, z = 4},

	yslice_prob = {
		{ypos = 1, prob =  200}
	},

	data = {


	_,_,_,_,
	_,_,_,_,
	_,_,_,_,
	_,M,M,_,
	_,M,M,_,
	_,M,M,_,
	_,M,M,_,
	_,_,_,_,

	_,T,T,_,
	_,T,T,_,
	_,T,T,_,
	M,T,T,M,
	M,T,T,M,
	M,T,T,M,
	M,T,T,M,
	_,M,M,_,

	_,T,T,_,
	_,T,T,_,
	_,T,T,_,
	M,T,T,M,
	M,T,T,M,
	M,T,T,M,
	M,T,T,M,
	_,M,M,_,

	_,_,_,_,
	_,_,_,_,
	_,_,_,_,
	_,M,M,_,
	_,M,M,_,
	_,M,M,_,
	_,M,M,_,
	_,_,_,_,


	}
}




--[[ old version with a more bell like shape
local P = {name = "realms:mushroom_pore", prob = 255}

bd_odd_biomes.mushroom_giant_morel = {

	size = {x = 6, y = 8, z = 6},

	yslice_prob = {
		{ypos = 1, prob =  200}
	},

	data = {


	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,M,M,M,M,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,

	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	M,M,P,P,M,M,
	_,_,M,M,_,_,
	_,_,M,M,_,_,
	_,_,M,M,_,_,
	_,_,_,_,_,_,

	_,_,T,T,_,_,
	_,_,T,T,_,_,
	_,_,T,T,_,_,
	M,P,T,T,P,M,
	_,M,T,T,M,_,
	_,M,T,T,M,_,
	_,M,T,T,M,_,
	_,_,M,M,_,_,

	_,_,T,T,_,_,
	_,_,T,T,_,_,
	_,_,T,T,_,_,
	M,P,T,T,P,M,
	_,M,T,T,M,_,
	_,M,T,T,M,_,
	_,M,T,T,M,_,
	_,_,M,M,_,_,

	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	M,M,P,P,M,M,
	_,_,M,M,_,_,
	_,_,M,M,_,_,
	_,_,M,M,_,_,
	_,_,_,_,_,_,

	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,M,M,M,M,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,
	_,_,_,_,_,_,


	}
}
--]]
