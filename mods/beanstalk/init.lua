--beanstalk

--brief explanation of what each of the beanstalk parameters do/mean
--bnst[lv][b]  lv=what level of the world this beanstalk is on.  1=ordinary ground level.  if your world has more levels, 1=the first level above ground level, etc
--stemtot= total number of stems (vines) in this beanstalk. 
--stemrad= the radius of each stem.  
--rot1radius= this is the radius that the stems rotate around each other.  
--rot1dir= direction stems rotate around each other.  1=clockwise, -1=counter clockwise.  
--rot1yper360= y units per one 360 degree rotation of a stem
--rot2radius= the radius of the secondary spiral.  this is the radius that the center the stems are rotating around rotates around. 
--rot2yper360= y units per one 360 degree rotation of the secondary spiral
--rot2dir= direction the secondary spiral rotates.  1=clockwise, -1=counter clockwise
--rot1crazy= this number is how much the rot1radius changes.  if rot1crazy=3 then rot1radius will vary by -3 to +3
--rot2crazy= this number is how much the rot2radius changes.  if rot2crazy=6 then rot2radius will vary by -6 to +6

--to avoid confusion
--beanstalk=the whole beanstalk plant
--stalk = the node placed to create the beanstalk stems
--stem = a beanstalk consist of multiple stems that wind around each other
--vine = the little vines on the side of the stem that make the beanstalk climbable when vertical

beanstalk = { } --will be used to hold functions.
--putting the functions into a lua table like this is, I believe, generally considered good form
--because it makes it easy for any other mod to access them if needed

--this runs nodes.lua, I put all the node definitions in there in instead of in init.lua
--it helps to keep the code cleaner and more organized.  I run nodes.lua near the top of init.lua
--because we use those node definitions in some of the code below
dofile(minetest.get_modpath("beanstalk").."/nodes.lua")

--grab content IDs -- You need these to efficiently access and set node data.  get_node() works, but is far slower
local c_air = minetest.get_content_id("air")

--These are the constants that need to be modified based on your game needs
--we store all the important variables in a single table, bnst, this makes it easy to
--write to a file and read from a file
--local bnst={["level_max"]=5}   --(counting up from 1, what is the highest "level" of beanstalks?)
local bnst={}


--this function displays the entire bnst_values table in the log
--it is just for debugging purposes
--********************************
function beanstalk.displaybv()
--  if msg==nill then msg="" end
	minetest.log("beanstalk-> ")
	minetest.log("beanstalk-> ===Beanstalk_Values===")
	--minetest.log(minetest.serialize(bnst_values))
	--minetest.log("--")
	for klv,vlv in ipairs(bnst_values) do
		--minetest.log("klv="..klv.." type(vlv)="..type(vlv))
		if type(vlv)~="table" then
			mintest.log("beanstalk-> bnst_values."..klv.."="..vlv)
		else
			local r=1
			--minetest.log("  in ktag bnst_values[klv].count.chancefrm.1="..bnst_values[klv].count.chancefrm[r])
--      for ktag,vtag in ipairs(bnst_values[klv]) do 
			for ktag,vtag in pairs(vlv) do       
				--minetest.log("ktag="..ktag.." type(vtag)="..type(vtag)) 
				if type(vtag)~="table" then
					minetest.log("beanstalk-> bnst_values["..klv.."]."..ktag.."="..vtag)
				else 
					--minetest.log("    in kfld")
					for kfld,vfld in pairs(bnst_values[klv][ktag]) do
						--minetest.log("kfld="..kfld.." type(vfld)="..type(vfld)) 
						if type(vfld)~="table" then
							minetest.log("beanstalk-> bnst_values["..klv.."]["..ktag.."]."..kfld.."="..vfld)
						else
							--minetest.log("  in krow")
							for krow,vrow in pairs(bnst_values[klv][ktag][kfld]) do              
									minetest.log("beanstalk-> bnst_values["..klv.."]["..ktag.."]["..kfld.."]["..krow.."]="..vrow)              
							end --for krow
						end --if kfld not table
					end --for kfld
				end --if ktag not table
			end --for ktag
		end --if klv not table 
	end --for klv   
	minetest.log("beanstalk-> ==end==")
	minetest.log("beanstalk-> ")
end --displaybv
	
	
--this copies any unset values in bnst_values[lv] from bnst_values[lv-1]
--so that you don't have to repeat data for each level if it is the same
--It is in a function because it is called in two places
--********************************
function beanstalk.copy_prev_bnst_values(lv)
	local plv=lv-1
	for k,v in pairs(bnst_values[plv]) do  --loop through everything (tags and base level vars) in previous level
		if bnst_values[lv][k]==nil then 
			bnst_values[lv][k]=bnst_values[plv][k] 
			--minetest.log("beanstalk-> copy prev value k="..k)      
			end --if this level is unpopulated, copy previous level
	end --for
end --copy_prev_beanstalk_values
	
	
--load beanstalk values from file  beanstalk_values.conf
--NOTE: this is NOT the particular settings for each beanstalk.  These are the numbers and
--formulas used to randomly determine the values for each beanstalk.
--I put this in a file because folks are going to want to play with/modify these numbers and
--it is a lot easier (and less intimidating) to do it from a file than to directly modify
--the lua code.  This also means that you could update the code without loosing your customized
--settings
--IMPORTANT NOTE: the beanstalk_values file is ONLY read when a beanstalks file does not already exist
--this means that the very first time you start a new world with beanstalks, the beanstalk_values file 
--will be read, and all of the beanstalks will be created using those values.  After that, the 
--beanstalks are loaded from the beanstalks file and this file will not be used again until you 
--create a new world
--
--this function loads the beanstalk values (the user defined formulas for creating beanstalks)
--from the beanstalk_values file.  it will first look in the world folder, if it doesn't
--find it there it will look in the mod folder.
--this is only run once at world creation (unless you delete the beanstalk file)
--********************************
function beanstalk.read_beanstalk_values()
	minetest.log("beanstalk-> reading beanstalk value file")
	local str   --str will be the string read from the file
	local p     --position
	local tag   --the stuff to the left of the = sight, could be beasntalk_level, count, bot, etc
	local value --the stuff to the right of the = sign
	local prevtag=""
	local lv=0  --lv is what level of the world you are on
	local r --will hold what line of the ranomized value table we are loading
	bnst_values={}
	bnst_values.level_max=0
		minetest.log("beanstalk-> file wrldpth="..minetest.get_worldpath().."/beanstalk_values.conf")
		minetest.log("beanstalk-> file modpath="..minetest.get_modpath("beanstalk").."/beanstalk_values.conf")  
	--first we look to see if there is a beanstalks_values file in the world path
	local file = io.open(minetest.get_worldpath().."/beanstalk_values.conf", "r")
	--if its not in the worldpath, try for the modpath
	if file then
		minetest.log("beanstalk-> loading beanstalk_values from worldpath:")
	else  
		file = io.open(minetest.get_modpath("beanstalk").."/beanstalk_values.conf", "r")    
		if file then minetest.log("beanstalk-> loading beanstalk_values from modpath") 
		else minetest.log("beanstalk-> unable to find beanstalk_values file in worldpath or modpath.  This is bad")
		end --if file (modpath)
	end --if file (worldpath)   
	if file then  
		for line in file:lines() do
			str = line
			minetest.log("beanstalk-> str:"..str)
			--eliminate comments
			p=string.find(str,"%-%-")  -- because hypen is a magic character in lua you have to escape it, this searches for --
			if p~=nil then str=string.sub(str,1,p-1) end              
			--split based on =, every line with data has an = in it
			p=string.find(str,"=")
			if p~=nil then --equals : now we know we have an actual entry
				--split beanstalk_level=0 into tag=beanstalk_level value=0  
				--split stemrad =75:2,6 into tag=stemrad value=75:2,6
				tag=luautils.trim(string.sub(str,1,p-1)) --tag is everything to the left of the =
				value=luautils.trim(string.sub(str,p+1)) --value is everything to the right of the =
				--minetest.log("beanstalk->   tag="..tag.." value="..value)
				
				if tag=="beanstalk_level" then  --new beanstalk level
					lv=value+0  --the plus zero converts from string to number
					--I should probably add level checking to make certain they are doing these in order
					--I don't think I want to remove the level number from the values file
					if lv>bnst_values.level_max then bnst_values.level_max=lv end
					bnst_values[lv]={}               
					--minetest.log("beanstalk->   created new lv="..lv)
					if lv>2 then --check back values
						--if the user does not set a value in a level, then take the value from the previous level
						beanstalk.copy_prev_bnst_values(lv-1)
					end --if
					minetest.log("beanstalk->   lv="..lv.." (new level)")                  
				else --tag but not beanstalk_level: process this line as a new entry for this beanstalk level             
					if tag~="" then --this is a new tag, not a blank continuation
						r=1 --new tag, first row
						--minetest.log("beanstalk->   lv="..lv.." new tag="..tag.." r="..r)
						--we have a new tag value zero out the rndval table vars  
						bnst_values[lv][tag]={}                              
						bnst_values[lv][tag].chancemax=1  --chancemax is what is the maximum random number we need to roll on the chance table of values, default=1
						bnst_values[lv][tag].rowmax=r
						--now initialize [tag]for these items so we can use as a multi-dementional array [tag][r] 
						bnst_values[lv][tag].chancefrm={}
						bnst_values[lv][tag].chanceto={}
						bnst_values[lv][tag].valfrm={}
						bnst_values[lv][tag].valto={}            
						bnst_values[lv][tag].chancefrm[r]=1 --first entry in table always starts from 1 
						bnst_values[lv][tag].chanceto[r]=1  --will be changed later probably
						prevtag=tag
					else --tag=""   blank tags are continuations of the previous tag 
						tag=prevtag      
						r=r+1
						--minetest.log("beanstalk->   lv="..lv.." continued tag="..tag.." r="..r)            
						bnst_values[lv][tag].rowmax=r
						--local oldchanceto=bnst_values[lv][tag].chanceto[r-1]
						--bnst_values[lv][tag].chancefrm[r]=oldchanceto+1 
						bnst_values[lv][tag].chancefrm[r]=bnst_values[lv][tag].chanceto[r-1]+1
						bnst_values[lv][tag].chanceto[r]=bnst_values[lv][tag].chancefrm[r] --will be changed later probably
						--minetest.log("beanstalk->   lv="..lv.." continued tag="..tag.." r="..r.." chancefrm="..bnst_values[lv][tag].chancefrm[r])            
						--for any row past the first, chancefrom is one greater than the previous chanceto
						--remember chancefrm chanceto and chancemax are about the chance table values, the chance that we will use this rows valfrm and valto to get results 
					end --if tag~=""                                                  
					
					--now check to see if this is a simple entry with one value, like vnode=bnst_vine1, or a complex entry with ranges like rot1yper360=3:1;80
					local pbar=string.find(value,"|")  --find the vert bar                       
					if pbar==nil then --we have a simple tag with just one value like vnode=bnst_vine1, or a single row with a range, like stemtot=3;5. fake a row for it          
						if r>1 then
							minetest.log("beanstalk-> ERROR:"..str)
							minetest.log("beanstalk->  lv="..lv.." tag="..tag.." r="..r.." ERROR! should never have an entry with blank tag and no bar!")
						else --r==1
							--minetest.log("beanstalk-> simple entry, no bar, value="..value);
							--no chance table, so we make one up just to make this work the same as all the others  example: snode=bnst_stalk1
							--bnst_values[lv][tag].chanceto[r]=bnst_values[lv][tag].chancefrm[r]  --it is already set this way as default isnt it?
							local psemicol=string.find(value,";")
							if psemicol~=nil then --semicol
								bnst_values[lv][tag].valfrm[r]=luautils.trim(string.sub(value,1,psemicol-1))
								bnst_values[lv][tag].valto[r]=luautils.trim(string.sub(value,psemicol+1))
							else --no semicol, only one value
								bnst_values[lv][tag].valfrm[r]=value
								bnst_values[lv][tag].valto[r]=value
							end --semicol							
						end --r>1
					else --pbar found
						--so we have a value in the form of 75|2;6 or 2|1  
						--the number before the bar is the chance.  
						--the numbers after the bar are the actual beanstalk from and to values for this entry (to is optional)
						local chance=luautils.trim(string.sub(value,1,pbar-1)) --to the left of the :
						--chancefrom and chanceto are used to pick which row we will get the values from          
						local valfromto=luautils.trim(string.sub(value,pbar+1))  --to the right of the :        
						--minetest.log("beanstalk->       chance="..chance.." valfromto="..valfromto)  
						--valfrom and valto are the actual range of values we will roll from to pick the final beanstalk value
						--if chancefrom=1 and chance=5 then chanceto=5
						--if chancefrom=6 and chance=3 then chanceto=8
						--chance tells us what the range is for this row entry
						bnst_values[lv][tag].chanceto[r]=bnst_values[lv][tag].chancefrm[r]+chance-1
						--chancemax tells us the maximum chance we have to roll on the chance values table.
						--could update this from the last row when we are done instead of updating it as we go.  But this works.
						bnst_values[lv][tag].chancemax=bnst_values[lv][tag].chanceto[r] 

						--we use semicolon instead of comma so that you can use math with a colon in it in your definitions (like math.random(from,to))
						local psemicol=string.find(valfromto,";")
						if psemicol~=nil then --semicol
							bnst_values[lv][tag].valfrm[r]=luautils.trim(string.sub(valfromto,1,psemicol-1))
							bnst_values[lv][tag].valto[r]=luautils.trim(string.sub(valfromto,psemicol+1))
						else --no semicol, only one value
							bnst_values[lv][tag].valfrm[r]=valfromto
							bnst_values[lv][tag].valto[r]=valfromto
						end --semicol
					end --bar
				minetest.log("beanstalk->   lv="..lv.." tag="..tag.." r="..r.." chancefrm="..bnst_values[lv][tag].chancefrm[r]..
						" chanceto="..bnst_values[lv][tag].chanceto[r].." valfrm="..bnst_values[lv][tag].valfrm[r].." valto="..bnst_values[lv][tag].valto[r])
				minetest.log("beanstalk->      chancemax="..bnst_values[lv][tag].chancemax.." rowmax="..bnst_values[lv][tag].rowmax)                  
				end --if tag="beanstalk_level"  
			end --equals    
		end -- for line in file:lines() do
	beanstalk.copy_prev_bnst_values(bnst_values.level_max)  --got to copy previous values for the last one
	end --if file 
	minetest.log("beanstalk-> beanstalk_values loaded bnst_values.level_max="..bnst_values.level_max)
	beanstalk.displaybv()
end --read_beanstalk_values


--this function is used for creating random seed values.
--it returns a number that is an integer, strips out . e and + and leading zeros
--returned number is always 14 chars long
--we also reverse the number, because the highest digit has the least randomness due to carry over
--so, for example 1.0382452725245+e14 will become 54252725428301
function beanstalk.seednum(numin)
	--local rslt=string.gsub(string.gsub(string.gsub(numin,"%.",""),"e",""),"+","")  --eliminate . e and +
	local rslt=string.gsub(string.gsub(numin,"%.",""),"-","") --remove the decimal point and any negative sign  
	--rslt=rslt:match("(%d+)e.*")  --remove scientific notation   my regex doesn't work, so doing this the old fasioned way
	local p=string.find(rslt,"e")
	if p~=nil then rslt=string.sub(rslt,1,p-1) end  --strip off the scientific notation
	rslt=rslt:match("0*(%d+)")   --strip leading zeros 
	rslt=string.reverse(rslt):match("0*(%d+)")  --reverse and strip leading zeros again
	--now make certain it is 14 long.
	repeat
		rslt=string.sub(rslt..string.reverse(rslt),1,14) 
	until string.len(rslt)==14
	--minetest.log("stripnum numin="..numin.." rslt="..rslt)
	return tonumber(rslt)
end  


--this is used to retreave beanstalk values.  It rolls random results from bnst_values table
--pass b=0 when calling for values in bnst[lv]
--********************************
function beanstalk.get_bval(lv,b,tag)  
	--minetest.log("beanstalk-> bval: lv="..lv.." b="..b.." tag="..tag)
	--get a random seed
	local lvseed=beanstalk.seednum(math.sin(lv))
	--minetest.log("beanstalk-> bval: b="..b)
	--minetest.log("beanstalk-> bval: math.tan(b)="..math.tan(b)) 
	local _,bseed=math.modf(math.tan(b))
	--minetest.log("beanstalk-> bval: modf(b)="..bseed)
	bseed=beanstalk.seednum(bseed)
	--minetest.log("beanstalk-> bval: strip(b)="..bseed)
	local tagseed=1
	for i=1,string.len(tag),1 do
		tagseed=beanstalk.seednum(tagseed*string.byte(tag,i)+beanstalk.seednum(math.cos(string.byte(tag,i))))
	end --for 

	local seed=beanstalk.seednum(bnst.seed+lvseed+bseed+tagseed)

	--you are probably wondering, why go to all this trouble to reseed the random number generator this way?
	--well, there IS a reason.  This way, the random numbers stay the same for a world with the same mapseed.
	--and that is helpful when you are debugging and testing, because you can make a small change in the
	--settings or code, then generate a new world with the same mapseed and know that the differences you
	--see are because of the change, since the random numbers are the same.
	math.randomseed(seed)
	
	--minetest.log("beanstalk-> bval: mapseed  ="..minetest.get_mapgen_setting("seed"))
	--minetest.log("beanstalk-> bval: bnst.seed="..bnst.seed)
	--minetest.log("beanstalk-> bval: lvseed   ="..lvseed)
	--minetest.log("beanstalk-> bval: bseed    ="..bseed)
	--minetest.log("beanstalk-> bval: tagseed  ="..tagseed)
	--minetest.log("beanstalk-> bval: seed     ="..seed)  
 
	local rnd=math.random(1,bnst_values[lv][tag].chancemax)   
	local r=1
 -- minetest.log("beanstalk-> rowmax="..bnst_values[lv][tag].rowmax)
 -- minetest.log("beanstalk-> chancefrm="
	while r<=bnst_values[lv][tag].rowmax and rnd>bnst_values[lv][tag].chanceto[r] do      
		r=r+1
	end--while
	--minetest.log("beanstalk-> bval: r="..r)
	--I'm not going to waste time checking if r<=varin.maxrows because that shouldnt be possible
	--may change my mind on that later.
	local rslt=""
	local valfrm=bnst_values[lv][tag].valfrm[r]
	local valto=bnst_values[lv][tag].valto[r]
	--minetest.log("beanstalk-> bval: before variable substitution valfrm="..valfrm.." valto="..valto)  
	
	--these are the variables that can be substituted     
	local vars={}
	if b>0 then   
		--easy to add other variables to this list if we need them later
		vars={stemtot=luautils.var_or_nil(bnst[lv][b].stemtot), 
					stemradius=luautils.var_or_nil(bnst[lv][b].stemradius),
					rot1dir=luautils.var_or_nil(bnst[lv][b].rot1dir),               
					rot1radius=luautils.var_or_nil(bnst[lv][b].rot1radius), 
					rot1circumf=luautils.var_or_nil(bnst[lv][b].rot1circumf), 
					rot1yper360=luautils.var_or_nil(bnst[lv][b].rot1yper360), 
					rot1crazy=luautils.var_or_nil(bnst[lv][b].rot1crazy),
					rot2dir=luautils.var_or_nil(bnst[lv][b].rot2dir),                
					rot2radius=luautils.var_or_nil(bnst[lv][b].rot2radius), 
					rot2circumf=luautils.var_or_nil(bnst[lv][b].rot2circumf),               
					rot2yper360=luautils.var_or_nil(bnst[lv][b].rot2yper360), 
					rot2crazy=luautils.var_or_nil(bnst[lv][b].rot2crazy)} 
	end --if b>0  
	local rslt
	--only call string_math if tag is not one of our text tags
	if tag~="snode" and tag~="vnode" and tag~="enforce_min_rot1rad" then
		valfrm=luautils.string_math(valfrm,vars)
		valto=luautils.string_math(valto,vars)
	end  
	if valfrm==valto then rslt=valfrm
	else --if valfrm is different from valto, then get a random number between valfrm and valto    
		rslt=math.random(valfrm,valto)    
	end--if 

	return rslt
end --get_bval
	

--this is the perlin noise that will be used for "crazy" beanstalks
--I don't really understand how these parms work, but this link has
--a nice attempt at explaining: https://forum.minetest.net/viewtopic.php?f=47&t=13278#p194281
local np_crazy =
	{
	 offset = 0,
	 scale = 1,
	 spread = {x=15, y=8, z=8},
	 seed = 0, --this will be overriden
	 octaves = 1,
	 persist = 0.67
	 }
--since I'm using this perlin noise one dimensionally, I would have assumed a spread of
--{x=15, y=1, z=1} would have been right, but that reduces the variation too much.
--I really do NOT understand perlin noise well enough.


--this function calculates (very approximately) the circumference of a circle of radius r in voxels
--this could be made much more accurate
--this function has to be way up here because it has to be defined before it is used
--*!* this is in luautils, it should be used from there, not here.
--********************************
function beanstalk.voxel_circum(r)
	if r==1 then return 4
	elseif r==2 then return 8
	else return 2*math.pi*r*0.88 --not perfect, but a pretty good estimate
	end --if
end --voxel_circum


--this function generates the calculated constants that apply to each beanstalk level.
--we do not store these values in the beanstalk file because if the user changes any of the
--basic values (such as count) in the beanstalk file, we want all of THESE values to be recalculated
--correctly after the beanstalk file is read.
--this function is run TWICE in create_beanstalks.  That is because it has to be run
--BEFORE create_beanstalks, in order to set up the constants used in that function.  But
--create_beanstalks also runs write_beanstalks, which wipes these values out (because we dont want to write
--them to the beanstalk file) so it is run again after the call to write_beanstalks to reset the values again
--when reading from the beanstalk file this function only runs once
--********************************
function beanstalk.calculated_constants_bylevel()
	--calculated constants by level
	bnst.level_max=bnst_values.level_max 
	for lv=1,bnst.level_max do
		--bnst[lv].seed=bnst.seed+(math.sin(lv)*100000000)  --this gives us a uniqe different seed for each level, used for crazy
		if bnst[lv]==nil then bnst[lv]={} end --we run this more than once, dont want to wipe out values other times
		bnst[lv].count=beanstalk.get_bval(lv,0,"count")
		bnst[lv].bot=beanstalk.get_bval(lv,0,"bot")
		bnst[lv].height=beanstalk.get_bval(lv,0,"height")
		--*!* should put some logging or at least error catching around these?
		minetest.log("beanstalk-> ccbl snode="..beanstalk.get_bval(lv,0,"snode").."  vnode="..beanstalk.get_bval(lv,0,"vnode"))
		bnst[lv].snode=minetest.get_content_id(beanstalk.get_bval(lv,0,"snode"))
		bnst[lv].vnode=minetest.get_content_id(beanstalk.get_bval(lv,0,"vnode"))

		bnst[lv].per_row=math.floor(math.sqrt(bnst[lv].count))  --beanstalks per row are the sqrt of beanstalks per level
		bnst[lv].count=bnst[lv].per_row*bnst[lv].per_row  --recalculate to a perfect square
		--so yes, the count you set can be changed
		bnst[lv].area=62000/bnst[lv].per_row
		bnst[lv].top=bnst[lv].bot+bnst[lv].height-1
		minetest.log("beanstalk-> calculated constants by level lv="..lv.." per_row="..bnst[lv].per_row..
			" count="..bnst[lv].count.." area="..bnst[lv].area.." top="..bnst[lv].top)
	end --for
end --calculated_constants_bylevel


--this function generates the calculated constants that apply to each beanstalk.  We dont
--store these in the beanstalk file because if the user changes any of those values in the file
--(such as the beanstalk position) we need these constants to be recalculated correctly
--this function has to run after you create_beanstalks or read_beanstalks
--this function displays the beanstalk list in debug.txt
--********************************
function beanstalk.calculated_constants_bybnst()
	--calculated constants by beanstalk
	minetest.log("beanstalk-> calculated constants by beanstalk")
	minetest.log("beanstalk-> list --------------------------------------")
	for lv=1,bnst.level_max do  --loop through the levels
		minetest.log("***beanstalk-> level="..lv.." ***")    
		for b=1,bnst[lv].count do   --loop through the beanstalks
			minetest.log("beanstalk->   lv="..lv.." b="..b)     
			bnst[lv][b].rot1min=bnst[lv][b].rot1radius --default if we dont set crazy
			bnst[lv][b].rot1max=bnst[lv][b].rot1radius --default if we dont set crazy
			bnst[lv][b].rot2min=bnst[lv][b].rot2radius --default if we dont set crazy
			bnst[lv][b].rot2max=bnst[lv][b].rot2radius --default if we dont set crazy

			if bnst[lv][b].rot1crazy>0 then
				--determine the min and max we will move the rot1radius through
				bnst[lv][b].rot1max=bnst[lv][b].rot1radius+bnst[lv][b].rot1crazy
				bnst[lv][b].rot1min=bnst[lv][b].rot1radius-bnst[lv][b].rot1crazy
				if bnst[lv][b].rot1min<bnst[lv][b].stemradius then --we dont want min to be too small
					--below line says add what we take off the min to the max
					bnst[lv][b].rot1max=bnst[lv][b].rot1max+(bnst[lv][b].stemradius-bnst[lv][b].rot1min)
					bnst[lv][b].rot1min=bnst[lv][b].stemradius
				end --if rot1min<stemradius
			end --if rot1crazy>0
			bnst[lv][b].noise1=nil
			--now, right here would be a GREAT place to create and store the perlin noise.
			--BUT, you cant do that at this point, because the map isn't generated.  and for some odd reason,
			--the perlin noise function exits as nil if you use it before map generation.  so we will do it
			--in the generation loop
			--perlin noise is random, but SMOOTH, so it makes interesting looking changes.
			--we need to play with the perlin noise values and see if we can get results we like better

			if bnst[lv][b].rot2crazy>0 then
				--determine the min and max we will move the rot2radius through
				bnst[lv][b].rot2max=bnst[lv][b].rot2radius+bnst[lv][b].rot2crazy
				bnst[lv][b].rot2min=bnst[lv][b].rot2radius-bnst[lv][b].rot2crazy
				if bnst[lv][b].rot2min<0 then --we dont want min to be too small
					--below line says add what we take off the min to the max
					bnst[lv][b].rot2max=bnst[lv][b].rot2max+math.abs(bnst[lv][b].rot2min)
					bnst[lv][b].rot2min=0
				end --if rot2min<0
			end --if rot2crazy>0
			bnst[lv][b].noise2=nil

			-- total radius = rot1radius (radius stems circle around) + stem radius + 2 more for a space around the beanstalk (will be air)
			-- so this is the total radius around the current center
			bnst[lv][b].totradius=bnst[lv][b].rot1max+bnst[lv][b].stemradius+2
			-- but totradius can not be used for determining min and maxp, because the current center moves! for that we need
			-- full radius = max diameter of entire beanstalk including outer spiral (rot2radius)
			bnst[lv][b].fullradius=bnst[lv][b].totradius+bnst[lv][b].rot2max
			bnst[lv][b].minp={x=bnst[lv][b].pos.x-bnst[lv][b].fullradius, y=bnst[lv][b].pos.y, z=bnst[lv][b].pos.z-bnst[lv][b].fullradius}
			bnst[lv][b].maxp={x=bnst[lv][b].pos.x+bnst[lv][b].fullradius, y=bnst[lv].top, z=bnst[lv][b].pos.z+bnst[lv][b].fullradius}

			--display it
			local logstr="bnst["..lv.."]["..b.."] "..minetest.pos_to_string(bnst[lv][b].pos)
			logstr=logstr.." stemtot="..bnst[lv][b].stemtot.." stemrad="..bnst[lv][b].stemradius
			logstr=logstr.." rot1dir="..bnst[lv][b].rot1dir.." rot1radius="..bnst[lv][b].rot1radius.." rot1yper360="..bnst[lv][b].rot1yper360
			logstr=logstr.." rot1crazy="..bnst[lv][b].rot1crazy      
			logstr=logstr.." rot2dir="..bnst[lv][b].rot2dir.." rot2radius="..bnst[lv][b].rot2radius.." rot2yper360="..bnst[lv][b].rot2yper360
			logstr=logstr.." rot2crazy="..bnst[lv][b].rot2crazy
			bnst[lv][b].desc=logstr
			minetest.log(logstr)
		end --for b
	end --for lv
	minetest.log("beanstalk-> list --------------------------------------")
end --calculated_constants_bybnst


--saves the bnst list in minetest/worlds/<worldname>/beanstalks
--we could just recalculate the beanstalks from scratch each time, but writing them to a file
--gives the server admin the option of moving a beanstalk closer to spawn or further away
--or letting them play with the numbers if they want.  It also means that updates that
--change the way beanstalks are generated should not cause an existing games beanstalks
--to change positions or anything else disruptive like that.
--********************************
function beanstalk.write_beanstalks()
	minetest.log("beanstalk-> write_beanstalks")
	local file = io.open(minetest.get_worldpath().."/beanstalks", "w")
	if file then
		--wipe out variables that we will recalculate
		for lv=1,bnst.level_max do  --loop through the levels
			bnst[lv].per_row=nil
			bnst[lv].area=nil
			bnst[lv].top=nil
			for b=1,bnst[lv].count do   --loop through the beanstalks
				bnst[lv][b].rot1min=nil
				bnst[lv][b].rot1max=nil
				bnst[lv][b].rot1circumf=nil
				bnst[lv][b].rot2min=nil
				bnst[lv][b].rot2max=nil
				bnst[lv][b].rot2circumf=nil
				bnst[lv][b].totradius=nil
				bnst[lv][b].fullradius=nil
				bnst[lv][b].minp=nil
				bnst[lv][b].maxp=nil
				bnst[lv][b].desc=nil
			end --for b
			--bnst[lv].max=nil
		end --for lv
		file:write(minetest.serialize(bnst))
		file:close()
	end
end --write_beanstalks


--this function checks to see if two boxes overlap
--the function is actually pretty simple once you realize that the easiest way to do this
--is to determine what proves two boxes do NOT overlap.
--If box1minp.x > box2maxp.x then they can not overlap on that coord.  Likewise, if
--if box1maxp.x < box1minp.x then they can not overlap on that coord.  So, we check for the opposite,
--and for each coord
--********************************
--*!* this is in luautils, why do I have it here?  remove it and test
--function check_overlap(box1minp,box1maxp,box2minp,box2maxp)
--	if box1minp.x<=box2maxp.x and box1maxp.x>=box2minp.x and
--		 box1minp.y<=box2maxp.y and box1maxp.y>=box2minp.y and
--		 box1minp.z<=box2maxp.z and box1maxp.z>=box2minp.z then
--		 return true
--	else return false
--	end --if
--end --check_overlap



--this is the function that randomly generates the beanstalks based on the map seed, level,
--and beanstalk.  It should usually only run once per game
--then the results are written to the beanstalk file.  But if you deleted the beanstalk
--file so this would run again, you should get identical results.  UNLESS you've changed the
--beanstalk_values file
--********************************
function beanstalk.create_beanstalks()
	minetest.log("beanstalk-> create beanstalks")
	local logstr
	local lv=1
	
	--get_mapgen_params is deprecated; use get_mapgen_setting
	local mapseed = minetest.get_mapgen_setting("seed") --this is how we get the mapgen seed
	--lua numbers are double-precision floating-point which can only handle numbers up to 100,000,000,000,000
	--but the seed we got back is 20 characters!  We dont really need that much randomness anyway, so we are
	--going to just take the first 14 chars, and turn it into a number, so we can do multiplication and addition to it
	mapseed=tonumber(string.sub(mapseed,1,14))
	bnst.seed=mapseed

	--we need to load the beanstalk_value file
	beanstalk.read_beanstalk_values()

	--we need these values calculated before we do some of the things below:
	beanstalk.calculated_constants_bylevel()

	for lv=1,bnst.level_max do  --loop through the levels

		for b=1,bnst[lv].count do   --loop through the beanstalks
			bnst[lv][b]={ }
			--bnst[lv][b].seed=mapseed+lv*10000+b  
			--this gives us a unique seed for each beanstalk, used for perlin noise for crazy
			bnst[lv][b].seed=mapseed+beanstalk.seednum(math.cos(lv))+beanstalk.seednum(math.sin(b))

			--note that our random position is always at least 500 from the border, so that beanstalks can NEVER be right next to each other
			local overlap=false
			repeat
				bnst[lv][b].pos={ }
				bnst[lv][b].pos.x=math.floor(-31000 + (bnst[lv].area * (b % bnst[lv].per_row) + 500+math.random(0,bnst[lv].area-1000) ))
				bnst[lv][b].pos.y=math.floor(bnst[lv].bot)  --floor just in case the user put some crazy fraction in here
				bnst[lv][b].pos.z=math.floor(-31000 + (bnst[lv].area * (math.floor(b/bnst[lv].per_row) % bnst[lv].per_row) + 500 + math.random(0,bnst[lv].area-1000) ))
								--now check to see if this beanstalk overlaps one below it.  the odds of this are tiny tiny tiny, but must be prevented anyway
				if lv>1 then
					local lvdn=lv-1
					local bdn=1
					--note that when this runs, minp and maxp have not been calculated yet for any beanstalks!
					--so we just make them up with a distance of 250 for each, guaranteeing a distance of 500 between beanstalks
					local bnst1minp={ }
					bnst1minp.x=bnst[lv][b].pos.x-250
					bnst1minp.y=bnst[lv][b].pos.y
					bnst1minp.z=bnst[lv][b].pos.z-250
					local bnst1maxp={ }
					bnst1maxp.x=bnst[lv][b].pos.x+250
					bnst1maxp.y=bnst[lv][b].pos.y
					bnst1maxp.z=bnst[lv][b].pos.z+250
					local bnst2minp={ }
					bnst2minp.x=bnst[lvdn][bdn].pos.x-250
					bnst2minp.y=bnst[lvdn][bdn].pos.y
					bnst2minp.z=bnst[lvdn][bdn].pos.z-250
					local bnst2maxp={ }
					bnst2maxp.x=bnst[lvdn][bdn].pos.x+250
					bnst2maxp.y=bnst[lvdn][bdn].pos.y
					bnst2maxp.z=bnst[lvdn][bdn].pos.z+250
					repeat
						if luautils.check_overlap(bnst1minp,bnst1maxp,bnst2minp,bnst2maxp) then
							overlap=true
						end
						bdn=bdn+1
					until bdn>bnst[lvdn].count or overlap==true
				end --if lv>0
			until overlap==false

			--stemtot = total number of stems
			bnst[lv][b].stemtot=beanstalk.get_bval(lv,b,"stemtot")
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." stemtot="..bnst[lv][b].stemtot)
			
			--stemradius = radius of each stem
			bnst[lv][b].stemradius=beanstalk.get_bval(lv,b,"stemradius")
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." stemradius="..bnst[lv][b].stemradius)      
			
			--rot1dir = direction of rotation of the inner spiral
			bnst[lv][b].rot1dir=beanstalk.get_bval(lv,b,"rot1dir")
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot1dir="..bnst[lv][b].rot1dir)        

			--rot1radius = the radius the stems rotate around
			bnst[lv][b].rot1radius=beanstalk.get_bval(lv,b,"rot1radius")       
			if string.upper(beanstalk.get_bval(lv,b,"enforce_min_rot1rad"))=="Y" then      
				--stems merge too much if the rotation radius isn't at least stemradius
				--and stem radius +1 looks better in my opinion
				if bnst[lv][b].rot1radius<bnst[lv][b].stemradius then bnst[lv][b].rot1radius=bnst[lv][b].stemradius+1 
				end --if rot1radius<stemradius
			end --if enforce_min_rot1rad
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot1radius="..bnst[lv][b].rot1radius)          
						
			--rot1circumf = is usually used when determining yper360
			bnst[lv][b].rot1circumf=beanstalk.voxel_circum(bnst[lv][b].rot1radius)  --used as a variable for setting yper360

			--rot1yper360 = y units per one 360 degree rotation of a stem
			bnst[lv][b].rot1yper360=math.floor(beanstalk.get_bval(lv,b,"rot1yper360"))
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot1yper360="..bnst[lv][b].rot1yper360)             

			--rot1crazy = how much rot1radius varies
			--crazy gives us a number, the biger the number, the bigger the range of change in the crazy stem rot1radius value
			--note that this is the number we change each way, so crazy=3 means from radius-3 to radius+3
			--and crazy=6 is a whopping TWELVE change in radius, that should be VERY noticible
			--in calculated_constants_bybnst we use rot1crazy to set rot1min and rot1max
			bnst[lv][b].rot1crazy=beanstalk.get_bval(lv,b,"rot1crazy")    
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot1crazy="..bnst[lv][b].rot1crazy)     

			--rot2dir = direction of rotation of the outer spiral
			bnst[lv][b].rot2dir=beanstalk.get_bval(lv,b,"rot2dir")    
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot2dir="..bnst[lv][b].rot2dir)         
			
			--rot2radius = radius of the secondary spiral
			bnst[lv][b].rot2radius=beanstalk.get_bval(lv,b,"rot2radius")    
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot2radius="..bnst[lv][b].rot2radius)       

		 --rot2circumf is usually used when determining yper360      
			bnst[lv][b].rot2circumf=beanstalk.voxel_circum(bnst[lv][b].rot2radius)  --used as a variable for setting yper360

			--rot2yper360 = y units per one 365 degree rotation of secondary spiral
			bnst[lv][b].rot2yper360=math.floor(beanstalk.get_bval(lv,b,"rot2yper360"))
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot2yper360="..bnst[lv][b].rot2yper360)         
--      if math.random(1,4)<4 then bnst[lv][b].rot2yper360=math.floor(math.random(bnst[lv][b].rot2circumf,100))
--      else bnst[lv][b].rot2yper360=math.floor(math.random(bnst[lv][b].rot2circumf*0.75,500))
--      end

			--rot2crazy = like rot1crazy, but this is for the outer spiral
			--in calculated_constants_bybnst we use rot2crazy to set rot2min and rot2max
			bnst[lv][b].rot2crazy=beanstalk.get_bval(lv,b,"rot2crazy")    
			--minetest.log("beanstalk-> setting: lv="..lv.." b="..b.." rot2crazy="..bnst[lv][b].rot2crazy)         
		end --for b
	end --for lv
	
	--local l1=1
	--local b1=1

	--now that we have created all the values, we need to write them to the file.
	--in the future, create_beanstalks will not be run again, instead, values will be read from the beanstalk file.
	beanstalk.write_beanstalks()
	--but that wiped out some of our calculated constants bylevel, so lets redo them
	beanstalk.calculated_constants_bylevel()
	--and also get the beanstalk level calculated constants
	beanstalk.calculated_constants_bybnst()
end --create_beanstalks



--get beanstalks, from file if exists, otherwise generate
--********************************
function beanstalk.read_beanstalks()
	minetest.log("beanstalk-> reading beanstalks file")
	local file = io.open(minetest.get_worldpath().."/beanstalks", "r")
	if file then
		bnst = minetest.deserialize(file:read("*all"))
		-- check if it was an empty file because empty files can crash server
		if bnst == nil then
			minetest.log("beanstalk-> ERROR: beanstalk file exists but is empty, will recreate")
			beanstalk.create_beanstalks()
		else  --file exists and was loaded
			beanstalk.calculated_constants_bylevel()
			beanstalk.calculated_constants_bybnst()
		end  --if bnst==nil
		file:close()
	else --file does not exist
		minetest.log("beanstalk-> beanstalk file does not exist, creating it")
		beanstalk.create_beanstalks()
	end --if file
end --read_beanstalks



--this function checks to see if a node should have vines.  it is only called for positions
--that are vine radius +1.  The rules for adding a vine are pretty simple:
--if this location is not itself a vine or beanstalk, AND, the position directly below
--this position IS a beanstalk, then we add a vine.  That way vines appear on vertical
--surfaces, but not where you have nice climbable stair steps.
--parms: lv=current level  x,y,z pos of this node, vcx vcz center of this vine, also pass area and data so we can check below
--********************************
function beanstalk.checkvines(lv, x,y,z, vcx,vcz, area,data)
	local changed=false
	local vn = area:index(x, y, z)  --we get the node we are checking
	local vndown = area:index(x, y-1, z)  --and the node right below the one we are checking
	--if vn is not beanstalk or vines, and vndown is not beanstalk, then we will place a vine
	if data[vn]~=bnst[lv].snode and data[vn]~=bnst[lv].vnode and data[vndown]~=bnst[lv].snode then
		data[vn]=bnst[lv].vnode
		changed=true
		local pos={x=x,y=y,z=z}
		local node=minetest.get_node(pos)
		--we have the vine in place, but we need to rotate it with the vines
		--against the big beanstalk node.
		--if diff x is bigger than diff z we put against the x face, otherwize z
		--if diff is negative we put against plus face, otherwise minus face
		--facedir 0=top 1=bot 2=+x 3=-x 4=+z 5=-z
		local facedir=2
		local diffx=math.abs(x-vcx)
		local diffz=math.abs(z-vcz)
		if diffx>=diffz then
			if (x-vcx)<0 then facedir=2 else facedir=3 end
		else
			if (z-vcz)<0 then facedir=4 else facedir=5 end
		end
		node.param2=facedir --setting param2 on the node changes where it faces.
		minetest.swap_node(pos,node)
		--and for some reason I do not understand, you can't set it before you place it.
		--you have to set it afterwards and then swap it for it to take effect
	end --if
return changed
end --checkvines


--this is the function that will run EVERY time a chunk is generated.
--see at the bottom of this program where it is registered with:
--minetest.register_on_generated(gen_beanstalk)
--minp is the min point of the chunk, maxp is the max point of the chunk
--********************************
function beanstalk.gen_beanstalk(minp, maxp, seed)
	--we dont want to waste any time in this function if the chunk doesnt have
	--a beanstalk in it.
	--so first we loop through the levels, if our chunk is not on a level where beanstalks
	--exist, we just do a return
	--note that we assume levels are in ascending order so we can stop checking once we pass maxp.y
	local chklv=0
	local lv=0
	repeat
		chklv=chklv+1
		if bnst[chklv].bot<=maxp.y and bnst[chklv].top>=minp.y then lv=chklv end
	until chklv==bnst.level_max or lv>0  or bnst[chklv+1].bot>maxp.y
	if lv<1 then return end  --quit, we didn't match any level

	--now we know we are on a level with beanstalks, so we now need to check each beanstalk to
	--see if they intersect this chunk, if not, we return and waste no more cpu.
	--I think this could be made more efficent, seems we should be able to zero in on which
	--beanstalk to check better than just looping through them.
	--why are we looping through lv again?  because beanstalk levels can overlap (not beanstalks themselves)
	--but usually a beanstalk on level 1 will start below the surface of level 1, and extend ABOVE the surface of level 1
	--and the beanstalks of level 2 will start below the surface of level 2, which means they start at less than the top
	--of the beanstalks from level 1.  so we have to check for TWO levels that might match
	local b
	repeat --lv loop again
		local chkb=0
		b=0
		repeat
			chkb=chkb+1
			--this checks to see if the chunk is within the beanstalk area
			if luautils.check_overlap(minp,maxp,bnst[lv][chkb].minp,bnst[lv][chkb].maxp) then
					 b=chkb  --we are in the beanstalk!
			end --if
		until chkb==bnst[lv].count or b>0
		if b<1 then lv=lv+1 end --try next level, in case of lv overlap (not beanstalk overlap)
	until b>0 or lv>bnst.level_max or bnst[lv].bot>maxp.y

	if b<1 then return end --quit; otherwise, you'd have wasted resources

	--ok, now we know we are in a chunk that has beanstalk in it, so we need to do the work
	--required to generate the beanstalk

	--easy reference to commonly used values
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local ymax=maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local ymin=minp.y
	local z0 = minp.z

	--minetest.log("bnst [beanstalk_gen] BEGIN chunk minp ("..x0..","..y0..","..z0..") maxp ("..x1..","..y1..","..z1..")") --tell people you are generating a chunk
	--This actually initializes the LVM
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local changedany=false
	local stemx={ } --initializing the variable so we can use it for an array later
	local stemz={ }
	local rot1radius
	local rot2radius
	local stemradius
	local stemthiny
	local y
	local a1
	local a2
	local cx   --cx=center point x
	local cz   --cz=center point z
	local ylvl

	--y0 is the bottom of the chunk, but if y0<the bottom of the beanstalk, then we
	--will reset y to the bottom of the beanstalk to avoid wasting cpu
	y=y0
	if y<bnst[lv][b].minp.y then
		y=bnst[lv][b].minp.y  --no need to start below the beanstalk
	end

	stemthiny=bnst[lv].top-(bnst[lv][b].stemradius*4) --for the "taper off" logic below

	repeat  --this top repeat is where we loop through the chunk based on y

		--the purpose of this bit of code is to "taper off" the end of the beanstalk at the very top
		stemradius=bnst[lv][b].stemradius  --default
		if y>stemthiny then
			local disttopdown=(y-stemthiny)-1
			stemradius=bnst[lv][b].stemradius-((disttopdown/4) % bnst[lv][b].stemradius)
			--minetest.log("bnstt stemradius="..stemradius)
		end

		--calculate rot1crazy
		rot1radius=bnst[lv][b].rot1radius
		if bnst[lv][b].rot1crazy>0 then
			if bnst[lv][b].noise1==nil then
				--couldnt create the noise before mapgen, so doing it now (and only once per beanstalk)
				--I really only need 1d noise.  chulens defines the area of noise generated
				--I am defining the x axis only
				local chulens = {x=bnst[lv].height, y=1, z=1}
				local minposxz = {x=0, y=0}
				--minetest.log("beanstalk-> crazy check lv="..lv.." b="..b.." bnst[lv][b].seed="..luautils.var_or_nil(bnst[lv][b].seed))
				np_crazy.seed=bnst[lv][b].seed
				--really might want to change some of the other values based on how big the crazy number is?
				bnst[lv][b].noise1 = minetest.get_perlin_map(np_crazy, chulens):get2dMap_flat(minposxz)
				--now noise1 is an array indexed from 1 to height and
				--with each value in the range from -1 to 1 with fairly smooth changes
			end --if noise==nil
			--so I've got a noise number from -1 to 1, I need to turn it into a radius in the range min to max
			local midrange=(bnst[lv][b].rot1max-bnst[lv][b].rot1min)/2 --middle of our range
			ylvl=y-bnst[lv][b].pos.y+1 --the array goes from 1 up, so we add 1
			rot1radius=math.floor(bnst[lv][b].rot1min+(midrange+(midrange*bnst[lv][b].noise1[ylvl])))
		end --if rot1crazy>0

		--calculate rot2crazy
		rot2radius=bnst[lv][b].rot2radius
		if bnst[lv][b].rot2crazy>0 then
			if bnst[lv][b].noise2==nil then
				--couldnt create the noise before mapgen, so doing it now
				local chulens = {x=bnst[lv].height, y=1, z=1}
				local minposxz = {x=0, y=0}
				np_crazy.seed=bnst[lv][b].seed*2  --times 2 so it will be different than noise1
				bnst[lv][b].noise2 = minetest.get_perlin_map(np_crazy, chulens):get2dMap_flat(minposxz)
				local midrange=(bnst[lv][b].rot2max-bnst[lv][b].rot2min)/2
			end --if noise2==nil
			--so I've got a number from -1 to 1, I need to turn it into a radius in the range min to max
			local midrange=(bnst[lv][b].rot2max-bnst[lv][b].rot2min)/2
			ylvl=y-bnst[lv][b].pos.y+1 --the array goes from 1 up, so we add 1
			rot2radius=math.floor(bnst[lv][b].rot2min+(midrange+(midrange*bnst[lv][b].noise2[ylvl])))
		 end --if rot2crazy>0

		--now, if we had "crazy" we set local rot1radius and rot2radius above.  if we didnt
		--the same locals were set to the beanstalk values.  we use the local values below

		--lets get the beanstalk center based on secondary spiral
		a2=(360/bnst[lv][b].rot2yper360)*(y % bnst[lv][b].rot2yper360)*bnst[lv][b].rot2dir
		cx=bnst[lv][b].pos.x+rot2radius*math.cos(a2*math.pi/180)
		cz=bnst[lv][b].pos.z+rot2radius*math.sin(a2*math.pi/180)
		--now cx and cz are the new center of the beanstalk

		for v=1, bnst[lv][b].stemtot do --calculate centers for each vine
			-- an attempt to explain this rather complicated looking formula:
			-- (360/bnst[lv][b].stemtot)*v       gives me starting angle for this vine
			-- +(360/bnst[lv][b].rot1yper360) the change in angle for each y up
			--   (y-bnst[lv][b].pos.y)        the y pos in this beanstalk
			--                         % bnst[lv][b].rot1yper360)  get mod of yper360, together this gives us how many y up we are (for this section)
			-- *((y-bnst[lv][b].pos.y) % bnst[lv][b].rot1yper360)  multiply change in angle for each y, by how many y up we are in this section
			-- *bnst[lv][b].rot1dir  makes us rotate clockwise or counter clockwise
			a1=(360/bnst[lv][b].stemtot)*v+(360/bnst[lv][b].rot1yper360)*((y-bnst[lv][b].pos.y) % bnst[lv][b].rot1yper360)*bnst[lv][b].rot1dir
			--now that we have the rot2 center cx,cz, and the offset angle, we can calculate the center of this vine
			stemx[v]=cx+rot1radius*math.cos(a1*math.pi/180)
			stemz[v]=cz+rot1radius*math.sin(a1*math.pi/180)
		end --for v

		--we are inside the repeat loop that loops through the chunc based on y (from bottom up)
		--these two for loops loop through the chunk based x and z
		--changedthis says if there was a change in the z loop.  changedany says if there was a change in the whole chunk
		for x=x0, x1 do
			for z=z0, z1 do
				local vi = area:index(x, y, z) -- This accesses the node at a given position
				local changedthis=false
				local v=1
				repeat  --loops through the vines until we set the node or run out of vines
					local dist=math.sqrt((x-stemx[v])^2+(z-stemz[v])^2)
					if dist <= stemradius then  --inside stalk
						data[vi]=bnst[lv].snode
						changedany=true
						changedthis=true
						--minetest.log("--- -- stalk placed at x="..x.." y="..y.." z="..z.." (v="..v..")")
					--this else says to check for adding climbing vines if we are 1 node outside stalk of a beanstalk vine
					--(it is confusing that I call them both vine.  I should have called it stalks and vines)
					elseif dist<=(stemradius+1) then --one node outside stalk
						if beanstalk.checkvines(lv, x,y,z, stemx[v],stemz[v], area,data)==true then
							changedany=true
							changedthis=true
							--minetest.log("--- -- vine placed at x="..x.." y="..y.." z="..z.."(v="..v..")")
						end --changed vines
					end  --if dist
					v=v+1 --next vine
				until v > bnst[lv][b].stemtot or changedthis==true
				--add air around the stalk.  (so if we drill through a floating island or another level of land, the beanstalk will have room to climb)
				if changedthis==false and (math.sqrt((x-cx)^2+(z-cz)^2) <= bnst[lv][b].totradius)
						and (y > bnst[lv][b].pos.y+30) and (data[vi]~=c_air) then
					--minetest.log("bnstR setting air=false dist="..math.sqrt((x-cx)^2+(z-cz)^2).." totradius="..bnst[lv][b].totradius.." cx="..cx.." cz="..cz.." y="..y)
					data[vi]=c_air
					changedany=true
				end --if changedthis=false
			end --for z
		end --for x

		y=y+1 --next y
	until y>bnst[lv][b].maxp.y or y>y1


	if changedany==true then
		-- Wrap things up and write back to map
		--send data back to voxelmanip
		vm:set_data(data)
		--calc lighting
		vm:set_lighting({day=0, night=0})
		vm:calc_lighting()
		--write it to world
		vm:write_to_map(data)
		--minetest.log("beanstalk-> >>saved")
	end --if changed write to map

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	minetest.log("bnst["..lv.."]["..b.."] END chunk="..x0..","..y0..","..z0.." - "..x1..","..y1..","..z1.." [beanstalk_gen] "..chugent.." ms") --tell people how long
end -- beanstalk


--list_beanstalks is mainly here for testing.  It may be removed (or at least restricted)
--once this mod is complete
--********************************
function beanstalk.list_beanstalks(playername)
	local player = minetest.get_player_by_name(playername)
	local lv
	local b
	for lv=1,bnst.level_max do  --loop through the levels
		minetest.chat_send_player(playername,"***bnst level="..lv.." ***")
		for b=1,bnst[lv].count do   --loop through the beanstalks
			 minetest.chat_send_player(playername, bnst[lv][b].desc)
		end --for b
	end --for lv
end --list_beanstalks


--teleports you to a specific beanstalk, this is mainly here for testing
--and will probably be removed (or at least restricted) once this mod is complete
--********************************
function beanstalk.go_beanstalk(playername,param)
	local player = minetest.get_player_by_name(playername)
	if param=="" then minetest.chat_send_player(playername,"format is go_beanstalk <lv>,<b>")
	else
		--local lv, b = param:find("^(-?%d+)[, ](-?%d+)$")  --splits param on comma or space
		local slv,sb = string.match(param,"([^,]+),([^,]+)")
		local lv=tonumber(slv)
		local b=tonumber(sb)
		local p={x=bnst[lv][b].pos.x,y=bnst[lv][b].pos.y,z=bnst[lv][b].pos.z}
		--NEVER do local p=bnst[lv][b].pos passes by reference not value and you will change the original bnst pos!
		p.x=p.x+bnst[lv][b].fullradius+2
		p.y=p.y+13
		player:setpos(p)
		--player:set_look_yaw(100)  this is depricated, but set_look_horizontal uses radians
		player:set_look_horizontal(1.75)
	end --if
end --go_beanstalk


--note that the below stuff is NOT in a function and will run at the start of every game

--register the list_beanstalk chat command
minetest.register_chatcommand("list_beanstalks", {
	params = "",
	description = "list_beanstalks: list the beanstalk locations",
	func = function (name, param)
		beanstalk.list_beanstalks(name)
	end,
})

--register the go_beanstalk chat command
minetest.register_chatcommand("go_beanstalk", {
	params = "<lv> <b>",
	description = "go_beanstalk <lv>,<b>: teleport to beanstalk location",
	func = function (name,param)
		beanstalk.go_beanstalk(name,param)
	end,
})


--this is a test of reading the values, it will REALLY be called in read_beanstalks probably
beanstalk.read_beanstalk_values()

--this is what makes us create the beanstalk list
beanstalk.read_beanstalks()

--this is what makes the beanstalk function run every time a chunk is generated
minetest.register_on_generated(beanstalk.gen_beanstalk)

