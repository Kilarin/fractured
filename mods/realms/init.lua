
--Realms is Minetest mod that allows you to use multiple diferent lua landscape generators
--and control exactly where each one runs on the map through the realms.conf file

realms={}

local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_dirt_grass = minetest.get_content_id("default:dirt_with_grass")
local c_sand = minetest.get_content_id("default:sand")

realms.undefined_biome={
	name="undefined_biome",
	node_top=c_dirt_grass,
	depth_top = 1,
	node_filler=c_dirt,
	depth_filler = 5,
	dec=nil
	}

realms.undefined_underwater_biome={
	name="undefined_underwater_biome",
	node_top=c_sand,
	depth_top = 1,
	node_filler=c_sand,
	depth_filler = 1,
	dec=nil
	}


local data = {}   --define buffers up here to save memory
local vmparam2 = {}

local pts=luautils.pos_to_str
local von=luautils.var_or_nil
local placenode=luautils.place_node

realm={}

--note that these are global
realms.rmg={}  --realms map gen
realms.rmf={}  --realms map function
realms.noise={} --noise (so you can reuse the same noise or change it easily)
realms.biome={} --where registered biomes are stored.  Remember, registered biomes do nothing unless included in a biome map
realms.biomemap={}



--realms map generator
--********************************
function realms.register_mapgen(name, func)
	realms.rmg[name]=func
	minetest.log("realms-> rmg registered for: "..name)
end --register_mapgen



--realms map function
--********************************
function realms.register_mapfunc(name, func)
	realms.rmf[name]=func
	minetest.log("realms-> rmf registered for: "..name)
end --register_mapfunc


--realms noise
--********************************
function realms.register_noise(name, noise)
	--store the special seed for this noise based on the noise name
	--if the user passes a seed, we will add it to this nameseed
	--that way ONE seed can be passed and used for multiple noises without giving them all the same seed
	local nameseed=0
	for i=1,string.len(name) do
		nameseed=nameseed+i*string.byte(name,i)
	end --for
	noise.nameseed=nameseed
	realms.noise[name]=noise
	minetest.log("realms-> noise registered for: "..name)
end --register_noise


--call this function passing a noise parameter (usually parms.noisename)
--call this function passing a noisename_in (the name of a registered noise, usually parms.noisename)
--and a default noise name.  The function will return the default noise if noisename_in is blank.
--if you pass seed, the noise.seed will be set to that
--if seed is nil and default_seed is not, it will use default_seed (usualy pass parms.realm_seed)
--if default_seed is nill, it will not change the seed.
--NOTE: we add the seed you pass to nameseed, a unique seed based on the noise name.  that way you get
--unique seeds for each noise even when passing the same realm_seed
--
--this just makes it simpler and more intuitive to get your noise
--it is usually better to use realms.get_noise2d or realms.get_noise3d
--********************************
function realms.get_noise(noisename_in, default_noise, seed, default_seed)
	local noisename
	if noisename_in~=nil and noisename_in~="" then noisename=noisename_in
	else noisename=default_noise
	end --if noisename_in
	local noise=realms.noise[noisename]
	if seed~=nil then
		noise.seed=noise.nameseed+tonumber(seed)
	elseif default_seed~=nil then
		noise.seed=noise.nameseed+tonumber(default_seed)
	end --if seed
	return noise
end --get_noise


--note that this just saves the step of you getting the perlin map and lets you do it all in one step
--see get_noise for details on that function
--noisename_in=the name of a registered noise, usually parms.noisename
--default_noise=the name of a registered noise to use if noisename_in is nil
--seed=a seed to add to nameseed for this noise (usually parms.seed)
--default_seed=a seed to use if seed=nil (usually parms.realm_seed)
--size2d=the size of the map, (usually parms.isectsize2d)
--minposxz=the min position, (usually parms.minposxz)
--this function will return the noise map
--********************************
function realms.get_noise2d(noisename_in, default_noise, seed, default_seed, size2d, minposxz)
	local noise=realms.get_noise(noisename_in, default_noise, seed, default_seed)
	local noisemap = minetest.get_perlin_map(noise, size2d):get_2d_map_flat(minposxz)
	return noisemap
end --get_noise2d


--same as get_noise2d but for 3d noise
--********************************
function realms.get_noise3d(noisename_in, default_noise, seed, default_seed, size3d, minpos)
	local noise=realms.get_noise(noisename_in, default_noise, seed, default_seed)
	local noisemap = minetest.get_perlin_map(noise, size3d):get_3d_map_flat(minposxz)
	return noisemap
end --get_noise2d


--********************************
function realms.read_realms_config()
	minetest.log("realms-> reading realms config file")
	realm.count=0
	local p
	local cmnt
	--realms_configpathmod is set in minetest.conf in the games path, OR defaults to just realms
	--this is the NAME of the mod where we will get the config file.  I would rather use the game path,
	--but there is no way to get that in minetest.
	local configpathmod=minetest.settings:get("realms_configpathmod") or "realms"
	minetest.log("realms.read_realms_config -> configpathmod="..configpathmod)
	--using the mod name from configpathmod, we now get the path
	local configpath=minetest.get_modpath(configpathmod)
	minetest.log("realms.read_realms_config -> configpath="..configpath)
	--realms_config is set in minetest.conf in the game path, OR defaults to just realms.conf
	local filename = minetest.settings:get("realms_config") or "realms.conf"
	minetest.log("realms.read_realms_config -> filename="..filename)
	--open the file so we can load the config
	local file = io.open(configpath.."/"..filename, "r")
	if file then minetest.log("realms.read_realms_config -> loading realms config file: <"..filename.."> from "..configpath)
	else minetest.log("realms.read_realms_config -> ERROR!!! unable to find realms config file <"..filename.."> in "..configpath..".  This is bad")
	end --if file (modpath)
	
	if file then
		for str in file:lines() do
			str=luautils.trim(str)
			cmnt=false
			if string.len(str)>=2 and string.sub(str,1,2)=="--" then cmnt=true end
			p=string.find(str,"|")
			if p~=nil and cmnt~=true then --not a comment, and we found a vertical bar, this is an actual entry
				realm.count=realm.count+1
				local r=realm.count
				realm[r]={}
				minetest.log("realms-> count="..realm.count.." str="..str)
				--realm[r].rmg,p=tst,p=luautils.next_field(str,"|",1)  --for some strange reason THIS wont work
				local hld,p=luautils.next_field(str,"|",1,"trim")  --but this works fine
				realm[r].rmg=hld
				realm[r].parms={}
				local mapseed = minetest.get_mapgen_setting("seed") --this is how we get the mapgen seed
				--lua numbers are double-precision floating-point which can only handle numbers up to 100,000,000,000,000
				--but the seed we got back is 20 characters!  We dont really need that much randomness anyway, so we are
				--going to just take the first 13 chars, and turn it into a number, so we can do multiplication and addition to it
				mapseed=tonumber(string.sub(mapseed,1,13))
				--multiplying by the realm number should give us a unique seed for each realm that can be used in noise etc
				--since we cut 13 chars from the mapseed, even realm[1] seed would should be different from the map seed
				realm[r].parms.realm_seed=mapseed*r
				realm[r].parms.realm_minp={}
				realm[r].parms.realm_minp.x, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_minp.y, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_minp.z, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_maxp={}
				realm[r].parms.realm_maxp.x, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_maxp.y, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.realm_maxp.z, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.sealevel, p=luautils.next_field(str,"|",p,"trim","num")
				realm[r].parms.biomefunc, p=luautils.next_field(str,"|",p,"trim","str")
				if realm[r].parms.biomefunc=="" then realm[r].parms.biomefunc=nil end
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
				minetest.log("realms->   r="..r.." minp="..pts(realm[r].parms.realm_minp)..
						" maxp="..pts(realm[r].parms.realm_maxp).." sealevel="..realm[r].parms.sealevel)
			end --if p~=nil
		end --for str
		minetest.log("realms-> all realms loaded, count="..realm.count)
	end --if file
end --read_realm_config()



--********************************
function realms.decorate(x,y,z, biome, parms)
	local dec=biome.dec
	--minetest.log("  realms.decorate-> "..luautils.pos_to_str_xyz(x,y,z).." biome="..biome.name)
	if dec==nil then return end --no decorations!
	local area=parms.area
	local data=parms.data
	local vmparam2=parms.vmparam2
	local d=1
	local r=math.random()*100
	--minetest.log("    r="..r)
	--we will loop until we hit the end of the list, or an entry whose chancebot is <= r
	--so when we exit we will be in one of these conditions
	--dec[d]==nil (this biome had no decorations)
	--r>=dec[d].chancetop (chance was too high, no decoration selected)
	--r<dec[d].chancetop (d is the decoration that was selected)
	while (dec[d]~=nil) and (r<dec[d].chancebot) do
		--minetest.log("      d="..d.." chancetop="..luautils.var_or_nil(dec[d].chancetop).." chancebot="..luautils.var_or_nil(dec[d].chancebot))
		d=d+1
		end
	--minetest.log("      d="..d.." chancetop="..luautils.var_or_nil(dec[d].chancetop).." chancebot="..luautils.var_or_nil(dec[d].chancebot))
	if (dec[d]~=nil) and (r<dec[d].chancetop) then
		--decorate
		--minetest.log("      hit d="..d.." chancetop="..luautils.var_or_nil(dec[d].chancetop).." chancebot="..luautils.var_or_nil(dec[d].chancebot))

		--deal with offest here, because we use it for all three decoration types
		local px=x
		local py=y
		local pz=z
		if dec[d].offset_x ~= nil then px=px+dec[d].offset_x end
		if dec[d].offset_y ~= nil then py=py+dec[d].offset_y end
		if dec[d].offset_z ~= nil then pz=pz+dec[d].offset_z end
		--this is only used in type=node for right now
		local rotate=nil
		if dec[d].rotate~=nil then
			if type(dec[d].rotate)=="table" then rotate=dec[d].rotate[math.random(1,#dec[d].rotate)]
			elseif dec[d].rotate=="random" then rotate=math.random(0,3)
			elseif dec[d].rotate=="random3d" then rotate=math.random(0,11)
			else rotate=dec[d].rotate
			end --if dec[d].rotate==random
		end --if dec[d].rotate~=nil
		if dec[d].node~=nil then
			--minetest.log("decorate:placing node="..dec[d].node.." biomename="..biome.name.." d="..d)
			--note that rotate will be nil unless they sent a rotate value, and if it is nil, it will be ignored
			placenode(px,py,pz,area,data,dec[d].node, vmparam2,rotate)
			if dec[d].height~=nil then
				local height_max=dec[d].height_max
				if height_max==nil then height_max=dec[d].height end
				local r=math.random(dec[d].height,height_max)
				--minetest.log("heighttest-> height="..dec[d].height.." height_max="..height_max.." r="..r)
				for i=2,r do --start at 2 because we already placed 1
					--minetest.log(" i="..i.." y-i+1="..(y-i)+1)
					placenode(px,py+i-1,pz,area,data,dec[d].node, vmparam2,rotate)
				end --for
			end --if dec[d].node.height
		elseif dec[d].func~=nil then
			dec[d].func(px, py, pz, area, data)
		elseif dec[d].schematic~=nil then
			--minetest.log("  realms.decorate-> schematic "..luautils.pos_to_str_xyz(x,y,z).." biome="..biome.name)
			--placenode(x,y+1,z,area,data,c_mese)
			--minetest.place_schematic({x=x,y=y,z=z}, dec[d].schema, "random", nil, true)
			--minetest.place_schematic_on_vmanip(parms.vm,{x=x,y=y,z=z}, dec[d].schema, "random", nil, true)
			--can't add schematics to the area properly, so they get added to the parms.mts table, then placed at the end just before the vm is saved
			--I'm using offset instead of center so I dont have to worry about whether the schematic is a table or mts file
			--I dont know how to send flags for mts file schematics, flags dont seem to be working well for me anyway
			table.insert(parms.mts,{{x=px,y=py,z=pz},dec[d].schematic})
		elseif dec[d].lsystem~=nil then
			--minetest.spawn_tree({x=px,y=py,z=pz},dec[d].lsystem)
			--cant add it here, so treating the same as schematic
			table.insert(parms.lsys,{{x=px,y=py,z=pz},dec[d].lsys})
		end --if dec[d].node~=nil
	end --if (dec[d]~=nil)

	--minetest.log("  realms.decorate-> "..luautils.pos_to_str_xyz(x,y,z).." biome="..biome.name.." r="..r.." d="..d)
end --decorate




--just allows for error checking and for passing a content id
--********************************
function realms.get_content_id(nodename)
	if nodename==nil or nodename=="" then return nil
	--if you sent a number, assume that is the correct content id
	elseif type(nodename)=="number" then return nodename
	else return minetest.get_content_id(nodename)
	end --if
end --realms.get_content_id



--calculate biomes decoration percentages
--(this is different from the way minetest does its biome decorations)
--********************************
function realms.calc_biome_dec(biome)
	--minetest.log("realms calc_biome_dec-> biome="..von(biome.name))
	local d=1
	if biome.dec~=nil then --there are decorations!
		--# gets the length of an array
		--putting it in biome.dec.max is probably not really needed, but I find it easy to use and understand
		biome.dec.max=#biome.dec
		local chancetop=0
		local chancebot=0
		--loop BACKWARDS from last decoration to first setting our chances.
		--the point here is that we dont want to roll each chance individually.  We want to roll ONE chance,
		--and then determine which decoration, if any, was selected.  So this process sets up the chancetop and chancebot
		--for each dec element so that we can easily (and quickly) go through them when decorating.
		--example:  dec[1].chance=3 dec[2].chance=5 dec 3.chance=2
		--after this runs
		--dec[1].chancebot=7  dec[1].chancetop=9
		--dec[2].chancebot=2  dec[2].chancetop=7
		--dec[3].chancebot=0  dec[3].chancetop=2
		for d=biome.dec.max, 1, -1 do
			--minetest.log("realms calc_biome_dec->   decoration["..d.."] =")
			luautils.log_table(biome.dec[d])
			if biome.dec[d].chance~=nil then  --check this because intend to incorporate noise option in future.
				chancebot=chancetop
				chancetop=chancetop+biome.dec[d].chance
				biome.dec[d].chancetop=chancetop
				biome.dec[d].chancebot=chancebot
				--turn node entries from strings into numbers
				biome.dec[d].node=realms.get_content_id(biome.dec[d].node) --will return nil if passed nil
				--minetest.log("realms calc_biome_dec->  content_id="..von(biome.dec[d].node))
			end --if dec.chance~=nil
		end --for d
		--this is the default function for realms defined biomes, no need to have to specify it every time
		if biome.decorate==nil then biome.decorate=realms.decorate end
	end --if biome.dec~=nil
end --calc_biome_dec



--********************************
--untested, probably needs to be modified so you could add multiple decorations
function realms.add_decoration(biome,newdec)
	--minetest.log("add_decoration-> #newdec="..#newdec)
	if biome.dec==nil then biome.dec=newdec
	else 
		for _,v in pairs(newdec) do
			table.insert(biome.dec, v)
		end--for
	--biome.dec[#biome.dec+1]=newdec
	end --if
	realms.calc_biome_dec(biome)
	--minetest.log("  add_decoration -> #biome.dec="..#biome.dec)
end --add_decoration




--********************************
function realms.add_dec_flowers(biomein,modifier,cat)
	local biome
	if type(biomein)=="string" then biome=realms.biome[biomein]
	else biome=biomein
	end --if type(biomein)
	if modifer==nil or modifier==0 then modifier=1 end 
	if flowers then --if the flowers mod is available
		--the category parm may not be needed, since I'm just adding all flowers the same right now
		if cat==nil or cat=="all" then  
			realms.add_decoration(biome,
				{
					{chance=0.30*modifier, node="flowers:dandelion_yellow"},
					{chance=0.30*modifier, node="flowers:dandelion_white"},
					{chance=0.25*modifier, node="flowers:rose"},
					{chance=0.25*modifier, node="flowers:tulip"},
					{chance=0.20*modifier, node="flowers:chrysanthemum_green"},
					{chance=0.20*modifier, node="flowers:geranium"},
					{chance=0.20*modifier, node="flowers:viola"},
					{chance=0.05*modifier, node="flowers:tulip_black"},
				})
		end --if cat==all
	end --if flowers
end --add_dec_flowers


function realms.add_dec_mushrooms(biomein,modifier) --can add a cat to this later if needed
	if type(biomein)=="string" then biome=realms.biome[biomein]
	else biome=biomein
	end --if type(biomein)
	if modifer==nil or modifier==0 then modifier=1 end 
	realms.add_decoration(biome,
		{
			{chance=0.05*modifier,node="realms:mushroom_white"},
			{chance=0.01*modifier,node="realms:mushroom_milkcap"},
			{chance=0.01*modifier,node="realms:mushroom_shaggy_mane"},
			{chance=0.01*modifier,node="realms:mushroom_parasol"},
			{chance=0.005*modifier,node="realms:mushroom_sulfer_tuft"},
		})
	if flowers then --if the flowers mod is available
		realms.add_decoration(biome,
			{
				{chance=0.05*modifier, node="flowers:mushroom_brown"},
				{chance=0.05*modifier, node="flowers:mushroom_red"},
			})
	end --if flowers
end --add_dec_flowers


--********************************
function realms.register_biome(biome)
	if realms.biome[biome.name]~=nil then
		minetest.log("realms.register_biome-> ***WARNING!!!*** duplicate biome being registered!  biome.name="..biome.name)
	end
	realms.biome[biome.name]=biome

	--set defaults
	if biome.depth_top==nil then biome.depth_top=1 end
	if biome.node_filler==nil then biome.node_filler="default:dirt" end
	if biome.depth_filler==nil then biome.depth_filler=3 end
	if biome.node_stone==nil then biome.node_stone="default:stone" end


	--turn the node names into node numbers
	--minetest.log("*** biome.name="..biome.name)
	biome.node_dust = realms.get_content_id(biome.node_dust)
	biome.node_top = realms.get_content_id(biome.node_top)
	biome.node_filler = realms.get_content_id(biome.node_filler)
	biome.node_stone = realms.get_content_id(biome.node_stone)
	biome.node_water_top = realms.get_content_id(biome.node_water_top)
	biome.node_riverbed = realms.get_content_id(biome.node_riverbed)
	--will have to do the same thing for the dec.node entries, but we do that below

	--now deal with the decorations (this is different from the way minetest does its biomes)
	realms.calc_biome_dec(biome)
	minetest.log("realms-> biome registered for: "..biome.name)
end --register_biome



--********************************
function realms.voronoi_sort(a,b) 
	if a.dist==b.dist and a.y_min~=nil and b.y_min~=nil then return a.y_min<b.y_min
	else return a.dist<b.dist
	end --if
end --realms.voronoi_sort 



realms.vboxsz=20
--********************************
function realms.register_biomemap(biomemap)
	minetest.log("realms.register_biomemap "..biomemap.name.." ["..biomemap.typ.."]")
	if realms.biomemap[biomemap.name]~=nil then
		minetest.log("realms.register_biomemap-> ***WARNING!!!*** duplicate biome map being registered!  biomemap.name="..biomemap.name)
	end
	realms.biomemap[biomemap.name]=biomemap
	if biomemap.typ=="VORONOI" then
		--voronoi diagrams have some nice advantages
		--BUT, I dont know of any simple solution for finding the closest point in a list
		--so, I'm cheating.  We split the voronoi graph into lots of little boxes, calculate
		--the distance to every heat,humid point in the list FROM THE CENTER OF THE BOX
		--and then store that in a 2d array.  
		--now, when we get our noise, we just calculate which box the noise point is in, and
		--then use the list calculated from the center of that box.  It will not be completely
		--accurate, of course, but it should be good enough, and a lot faster than brute force
		biomemap.voronoi={}
		local vboxsz=realms.vboxsz
		--minetest.log("voronoi -> vboxsz="..vboxsz)
		for heat=0,vboxsz-1 do
			biomemap.voronoi[heat]={}
			for humid=0,vboxsz-1 do
				biomemap.voronoi[heat][humid]={}
				local cx=(heat/vboxsz)+(1/(vboxsz*2))
				local cz=(humid/vboxsz)+(1/(vboxsz*2))
				--minetest.log("voronoi-> heat="..heat.." humid="..humid.." cx="..cx.." cz="..cz)
				for i,v in ipairs(biomemap.list) do
					--v=biomemap which contains v.biome, v.heat_point, v_humidity_point
					--this is just a temporary place to store distance, it will be disposed of later
					v.biome.dist=luautils.distance2d(cx,cz, v.heat_point/100,v.humidity_point/100)
					--minetest.log("voronoi->     distance="..v.biome.dist.." to "..v.biome.name.." ("..v.heat_point..","..v.humidity_point..")")
					table.insert(biomemap.voronoi[heat][humid], v.biome) --we insert the actual biome not the biomemap
					--minetest.log("     "..v.biome.dist.."  "..v.biome.name)
				end --for biommap.list
			--now biomemap.voronoi[heat][humid] is a list of all the biomes in the biomemap, with dist
			--we need to sort them.
			table.sort(biomemap.voronoi[heat][humid], realms.voronoi_sort) 
			if biomemap.voronoi[heat][humid][1].count==nil then biomemap.voronoi[heat][humid][1].count=1
			else biomemap.voronoi[heat][humid][1].count=biomemap.voronoi[heat][humid][1].count+1
			end
			local b1=biomemap.voronoi[heat][humid][1]
			--minetest.log("voronoi["..heat.."]["..humid.."][1] -> dist="..b1.dist.." count="..b1.count.." : "..b1.name)
			--minetest.log("-----after sort")
			--for i,v in ipairs(biomemap.voronoi[heat][humid]) do minetest.log("     "..v.dist.."  "..v.name) end
			end --for humid		
		end --for heat
		--now, dispose of those dist variables you put into the biome so that no one thinks they have meaning.
		for i,v in ipairs(biomemap.list) do 
			v.biome.dist=nil 
			--minetest.log("voronoi analysis-> "..v.biome.count.." : "..v.biome.name)
			local c=v.biome.count
			if c==nil then c=0 end
			minetest.log("voronoi analysis-> "..c.." : "..v.biome.name)
			v.biome.count=nil
		end
	elseif biomemap.typ=="MATRIX" then
		--convert alternates from strings to direct links to the biomes
		--we could do this in register biome, but doing it here means we dont have to worry
		--about the order of the biomes
		--the reason for this?  With a voronoi map, if one biome is unavailble because of y_min/y_max restrictions
		--you just take the next closest distance heat/humidity point.  BUT, with a matrix type of biome map,
		--you can NOT have an empty spot on the matrix.  So we provide a list of alternate biomes if we provide
		--a y_min/y_max.  
		--this ends up working almost identical to the voronoi map because what is usually done with the voronoi
		--is to provide alternate biomes with the exact same heat/humidity point and different y_min/y_max limits
		minetest.log("realms.register_biomemap-> starting alternate scan for "..biomemap.name)
		--biomemap.biome is a table in the form of biomemap.biome[heat][humid]
		for i1,v1 in ipairs(biomemap.biome) do --loop through biomemap.biome[heat] 
			minetest.log("  heat index["..i1.."]")
			for i2,v2 in ipairs(v1) do --loop through biomemap.biome[heat][humid] (this gives us the actual biome)
				minetest.log("    humid index["..i2.."] "..v2.name)
				--only proceed if alternates exists, and if it is a list of strings (has not already been converted into actual biome links)
				if v2.alternates~=nil and type(v2.alternates[1])=="string" then
					for i3,v3 in ipairs(v2.alternates) do --loop through biomemap[heat][humid].alternates
						biomemap.biome[i1][i2].alternates[i3]=realms.biome[v3] --turn string name into actual biome
						minetest.log("      "..v2.name..".alternates["..i3.."]="..biomemap.biome[i1][i2].alternates[i3].name)
					end --for i3,v3
				end --if v2.alternates
			end --for i2,v2
		end --for i1,v1
						
	end --if biomemap.typ
	minetest.log("realms-> biomemap registered for: "..biomemap.name)
end --register_biomemap






--********************************
function realms.randomize_depth(depth,variation,noise)
	if depth<3 then return depth
	else 
		local d=depth-(depth*variation)+(depth*variation*math.abs(noise))
		return d
	end--if depth
end --reandomize_depth
--[[
function realms.randomize_depth(depth,variation,noise,x,z,minp,chunk_size)
	if depth<3 then return depth
	else 
		local nixz=luautils.xzcoords_to_flat(x,z, minp, chunk_size)
		--minetest.log("randomize_depth-> depth="..depth.." variation="..variation.." noise="..luautils.var_or_nil(noise))
		--return depth-(depth*variation)+(depth*variation*math.abs(noise[nixz]))
		local d=depth-(depth*variation)+(depth*variation*math.abs(noise[nixz]))
		--minetest.log("randomize_depth-> depth="..depth.." variation="..variation.." nixz="..nixz.." noise="..noise[nixz].." d="..d)
		return d
	end--if depth
end --reandomize_depth
]]






--********************************
function realms.gen_realms(chunk_minp, chunk_maxp, seed)
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
	vm:get_data(data)
	vm:get_param2_data(vmparam2)
	local mts = {} --mts array stores schematics
	--add a schematic to this table with: table.insert(parms.mts,{pos,schematic})  (shouldnt matter if table or file, but dont forget the position!)
	--the schematics will be written to the chunk after all other manipulation is done
	--we do it this way because minetest.place_schematic writes to the map, not the vm area, so it gets messed up
	--when the vm is saved after all the realms run.
	--and place_schematic_vmanip does nothing if you are writing to the area, it has to be run after 'set data' and before any of: 'set lighting', 'calc lighting', 'write to map'.
	--https://minetest.org/forum/viewtopic.php?f=47&t=4668&start=2340
	--idea for using table from https://forum.minetest.net/viewtopic.php?f=47&t=18259
	local lsys = {} --lsys array stores lsystem entries same as mts stores schematics, and for the same reason

	--share is used to pass data between rmgs working on the same chunk
	local share={}
	--r already equals one that matches, so start there
	--could just do the match here automatically and skip the overlap check, then start at r+1?
	local rstart=r
	local first=0
	for r=rstart,realm.count,1 do
		local parms=realm[r].parms
		if luautils.check_overlap(parms.realm_minp, parms.realm_maxp, chunk_minp,chunk_maxp)==true then
			if first==0 then
				minetest.log("======== realms-> gen_realms chunk minp="..pts(chunk_minp).." maxp="..pts(chunk_maxp))
				first=1
			end --first
			--minetest.log("realms-> gen_realms r="..r.." rmg="..luautils.var_or_nil(realm[r].rmg)..
			--		" realm minp="..pts(parms.realm_minp).." maxp="..pts(parms.realm_maxp))
			--minetest.log("     sealevel="..parms.sealevel.." chunk minp="..pts(chunk_minp).." maxp="..pts(chunk_maxp))

			--rmg[realm[r].rmg](realm[r].parms.realm_minp,realm[r].parms.realm_maxp, realm[r].parms.sealevel, chunk_minp,chunk_maxp, 0)
			parms.chunk_minp=chunk_minp
			parms.chunk_maxp=chunk_maxp
			parms.isect_minp, parms.isect_maxp = luautils.box_intersection(parms.realm_minp,parms.realm_maxp, parms.chunk_minp,parms.chunk_maxp)
			parms.isectsize2d = luautils.box_sizexz(parms.isect_minp,parms.isect_maxp)
			parms.isectsize3d = luautils.box_size(parms.isect_minp,parms.isect_maxp)
			parms.minposxz = {x=parms.isect_minp.x, y=parms.isect_minp.z}
			parms.share=share
			parms.area=area
			parms.data=data
			parms.vmparam2=vmparam2
			parms.vm=vm  --I dont know if the map gen needs this, but just in case, there it is.
			parms.mts=mts --for storing schematics to be written before vm is saved to map
			parms.lsys=lsys
			parms.chunk_seed=seed --the seed that was passed to realms for this chunk
			--minetest.log("realms-> r="..r)
			minetest.log("  >>>realms-> gen_realms r="..r.." rmg="..luautils.var_or_nil(realm[r].rmg).." isect "..pts(parms.isect_minp).."-"..pts(parms.isect_maxp))
			realms.rmg[realm[r].rmg](parms)
			if parms.area~=area then minetest.log("***realms.init-> WARNING parms.area~=area!!!") end
			share=parms.share --save share to be used in next parms (user might have changed pointer)
		end --if overlap
	end--for

	--Wrap things up and write back to map, send data back to voxelmanip
	--(by saving here we avoid multiple save and pulls in overlapping realm map gens)
	minetest.log("  ---realms-> saving area "..luautils.range_to_str(chunk_minp,chunk_maxp))
	vm:set_data(data)
	vm:set_param2_data(vmparam2)
	--apply any schematics that were set (see comments above where parms.mts is defined)
	--generator should have placed schematics using: table.insert(parms.mts,{pos,schematic})
	--now we loop through them and know that mts[i][i]=pos and mts[i][2]=schematic
	--need to modify to let user specify is placement should be random or not.
	for i = 1, #mts do
		minetest.place_schematic_on_vmanip(vm, mts[i][1], mts[i][2], "random", nil, true)  --true means force replace other nodes
	end


	--calc lighting
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--write it to world	
	vm:write_to_map()

	for i = 1, #lsys do
		minetest.log("decorate->spawning lsystem tree at ("..pts(lsys[i][1])..")")
		minetest.spawn_tree(lsys[i][1],lsys[i][2])
	end --for

end -- gen_realms

dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_layer_barrier.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_flatland.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_very_simple.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_2dMap.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_mesas.lua")
--dofile(minetest.get_modpath("realms").."/realms_map_generators/bg_basic_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bf_basic_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_caves.lua")
--dofile(minetest.get_modpath("realms").."/realms_map_generators/bf_odd_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tg_stupid_islands.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bf_generic.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bd_basic_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bd_odd_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bm_basic_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bm_mixed_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bd_default_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bm_default_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bm_mesas_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/bm_shattered_biomes.lua")
dofile(minetest.get_modpath("realms").."/realms_map_generators/tf_generic_2dMap_loop.lua")

minetest.register_on_generated(realms.gen_realms)
realms.read_realms_config()




