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
		 return valse
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



--********************************
function luautils.point_in_box(point, minp,maxp)
	return luautils.check_overlap(point,point, minp,maxp)
end --point_in_box



--********************************
function luautils.xyz_in_box(x,y,z, minp,maxp)
	return luautils.point_in_box({x=x,y=y,z=z}, minp,maxp)
end --xyz_in_box


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
	return {x=luautils.round_digits(pos.x,digits),y=luautils.round_digits(pos.y,digits),
					z=luautils.round_digits(pos.z,digits)}
end --round_digits_pos


--lua does not allow overloading functions, so you can not specify func(one,two) and func(one,two,three)
--but lua parameters are all optional, so you can just define as func(one,two,three) and then inside
--the function check to see if three==nil and respond accordingly.   This is used for rounddigits below


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
		if rounddigits ~= nil then pos=luautils.round_pos(posin,rounddigits) end
		return "("..pos.x..sep..pos.y..sep..pos.z..")"
	end --if
end --pos_to_str



function luautils.is_ground_content(pos)
	if minetest.registered_nodes[minetest.get_node(pos).name].is_ground_content then return true
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
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end


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




