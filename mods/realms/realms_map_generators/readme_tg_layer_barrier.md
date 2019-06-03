#tg_layer_barrier

Layer Barrier creates a layer of invisble invulnerable nodes to separate layers (thank you to Beerholder and his `multi_map` mod for this idea.)  

Passing the parameter "bedrock" to `tg_layer_barrier` will cause it to generate a layer of invulnerable (but opaque) nodes as the very top layer of its area.  Very handy for creating a "bottom" to a realm in the sky.

below is an example of a realms.conf line that calls layer barrier

    tg_layer_barrier |-33000|  4900|-33000| 33000|  4999| 33000|       0|                    |bedrock
