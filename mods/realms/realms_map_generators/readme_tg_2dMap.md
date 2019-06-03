# tg_2dMap  (Terrain Generator)
This Terrain Generator uses 2d Noise to generate Terrain.  Its not great, but it can make some interesting landscapes

possible paramaters:

`tg_2dMap` takes the standard realms paramters, plus the following:


* `height_base=#`
 * The `height_base` is the base value the noise manipulates to generate the terrain, so higher 
   values generate taller and deeper features.  It defaults to 30 if you do not include it in 
   realms.conf
* `sea_percent=#`
  * This sets aproximately what percentage of the world will be below sea level.  The landscape 
    is actually shifted up (or down) to accomplish this.  It defaults to 25% if you do not include 
    it in realms.conf
* extremes  or extremes=#
  * this turns on (and optionaly sets the multiplier for) extremes in the terrain.  It creates 
    regions of tall mountains, deep valleys, and flatter plains.  The value defaults to 4 if you just
    set it as a flag |extremes| but you can specify a value like |extremes=5|
    when extremes are on, the generator uses a second layer of 2d noise and the surface calculation
    is multiplied by extval*(`noise_ext`^2)
* canyons
  * passing this flag in realms.conf will cause to terrain generator to use another layer of
    2d noise to generate "canyons"  They aren't very canyon like yet, but do create some
    interesting terrain
* noise:
  * `tg_2dMap` uses 3 different noises.<br/>
    noisetop (for determining the surface)<br/>
    noiseext (for making extremes, high mountains, plains, deep valleys and seas)<br/>
    noisecan (for making canyons, this doesnt work very well yet, but is at least interesting)<br/>
    you can change any of these by passing a paramater on the realms.conf line such as
    |noisetop=newnoise42| (this assumes, of course, that you have registered that noise somwhere)
* biome function: 
  * `tg_2dMap` can take a biome function in the biome collumn.
    The biome function is called after the surface is determined, and is passed in parms.share.surface
    it is assumed that the biome function has been registered with `register_mapfunc()` and will return 
    (in parms.share) surface[z][x].biome<br/> 
    important elements expected to be in the biome table are:<br/>
      `node_top` = what node to use for the surface of the biome<br/>
      `depth_top` = how deep the top layer is (usually 1).<br/>
      `node_filler` = what node to fill in under the surface (usually dirt)<br/>
      `depth_filler` = how deep should the filler be<br/>
      `node_water_top` = only specify if you want something besides water (like ice)<br/>
      `depth_water_top` = how deep should the `node_water_top` be<br/>
      `node_dust` = specify if you want something (like snow) on top of the surface<br/>
      `decorate` = the function that will place decorations.  Usually this is not defined in the biome
      and register_biome() sets it to realms.decorate which works for all biomes in standard 
      realms format
  * if the biome function sets `parms.share.make_ocean_sand` to true, then `tg_2dMap` will default all
    areas under sealevel to the `realms.undefined_underwater_biome` (sand)  (helps when setting up simple biomes)
  
below is an example of a realms.conf line defining a realm using `tg_2dMap`
  
    RMG Name         :min x :min y :min z :max x : max y: max z:sealevel:biome func       :other parms
    -----------------:------:------:------:------:------:------:--------:-----------------:---------- 
    tg_2dMap         |-33000| 15000|-33000| 33000| 16500| 33000|   16000|bm_default_biomes|height_base=60|sea_percent=35|extremes=5|canyons


