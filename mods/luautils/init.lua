luautils = { }

--this function calculates (very approximately) the circumference of a circle of radius r in voxels
--this could be made much more accurate
--this function has to be way up here because it has to be defined before it is used
--********************************
function luautils.voxel_circum(r)
	if r==1 then return 4
	elseif r==2 then return 8
	else return 2*math.pi*r*0.88 --not perfect, but a pretty good estimate
	end --if
end --voxel_circum



--this function checks to see if two boxes overlap
--the function is actually pretty simple once you realize that the easiest way to do this
--is to determine what proves two boxes do NOT overlap.
--If box1minp.x > box2maxp.x then they can not overlap on that coord.  Likewise, if
--if box1maxp.x < box1minp.x then they can not overlap on that coord.
--check for the same on each coord.
--we could check for the positive condition (box1minpx<=box2maxpx and box1maxpx>=box2minpx)
--but then you have to check all 6 conditions.  by checking for the negative, we can
--drop out of the function as soon as we hit any coord that proves the boxes do not overlap
--it may not save much time, but every microsecond counts. :)
--********************************
function luautils.check_overlap(box1minp,box1maxp,box2minp,box2maxp)
	if box1minp.x > box2maxp.x or box1maxp.x < box2minp.x or
		 box1minp.y > box2maxp.y or box1maxp.y < box2minp.y or
		 box1minp.z > box2maxp.z or box1maxp.z < box2minp.z then
		 return false
	else return true
	end --if
end --check_overlap
--old positive check, not as good
--  if box1minp.x<=box2maxp.x and box1maxp.x>=box2minp.x and
--     box1minp.y<=box2maxp.y and box1maxp.y>=box2minp.y and
--     box1minp.z<=box2maxp.z and box1maxp.z>=box2minp.z then
--     return true
--  else return false
--  end --if



--returns true if point is inside the box defined by minp,maxp
--********************************
function luautils.point_in_box(point, minp,maxp)
	return luautils.check_overlap(point,point, minp,maxp)
end --point_in_box



--returns true if point(x,y,z) is inside the box defined by minp,maxp
--********************************
function luautils.xyz_in_box(x,y,z, minp,maxp)
	return luautils.point_in_box({x=x,y=y,z=z}, minp,maxp)
end --xyz_in_box



--this function adjusts (trims) the secondary box to be inside the primary box
--WARNING: this function assumes that the primary and secondary boxes overlap
--if they dont, you will get back strange results.
--********************************
function luautils.box_intersection(primary_minp,primary_maxp, secondary_minp,secondary_maxp)
	local minp={}
	local maxp={}

	minp.x=secondary_minp.x
	if minp.x<primary_minp.x then minp.x=primary_minp.x end
	maxp.x=secondary_maxp.x
	if maxp.x>primary_maxp.x then maxp.x=primary_maxp.x end

	minp.y=secondary_minp.y
	if minp.y<primary_minp.y then minp.y=primary_minp.y end
	maxp.y=secondary_maxp.y
	if maxp.y>primary_maxp.y then maxp.y=primary_maxp.y end

	minp.z=secondary_minp.z
	if minp.z<primary_minp.z then minp.z=primary_minp.z end
	maxp.z=secondary_maxp.z
	if maxp.z>primary_maxp.z then maxp.z=primary_maxp.z end

	return minp,maxp
end --box_intersection



--this rounds a number to a specific digit place.
--0=integer  round_digits(3.14159,0) = 3
--1,2,3.. that many decimal places, round_digits(3.14159,2)=3.14
--a nil or negative value for digits results in no rounding
--********************************
function luautils.round_digits(num,digits)
	if digits==nil or digits<0 then return num
	else
		if num >= 0 then return math.floor(num*(10^digits)+0.5)/(10^digits)
		else return math.ceil(num*(10^digits)-0.5)/(10^digits)
		end
	end
end --round_digits



--round digits on a position
--********************************
function luautils.round_digits_pos(pos,digits)
	if pos.z==nil then return {x=luautils.round_digits(pos.x,digits),y=luautils.round_digits(pos.y,digits)}
	else return {x=luautils.round_digits(pos.x,digits),y=luautils.round_digits(pos.y,digits),
					z=luautils.round_digits(pos.z,digits)}
	end --if pos.z
end --round_digits_pos



--lua does not allow overloading functions, so you can not specify func(one,two) and func(one,two,three)
--but lua parameters are all optional, so you can just define as func(one,two,three) and then inside
--the function check to see if three==nil and respond accordingly.   This is used for rounddigits below
--
--this calculates the distance between two positions, 2D only, passing the x and z values directly
--note that rounddigits is optional, if you call as just luautils.distance2d(x1,z1,x2,z2) it will not round
--also, rounding is done AFTER the distance calculation, not before.  (does that matter?)
--********************************
function luautils.distance2d(x1,z1, x2,z2, rounddigits)
	return luautils.round_digits(math.sqrt((x2-x1)^2+(z2-z1)^2), rounddigits)
	--this works because round_digits does not round when rounddigits=nil
end --distance2d



--this calculates the distance between two positions, 3D only, passing the x, y, and  z values directly
--note that rounddigits is optional, if you call as just luautils.distance2d(x1,y1,z1,x2,y1,z2) it will not round
--also, rounding is done AFTER the distance calculation, not before.  (does that matter?)
--********************************
function luautils.distance3d(x1,y1,z1, x2,y2,z2, rounddigits)
	return luautils.round_digits(math.sqrt((x2-x1)^2+(z2-z1)^2+(y2-y1)^2), rounddigits)
	--this works because round_digits does not round when rounddigits=nil
end --distance3d



--this calculates the distance between two positions, 2D only (x,z)
--note that rounddigits is optional, if you call as just luautils.distance2d(pos1,pos2) it will not round
--********************************
function luautils.distance2d_pos(pos1,pos2,rounddigits)
	return luautils.distance2d(pos1.x,pos1.z, pos2.x,pos2,z, rounddigits)
end --distance2d



--calculate distance between two points, 3D (x,y,z)
--note that rounddigits is optional, if you call as just luautils.distance3d(pos1,pos2) it will not round
--********************************
function luautils.distance3d_pos(pos1in,pos2in,rounddigits)
	return luautils.distance3d(pos1.x,pos1.y,pos1.z, pos2.x,pos2.y,pos2.z, rounddigits)
end --distance3d



--rubanwardy points out in his excellent modding book that square roots are computationaly expensive.
--a fact that is obviously true but that I hadn't taken into account.  He recommended comparing distances
--to the square of the distance to avoid the square root.  so, to make that possible, I have created
--duplicates of all of the distance functions, but these return only the square

--this calculates the distance between two positions, 2D only, passing the x and z values directly
--and returns the SQUARE of the result (not the square root) since square root is slow
--note that rounddigits is optional, if you call as just luautils.distance2d(x1,z1,x2,z2) it will not round
--also, rounding is done AFTER the distance calculation, not before. 
--********************************
function luautils.distance2d_sq(x1,z1, x2,z2, rounddigits)
	return luautils.round_digits((x2-x1)^2+(z2-z1)^2, rounddigits)
	--this works because round_digits does not round when rounddigits=nil
end --distance2d



--this calculates the distance between two positions, 3D only, passing the x, y, and  z values directly
--and returns the SQUARE of the result (not the square root) since square root is slow
--note that rounddigits is optional, if you call as just luautils.distance2d(x1,y1,z1,x2,y1,z2) it will not round
--also, rounding is done AFTER the distance calculation, not before.  (does that matter?)
--********************************
function luautils.distance3d_sq(x1,y1,z1, x2,y2,z2, rounddigits)
	return luautils.round_digits((x2-x1)^2+(z2-z1)^2+(y2-y1)^2, rounddigits)
	--this works because round_digits does not round when rounddigits=nil
end --distance3d



--this calculates the distance between two positions, 2D only (x,z) RETURNS THE SQUARE
--note that rounddigits is optional, if you call as just luautils.distance2d(pos1,pos2) it will not round
--********************************
function luautils.distance2d_pos_sq(pos1,pos2,rounddigits)
	return luautils.distance2d_sq(pos1.x,pos1.z, pos2.x,pos2,z, rounddigits)
end --distance2d



--calculate distance between two points, 3D (x,y,z) RETURNS THE SQUARE
--note that rounddigits is optional, if you call as just luautils.distance3d(pos1,pos2) it will not round
--********************************
function luautils.distance3d_pos_sq(pos1in,pos2in,rounddigits)
	return luautils.distance3d_sq(pos1.x,pos1.y,pos1.z, pos2.x,pos2.y,pos2.z, rounddigits)
end --distance3d



--handles nil
--separator is optional, if you do not pass it, it will default to comma
--rounddigits is optional, if you call as just luautils.pos_to_str(posin) it will not round
--********************************
function luautils.pos_to_str(posin, separator, rounddigits)
	if posin==nil then return "(nil)"
	else
		local sep=","
		if separator ~= nil then sep=separator end
		local pos=posin
		if rounddigits ~= nil then pos=luautils.round_digits_pos(posin,rounddigits) end
		if pos.z==nil then return "("..pos.x..sep..pos.y..")"
		else return "("..pos.x..sep..pos.y..sep..pos.z..")"
		end --if pos.z==nil
	end --if
end --pos_to_str



--same as pos_to_str but with coords
--********************************
function luautils.pos_to_str_xyz(x,y,z, separator, rounddigits)
	return luautils.pos_to_str({x=x,y=y,z=z}, separator, rounddigits)
end --pos_to_str_xyz


--like pos to str, but takes to positions and returns (x1,y1,z1)-(x2,y2,z2)
--********************************
function luautils.range_to_str(posin1,posin2, separator, rounddigits)
	return luautils.pos_to_str(posin1, separator, rounddigits).."-"..luautils.pos_to_str(posin2, separator, rounddigits)
end --pos_to_str




--reutrns true if pos1 x,y,z = pos2 x,y,z
--will work on any combination of x, y, and ze
--if you pass to tables without any x,y,z values,
--this will return equal
--********************************
function luautils.pos_equals(pos1, pos2)
	if    ( (pos1.x==nil and pos2.x==nil) or (pos1.x==pos2.x) )
		and ( (pos1.y==nil and pos2.y==nil) or (pos1.y==pos2.y) )
		and ( (pos1.z==nil and pos2.z==nil) or (pos1.z==pos2.z) )
		then return true
	else return false
	end --if
end --pos_equals



--return true if position is ground content
--********************************
function luautils.is_ground_content(pos)
	if minetest.registered_nodes[minetest.get_node(pos).name].is_ground_content then return true
	else return false
	end --if
end --is_ground_content


--return true if content_id is ground content
--********************************
function luautils.is_ground_content_id(id)
	if minetest.registered_nodes[minetest.get_name_from_content_id(id)].is_ground_content then return true
	else return false
	end --if
end --is_ground_content



--return center of box given minp and maxp
--********************************
function luautils.center_of_box(minp,maxp)
	local cent={}
	cent.x=math.floor(minp.x+(maxp.x-minp.x)/2)
	cent.y=math.floor(minp.y+(maxp.y-minp.y)/2)
	cent.z=math.floor(minp.z+(maxp.z-minp.z)/2) 
	return cent
end --center_of_box



--remove trailing and leading whitespace from string.
--from PiL2 20.4
--********************************
function luautils.trim(s)
	if s==nil then return nil 
	else return (s:gsub("^%s*(.-)%s*$", "%1"))
	end
end



--returns the next field from a string based on a seperator char
--the first time you call this you should pass p=1 or p=nil
--call as:
--fld,p=luautils.next_field(str,":",p)
--and keep passing it the same p (do not modify it) until p==nil
--trim and num are optional.  pass "trim" or "notrim" and "num" or "str"
--********************************
function luautils.next_field(s,sep,p,trim,num)
	--minetest.log("luautils-> next_field: s="..luautils.var_or_nil(s).." sep="..luautils.var_or_nil(sep).." p="..luautils.var_or_nil(p))
	if p==nil then p=1 end
	if s==nil or sep==nil or p>string.len(s) then return nil,nil end
	if trim==nil or trim=="" then trim="NOTRIM" end
	trim=string.upper(trim)
	if num==nil or num=="" then num="STR" end
	num=string.upper(num)

	local oldp=p
	p=string.find(s,sep,oldp)
	--if we did not find another separator, then return everything to the end of the string
	--and return p=nill so the user will know we are done.
	local rtn=nil
	if p==nil then rtn=string.sub(s,oldp) 
	else --we found a separator
		rtn=string.sub(s,oldp,p-1)
		p=p+1
		if p>string.len(s) then p=nil end --we are done
	end --if p==nil
	if rtn~=nil and trim=="TRIM" then rtn=luautils.trim(rtn) end
	--if rtn~=nil and num=="NUM" then rtn=rtn+0 end
	if rtn~=nil and num=="NUM" then rtn=tonumber(rtn) end
	return rtn,p
end --luautils.next_field



--returns the variable, OR, the string "nil" if the variable is nil
--space saver in some circumstances
--********************************
function luautils.var_or_nil(var)
	if var==nil then return "nil"
	else return var
	end --if
end --var_or_nil



--does string math
--uses sandbox, math. functions are allowed.  
--vars array is optional, if you pass in an array of variables and values they will be substituted before calculation
--********************************
function luautils.string_math(str,vars)
	--minetest.log("=====string_math->begin str="..str)
	if vars~=nil then --substitue variables
		--minetest.log("string_math->vars~=nil")
		for k,v in pairs(vars) do
			str=string.gsub(str,k,v)
			--minetest.log("string_math->k="..k.." v="..v.." str="..str) 
		end --for  
	end --if  
	--sandbox for security (do not allow arbitrary lua code execution)  
	local env = {loadstring=loadstring, math = {
		abs = math.abs,
		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan2,
		ceil = math.ceil,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		fmod = math.fmod,
		frexp = math.frexp,
		huge = math.huge,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		modf = math.modf,
		pi = math.pi,
		pow = math.pow,
		rad = math.rad,
		random = math.random,
		sin = math.sin,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tan = math.tan,
		tanh = math.tanh,
		}}    
	--minetest.log(">>>string_math-> before str="..str)
	local f=function() return loadstring("return "..str.."+0")() end

	setfenv(f,env)
	local rslt=f()
	--minetest.log(">>>string_math rslt="..luautils.var_or_nil(rslt))  
	
	return rslt
end  --string_math



--pass in a maxp and a minp and this returns a tabel with the SIZE of the box
--(so that x=length of x side, y=length of y side, and z=length of z size
--********************************
function luautils.box_size(minp,maxp)
	local siz={}
	--doing it in an ipairs loop like this means this will work for 2, 3, or 4, or any dimensional boxes
	for k,v in pairs(minp) do 
	  siz[k]=maxp[k]-minp[k]+1
	  --minetest.log("box_size-> k="..k.." v="..v.." maxp[k]="..maxp[k].." minp[k]="..minp[k].." siz[k]="..siz[k])
	end
	return siz
end --box_size


--this is the same as box_size, except it returns the z value in the y field
--this is useful for when you are trying to get 2D noise size, you want to drop 
--the real y param and replace with z  (OH how I wish minetest used z for vertical coord!)
--********************************
function luautils.box_sizexz(minp,maxp)
	local siz=luautils.box_size(minp,maxp)
	siz.y=siz.z
	siz.z=nil
	return siz
end --box_size



--for debugging purposes, this prints out a table in a readable format.
--not my code, copied from here:
--https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
--its recursive, so could potential run out of memory on large nested tables
--********************************
function luautils.log_table(t, s)
	if t==nil then minetest.log((s or '')..' = nil')
	else
		for k, v in pairs(t) do
			local kfmt = '["' .. tostring(k) ..'"]'
			if type(k) ~= 'string' then
				kfmt = '[' .. k .. ']'
			end
			local vfmt = '"'.. tostring(v) ..'"'
			if type(v) == 'table' then
				luautils.log_table(v, (s or '')..kfmt)
			else
				if type(v) ~= 'string' then
					vfmt = tostring(v)
				end
				minetest.log(type(t)..(s or '')..kfmt..' = '..vfmt)
			end --if type(v)==table
		end --for k,v
	end --if t==nil
end--table_print



--turns x,z coords into a flat nixz index
--proof of algorithm:  ( minp={50,25}, chunk_size={3,3} )
--  z   x   nixz   (z-minp.z)*chunk_size.x+(x-minp.x+1)= nixz
--[50][25] = 1     (50-50)   *3           +(25-25   +1)= 1
--[50][26] = 2     (50-50)   *3           +(26-25   +1)= 2
--[50][27] = 3     (50-50)   *3           +(27-25   +1)= 3
--[51][25] = 4     (51-50)   *3           +(25-25   +1)= 4
--[51][26] = 5     (51-50)   *3           +(26-25   +1)= 5
--[51][27] = 6     (51-50)   *3           +(27-25   +1)= 6
--[52][25] = 7     (52-50)   *3           +(25-25   +1)= 7
--[52][26] = 8     (52-50)   *3           +(26-25   +1)= 8
--[52][27] = 9     (52-50)   *3           +(27-25   +1)= 9
--********************************
function luautils.xzcoords_to_flat(x,z, minp, chunk_size)
	--return (z-1)*chunk_size.x+x
	return (z-minp.z)*chunk_size.x+(x-minp.x+1)
end



--just changes a two line entry into a one line entry
--********************************
function luautils.place_node(x,y,z, area, data, node)
	local vi = area:index(x, y, z)
	data[vi] = node
end --place node


--This gives an UPPER BOUND for noise (not counting offset and scale)
--And it may be an accurate upper bound, BUT, probably because of 
--combinatorial effects, the more octaves you have, the further the
--noise max from testing is from the noise max returned by this function.
--our guess is that this is because to reach the ACTUAL max with say, 
--six octaves, you would have to hit max value (1) on all 6 noises.  
--its like rolling 6 dice.  The range is still the same, and the average
--is still the same, but distribution is drastically different and the
--odds of getting the maximum or minimum values is very small compared to
--values in the middle of the range.
--********************************
function luautils.get_noise_max_raw(noise)
	local nm=(noise.persist^noise.octaves-1)/(noise.persist-1)
	return nm
end --get_noise_max_raw



