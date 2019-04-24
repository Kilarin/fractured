
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
				realm[r].parms={}
				realm[r].parms.realm_minp={}
				realm[r].parms.realm_minp.x, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_minp.y, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_minp.z, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_maxp={}
				realm[r].parms.realm_maxp.x, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_maxp.y, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_maxp.z, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.surfacey, p=luautils.next_field(str,"|",p,"trim","num")
				local misc
				local var
				local val
				--now we are going to loop through any OTHER flags/variables user set
				while p~=nil do
					misc, p=luautils.next_field(str,"|",p,"trim","str")
					local peq=string.find(misc,"=")
					if peq~=nil then --found var=value
						var=luautils.trim(string.sub(misc,1,peq-1)) --var is everything to the left of the =
						val=luautils.trim(string.sub(misc,peq+1)) --val is everything to the right of the =
						if tonumber(val)~=nil then val=tonumber(val) end  --if the string is numeric, turn it into a number
						realm[r].parms[var]=val
					else realm[r].parms[misc]=true --if no equals found, then treat it as a flag and set true
					end --if peq~=nil
				end --while p~=nil
				minetest.log("realms->   r="..r.." minp="..luautils.pos_to_str(realm[r].parms.realm_minp)..
						" maxp="..luautils.pos_to_str(realm[r].parms.realm_maxp).." surfacey="..realm[r].parms.surfacey)
			end --if p~=nil
		end --for str
		minetest.log("realms-> all realms loaded, count="..realm.count)
	end --if file
end --read_realm_config()



--********************************
function gen_realms(chunk_minp, chunk_maxp, seed)
	--eventually, this should run off of an array loaded from a file
	--every rmg (realm terrain generator) should register with a string for a name, and a function
	--the realm params will be loaded from a table
	local r=0
	local doit=false
	repeat
		r=r+1
		if luautils.check_overlap(realm[r].parms.realm_minp, realm[r].parms.realm_maxp, chunk_minp,chunk_maxp)==true then doit=true end
	until r==realm.count or doit==true
	if doit==false then return end --dont waste cpu

	--This actually initializes the LVM.  Since realms allows multiple overlapping
	--map gens to run, we can save cpu by getting the vm once at the begining,
	--passing it to each rmg (realms map gen) as it runs, and saving after
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	--share is used to pass data between rmgs working on the same chunk
	local share={}
	--r already equals one that matches, so start there
	--could just do the match here automatically and skip the overlap check, then start at r+1?
	local rstart=r
	for r=rstart,realm.count,1 do
		parms=realm[r].parms
		if luautils.check_overlap(parms.realm_minp, parms.realm_maxp, chunk_minp,chunk_maxp)==true then
			minetest.log("realms-> gen_realms r="..r.." rmg="..luautils.var_or_nil(realm[r].rmg)..
					" realm minp="..luautils.pos_to_str(parms.realm_minp).." maxp="..luautils.pos_to_str(parms.realm_maxp))
			minetest.log("     surfacey="..parms.surfacey.." chunk minp="..luautils.pos_to_str(chunk_minp).." maxp="..luautils.pos_to_str(chunk_maxp))
			
			--rmg[realm[r].rmg](realm[r].parms.realm_minp,realm[r].parms.realm_maxp, realm[r].parms.surfacey, chunk_minp,chunk_maxp, 0)
			parms.chunk_minp=chunk_minp
			parms.chunk_maxp=chunk_maxp
			parms.isect_minp, parms.isect_maxp = luautils.box_intersection(parms.realm_minp,parms.realm_maxp, parms.chunk_minp,parms.chunk_maxp)
			parms.share=share
			parms.area=area
			parms.data=data 
			parms.vm=vm  --I dont know if the map gen needs this, but just in case, there it is.
			rmg[realm[r].rmg](parms)
			share=parms.share --save share to be used in next parms (user might have changed pointer)
		end --if overlap
	end--for
	
	--Wrap things up and write back to map, send data back to voxelmanip
	--(by saving here we avoid multiple save and pulls in overlapping realm map gens)
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)
	
end -- gen_realms

dofile(minetest.get_modpath("realms").."/realms_map_generators/layer_barrier.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/flatland.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/very_simple.lua")

minetest.register_on_generated(gen_realms)
read_realms_config()




