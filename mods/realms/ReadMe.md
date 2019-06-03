#Realms
**version 0.2**

This mod lets you add different lua landscape generators and control exactly where they run based
on coords and other parameters provided in the realms.conf file

## License
My stuff is code=MIT License, images=CC0.  Some code and images copied from others.  Please see [license.txt](license.txt) for details.

## What it does:
When I first started working on the [Fractured](https://forum.minetest.net/viewtopic.php?f=50&t=11346) game, my vision was of a world with multiple layers, or "realms" going both up and down through the minetest 64k by 64k cube.  Like this:

![fractured realms diagram](https://i.imgur.com/jmvHzcA.jpg)  (sorry, art is NOT my strong point)

When I saw Beerholders multi\_map mod, I got all excited, because I thought it would do what I wanted!  But once I started looking at it I realized that it didn't allow the kind of control over where the realms *were* that I was looking for.  I strongly suspect that multi_map is technically superior to this mod, so be sure to take a look at it.  But if you need more precise control over the map and biomes, then Realms is an attempt to give you that.

The purpose of Realms is to allow the user to control multiple landscape and biome generators with exact precision.  Specifying exactly what generator should run where, and what biomes should be active, etc.

It is perhaps best to explain with an example.  First, let me explain the following naming conventions:

* tg\_\* = terrain generator, a program that generates terrain (without biomes)
* tf\_\* = terrain function, a function that generates terrain designed be called by another generator
* bd\_\* = biome definition, a file containing biome definitions
* bm\_\* = biome map, a file that defines a group of biomes (from various bd\_\* files) and how they should be mapped to the terrain (biome maps have biome functions built in)
* bf\_\* = biome function, a function dealing with biomes designed to be called by another generator


Here is an excerpt from the example [realms.conf](realms.conf) file:

    RMG Name         :min x :min y :min z :max x : max y: max z:sealevel:biome func          :other parms
    -----------------:------:------:------:------:------:------:--------:--------------------:----------
    tg_layer_barrier |-33000|  4900|-33000| 33000|  4999| 33000|       0|                    |bedrock
    tg_2dMap         |     0|  5000|-33000| 33000|  6500| 33000|    6000|bm_default_biomes   |sea_percent=20|canyons
    tg_2dMap         |-33000|  5000|-33000|    -1|  6500| 33000|    6000|bm_mixed_biomes     |sea_percent=20|canyons|extremes=4
    tg_caves         |-33000|  5000|-33000| 33000|  6000| 33000|    6000|                    |

What this means is not as confusing as it looks at first.  This is all setting up one realm.

A Realm Map Generator named `tg_layer_barrier` will run from y=4900 to y=499, the min and max x and z values are set so that it will run at that altitude anywhere on the map.  What `tg_layer_barrier` does is just create a layer of invisble invulnerable nodes to separate layers (thank you to Beerholder and his `multi_map` mod for this idea.)  You will notice that the parameter "bedrock" has been passed in the "other parms" field.  The "other parms" field can be used to pass parameters specific to a particular generator.  In this case, passing "bedrock" to `tg_layer_barrier` will cause it to generate a layer of invulnerable (but opaque) nodes as the very top layer of its area (in this case, at y=4999.)

The next entry is for `tg_2dMap`, this is a map generator based on 2d noise.  It's pretty simple actually, I'm new at this.  This generator will operate from min(0,5000,-33000) to max(33000,6500,33000).  This means it will be called from y=5000 up to y=6500, but only on the x+ (east) side of the world.  sealevel is set to 6000, which tells `tg_2dMap` where to base the surface of this realm.  And we passed it a biome function of `bm_default_biomes`.  This biome map reproduces most of the biomes from default using a (sort of) voronoi diagram to determine biome placement.  In the "other parms" field we tell `tg_2dMap` that `sea_percent=20`, so it will adjust the map so that about 20% of the world will be sea.  And we also passed "canyons" as a parameter, so it will create canyons in the map.  (my canyon code stinks, please help me improve it!)

Under that, we call `tg_2dMap` again, but this time, even though it operates at the exact same altitude, it will operate on the x- (west) side of the world.  And we pass a different biome map, so the biomes will be different on the west side of the world from the east in this realm.

Finally, we give the west side of the world the same sea percent as the east, and canyons, but we ALSO pass `extremes=4` which will cause `tg_2d_map` to generate more extremes, higher mountains, deeper valleys, and flatter plains.

The last line sets up a map generator called `tg_caves`.  You will notice that it covers the whole world (not divided between east and west) from altitude y=5000 to y=6000 (sea level for this realm).  You will also see that it *overlaps* the previous two `tg_2dMap` landscape generators.  Realms map generators are always called in order, and so `tg_caves` will run after the 2dMap generators have filled that region with stone, and will carve out caves in it.

The next realm can be defined wherever you want it to be, can run the same or completely different map generators, and combine them with whatever biome maps you wish.  With *realms*, you have complete control over your lua map generators.

---

So, what if you don't want to use one of the rather primitive map generators I have included with realms?  No problem, it should be very simple to adapt almost any lua map generator to work with realms.  You just have to make the following adjustments:

* make your mod dependent upon realms
* in your mod, instead of doing a `register_on_generated`, do a `realms.register_mapgen(mapgen_name, mapgen_function)`
* your mapgen function will need some slight modification:
  * it should expect a table _parms_ to be passed in.  This table will contain (among other parameters)
  * parms.isect\_minp and isect\_maxp, these are the min and max of where your defined realm has intersected the map.  THESE are the points your function should operate within.  Note that one nice benefit of this is that your function does NOT need to check if it is in the right region and exit if not.  realms takes care of that and only calls your function when the chunk actually intersects the defined realm.
  * parms.sealevel, which your function should use to establish where the surface of this realm is.
  * parms.area and parms.data, update THESE, do NOT create your own voxel manipulator.  Realms creates area and data for every chunk, passes it to each generator that intersects with that chunk, and only updates it to the map after all generators have completed running.  This improves speed and efficency.
  * anything you want passed on to OTHER realms generators being called on the same chunk should be put in parms.shared

I have attempted to document the individual generators included in realms so that they will be easy to use.

## Biome notes

Realms tries to implement biomes in a way that will look very familiar to people using the built in lua api `register_biome` function.  But with some important differences.

First you will notice that I am trying to separate terrain generation from biome generation.  This allows you to mix and match the two however you wish.  Just for example, suppose you want one level of the world to be mostly desert.  You've already got a nice desert biome defined in `bd_default_biomes`, so you create a new biome map, and set it to use the desert biome you want, and a few other biomes, but set the map so that the desert biome will cover 80% of the surface.  You can do this without having to define a new biome, and without affecting the other levels that use the desert biome for only a small percentage of the surface.

Biome Definition (bd\_\*) files just contain the definitions for the biomes.  These are standard lua tables that look mostly like the regular definitions used for the `register_biome` function, except for the addition of the decoration table. (more on that later)  Do NOT bother putting heat/humidity points in biomes here, that is handled in the biome map.

Biome Map (bm\_\*) files take a selection of biomes from biome definition files and say how to map them to the world.  This allows you to mix and match biomes for different realms.  So, for example, the biome map `bm_mixed_biomes` combines biomes from `bd_basic_biomes` (a group of ordinary biomes) and `bd_odd_biomes` (a group of unusual biomes) and maps them to the world using a simple matrix method.  There are currently 2 methods of mapping built in.

VORONOI, which is an approximated VORONOI diagram.  I use the approximation to make calculations faster.  When using this method you need to specify a heat and humidity point for each biome.  The drawback of using VORONOI is that its not easy to estimate or control exactly how common any particular biome is going to be this way.

MATRIX, which is super simple.  You just create a two dimensional matrix and put the biomes into the matrix.  You can repeat a biome, you can put them in whatever order/relation you want.  It doesn't create a "natural" of a mixing as the VORONOI diagram, but you will know EXACTLY how often any particular biome is likely to show up.  BUT, MATRIX does not deal with altitude restrictions on biomes as easily as VORONOI.  So I've added an extra field to the biome definition for MATRIX mode: "alternates".  If you are using MATRIX mode, and have a biome with altitude restrictions, include a list of alternate biomes in the alternate parameter and the generic generator will automatically search through that list for valid replacements if a chosen biome is outside of its altitude restrictions.

I also have one biome map that uses RANDOM as its distribution method, but it is customized and only useful in a very limited situation.

Now, back to that decoration table.  The regular minetest api uses `register_decoration` to set up decorations.  Decorations are associated primarily with a soil type, and you can't pass functions.  This is where my biome setup diverges from the standard.  I link decorations directly to the biome definiton.  Here is an example biome definition from [bd_basic_biomes](bd_basic_biomes):

    realms.register_biome({
    		name="basic_warm",
    		node_top="default:dirt_with_grass",
    		depth_top = 1,
    		node_filler="default:dirt",
    		depth_filler = 4,
    		y_max = upper_limit,
    		y_min = 1,
    		alternates={"basic_shore","basic_ocean"},
    		dec={
    			{chance=0.25, func=bd_basic_biomes.gen_appletree},
    			{chance=0.25,schematic=defaultschematics.."/apple_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
    			{chance=0.1,schematic=defaultschematics.."/aspen_tree.mts", offset_x=-3,offset_z=-3,offset_y=-1},
    			{chance=0.05,schematic=defaultschematics.."/aspen_log.mts"},
    			{chance=0.05,schematic=defaultschematics.."/bush.mts", offset_x=-1,offset_z=-1},
    			{chance=5, node="default:grass_1"},
    			{chance=5, node="default:grass_2"},
    			{chance=5, node="default:grass_3"},
    			{chance=5, node="default:grass_4"},
    			{chance=5, node="default:grass_5"},
    			}
    		})

You will notice the dec (decoration) table included.  Each item in the table has a chance, that is the percentage chance of this decoration showing up.  So 5 means that, on average, 5 out of every 100 nodes in this biome will have the decoration.  And 0.25 means there will be only 2.5 of this decoration per 1000 nodes (100x100 node area)  I fully intend to implement a noise option here as well, like regular minetest decorations use, but haven't gotten to it yet.

There are three kinds of decorations.

* func (function) which allows you to call a function that generates or places whatever you want.
* schematic, to which you can pass a mts file, OR a lua schematic table.  You will note that you can also pass offsets.  I TRIED to get the regular schematic center_x etc parameters to work, but they just didn't seem to be doing anything, so I implemented this.  Any help getting the built in params to work would be much appreciated.
* node, to which you can also pass height and height\_max, as in this cactus example: `{chance=0.1,node="default:cactus",height=2,height_max=5},`  This is handled just like the regular decoration version, so the catctus will be between 2 and 5 nodes high.

I LIKE having the decorations associated directly with the biomes.  But I'm willing to listen if someone wants to try and convince me it would be better to implement them the same way minetest does.

But, perhaps the most important point of all about this biome implementation, is that this is the way most of the map generators I've included with realms are implmenting biomes.  But it is NOT required.  If you wish to implement biomes using a completely customized system, realms is perfectly happy with that.  Just tell it what generators to run where, and it will do fine.

If you want to see realms in action, it is used in the current version of [Fractured](https://forum.minetest.net/viewtopic.php?f=50&t=11346)

##To Do
Realms works, but it is mainly a proof of concept right now.  It needs a lot of work, and since I don't know what I'm doing, I could certainly use some help.  These are SOME of the major issues I see that still need working on

* I need a map generator that uses 3d noise.  I haven't yet figured out how to use 3d noise to create natural looking terrain.  And HOW do you define the surface so that the biome functions know where to decorate?
* We need 3d floating islands.  (related to above)
* biome decorations should probably implement x and z min and max
* biome decorations need a noise option
* biomes need more decorations 
* caves need to be much better
* ore!  I haven't even tried to get ore generating in these above ground realms.  I THINK there is a way to get minetest to do this without requiring lua?
* cliffs/canyons needs improved.  Especially canyons, my canyon code is just sort of a place holder.  Now that I've been working on this for a while, I THINK that the proper way to implement canyons/rivers is probably using the intersection of two different 2d noises?  Perhaps with a third layer of noise to limit which intersections get mapped?
* how to do rivers/pools above sea level?
* I need to figure out how to implement the regular schematic flags, especially when passing mts files?
* realms needs to implement translation consistently (hardly doing it at all right now)
* the chasm walls in tg_mesas.lua and bm_shattered_biomes.lua need to have some more natural dropoff.  Also, decorations for chasm floor in progress.
* documentation still needs work
* there is a strange glitch where sometimes an area of recently generated terrain is suddenly dusted with snow.  I'm not certain if this is something minetest is doing or a problem in my code.







