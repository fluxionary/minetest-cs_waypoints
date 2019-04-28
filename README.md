minetest CSM which implements waypoints on top of the /teleport server side command.

= requirements =

tested with minetest 0.4.17 and 5.0.

in 5.0, the server *must* have send_chat_message enabled, which is not the default.

this mod will *only* work if your account has the "teleport" privilege. it will *not* let ordinary users teleport, unless that is a default privilege.

= installation =

make sure the mod is installed at ~/.minetest/clientmods/cs_waypoints

make sure ~/.minetest/clientmods/mods.conf exists and contains:

load_mod_cs_waypoints = true

= usage =

* to set a waypoint at your current location, type .wp_s NAME_OF_WAYPOINT
* to remove a waypoint, type .wp_rm NAME_OF_WAYPOINT
* to list waypoints, type .wp_ls
* to teleport to a waypoint, type .tw NAME_OF_WAYPOINT
* to teleport another player to a waypoint, type .tw PLAYER NAME_OF_WAYPOINT
* to teleport to a random location, type .tr
* to teleport to a random location at a particular elevation (y value), type .tr ELEVATION
