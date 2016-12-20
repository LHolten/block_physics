-- mods/modname/init.lua
-- =====================
-- See LICENSE.txt for licensing and README.md for other information.

block_physics = {}


local modpath = minetest.get_modpath("block_physics")
local modnames = minetest.get_modnames()

-- Load files

dofile(modpath .. "/functions.lua")

if (minetest.get_modpath("default")) then
	dofile(modpath .. "/nodes.lua")
end






--[[
minetest.register_abm({
	nodenames = {"group:shear","group:weight","group:compressive","group:tensile"},
	neighbors = {"air"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		
	end,
})
--]]
