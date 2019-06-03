# tg_mesas

This terrain generator creates mesas surrounded by deep chasms, each with a single biome on top.

Well, actually, there are exceptions to the single biome thing.  The seed used in the bm_mesa_biomes
function is the chunk_seed.  So, when mesa's cross chunk boundries, the biomes change.  I was going
to fix this, but then I decided I kind of liked the way it looked.  I haven't made up my mind yet.

it is designed to work with a biomefunc that uses random, like bm_mesas_biomes, to select one biome 
per mesa.

It does not currently take any extra parameters (although that might change)

below is an example of a realms.conf entry that calls this generator

    tg_mesas         |-33000| 20000|-33000|    -1| 21500| 33000|   21000|bm_mesas_biomes     |

