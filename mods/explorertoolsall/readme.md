Adds the ability for every pick, axe, and shovel in the game to not only dig on a left click, but place whatever item is in the inventory slot immediately to its right on a right click.

**Explorer Tools All Version 1.1**

Have you ever been frustrated when digging a mine or exploring a cavern because you have to dig, dig, dig, then swap the active inventory item to a torch, place a torch, swap the active inventory item back to your pick, and repeat?  Did you ever wish that you could just place a torch (or a block of stone or glass) with a right click while still wielding your pick, axe, or shovel?  If so, then this mod is for you!

With this mod, when wielding any pick, axe or shovel, if you right click, it does a "place" using the item directly to the right in the players inventory.  So, for example, if your inventory slots looked like this:

![alt text](http://i60.tinypic.com/11huw7k.png "image")

Then a left click with the pick would dig, but point the pick at the wall and right click, and it will place a torch from your second inventory slot on the wall.  No need to switch active inventory items at all.  Left click to dig with the pick, right click to place a torch.

And it doesn't have to be a torch.  Perhaps you are building a project that requires digging out stone and replacing it with glass.  Just put your stack of glass in the inventory slot next to the pick, dig the stone out with a left click, place the glass with a right click.  The axe and the shovel work the same way.

**Credits:**<p>
My son helped me with the idea, the programming, and the textures.  Thanks to kaeza for sample code of how to get the inventory item to the right of the tool, and to PilzAdam and Stu for answering my questions about how the uses field works.  The original version only gave the right click onplace ability to 3 specially crafted tools. 4aiman came up with the way to apply this on_place function to every pick, axe, and shovel in the game.  Explorer Tools All is just a slightly modified version of his code.

**Dependencies:**<p>
Soft depends on default.  If you have any tool mods that you want to have this ability, they should be added as soft dependencies to this mod so that they will be loaded before this mod.  Let me know about any mods you'd like added as soft dependencies to the basic mod and I'll put them in there.  (Or just do a pull request in github)

**Incompatibilities:**<p>
Do not use with Inventory Tweak mod, on right click your tool will disappear!

**License:** gplv3

**To browse source:**<p>
[https://github.com/Kilarin/explorertoolsall](https://github.com/Kilarin/explorertoolsall)

**Download:**<p>
[https://github.com/Kilarin/explorertoolsall/archive/master.zip](https://github.com/Kilarin/explorertoolsall/archive/master.zip)

**To install:**<p>
Simply unzip the file into your mods folder, and rename the folder to explorertoolsall<p>
OR, simply install it directly from minetest using the online mod repository.

**Mod Database:**<p>
If you use this mod, please consider reviewing it on the MineTest Mod Database.<p>
[https://forum.minetest.net/mmdb/mod/explorertoolsall/](https://forum.minetest.net/mmdb/mod/explorertoolsall/)<p>

**Change Log:**<p>
1.1 pull from kaeza Force-update stack instead of relying on success indicator.
    This eliminates a problem where using explorertoolsall and an itemframe would
    allow you to duplicate items.  And, to my surprise, it does not seem to cause
    you to lose items when you can't place the stack.
1.0 initial release
