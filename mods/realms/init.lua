
realms={ }
realm={}

local rmg={}

--register realmst terrain generator
--********************************

function realms.register_rmg(name, func)
	rmg[name]=func	
	minetest.log("realms-> rmg registered for: "..name)
end --register_rmg


function read_realms_config()
	minetest.log("realms-> reading realms config file")
	realm.count=0
	local p
	--first we look to see if there is a realms.conf file in the world path
	local file = io.open(minetest.get_worldpath().."/realms.conf", "r")
	--if its not in the worldpath, try for the modpath
	if file then
		minetest.log("realms-> loading realms.config from worldpath:")
	else  
		file = io.open(minetest.get_modpath("realms").."/realms.conf", "r")    
		if file then minetest.log("realms-> loading realms.conf from modpath") 
		else minetest.log("realms-> unable to find realms file in worldpath or modpath.  This is bad")
		end --if file (modpath)
	end --if file (worldpath)   
	if file then  
		for str in file:lines() do
			p=string.find(str,"|")
			if p~=nil then --we found a vertical bar, this is an actual entry
				realm.count=realm.count+1
				local r=realm.count
				realm[r]={}
				minetest.log("realms-> count="..realm.count.." str="..str)
				--realm[r].rmg,p=tst,p=luautils.next_field(str,"|",1)  --for some strange reason THIS wont work
				local hld,p=luautils.next_field(str,"|",1,"trim")  --but this works fine
				realm[r].rmg=hld
				realm[r].minp={}
				realm[r].minp.x, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].minp.y, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].minp.z, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].maxp={}
				realm[r].maxp.x, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].maxp.y, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].maxp.z, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].surfacey, p=luautils.next_field(str,"|",p,"trim","num")
				minetest.log("realms->   r="..r.." minp="..luautils.pos_to_str(realm[r].minp).." maxp="..luautils.pos_to_str(realm[r].maxp).." surfacey="..realm[r].surfacey)
			end --if p~=nil
		end --for str
		minetest.log("realms-> all realms loaded, count="..realm.count)
	end --if file
end --read_realm_config()



--********************************
function gen_realms(minp, maxp, seed)
	--eventually, this should run off of an array loaded from a file
	--every rmg (realm terrain generator) should register with a string for a name, and a function
	--the realm params will be loaded from a table
	local r=0
	local doit=false
	repeat
		r=r+1
		if luautils.check_overlap(realm[r].minp, realm[r].maxp, minp,maxp)==true then doit=true end
	until r==realm.count or doit==true
	if doit==false then return end --dont waste cpu

	--r already equals one that matches, so start there
	--could just do the match here automatically and skip the overlap check, then start at r+1?
	local parms={}
	local rstart=r	
	for r=rstart,realm.count,1 do
		if luautils.check_overlap(realm[r].minp, realm[r].maxp, minp,maxp)==true then
			minetest.log("realms-> gen_realms r="..r.." rmg="..luautils.var_or_nil(realm[r].rmg).." realm minp="..luautils.pos_to_str(realm[r].minp).." maxp="..luautils.pos_to_str(realm[r].maxp))
			minetest.log("     surfacey="..realm[r].surfacey.." minp="..luautils.pos_to_str(minp).." maxp="..luautils.pos_to_str(maxp))
			rmg[realm[r].rmg](realm[r].minp,realm[r].maxp, realm[r].surfacey, minp,maxp, 0)
		end --if overlap
	end--for
	--local gen=gen_layer_barrier(realm_minp,realm_maxp,0,minp,maxp,seed)
end -- gen_realms

dofile(minetest.get_modpath("realms").."/realms_map_generators/layer_barrier.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/flatland.lua")

minetest.register_on_generated(gen_realms)
read_realms_config()




