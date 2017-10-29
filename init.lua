-- mods/block_physics/init.lua
-- =====================
-- See LICENSE.txt for licensing and README.md for other information.

block_physics = {}


local modpath = minetest.get_modpath("block_physics")
local modnames = minetest.get_modnames()

-- Load files

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/core.lua")
dofile(modpath .. "/handlers.lua")

if (minetest.get_modpath("default")) then
	dofile(modpath .. "/nodes.lua")
	dofile(modpath .. "/decoration_nodes.lua")
end

if (minetest.get_modpath("stairs")) then
	dofile(modpath .. "/stairs.lua")
end


minetest.register_craftitem("block_physics:param2_check", {
	description = "get param2 of node",
	inventory_image = "param2_check.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			minetest.chat_send_player(user.get_player_name(user), tostring(node.param2))
		end
		if block_physics.isProcessing then
			minetest.chat_send_player(user.get_player_name(user), "processing...")
		end
		return nil
	end
})
minetest.register_craftitem("block_physics:param1_check", {
	description = "get param1 of node",
	inventory_image = "param1_check.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			minetest.chat_send_player(user.get_player_name(user), tostring(node.param1))
		end
		if block_physics.isProcessing then
			minetest.chat_send_player(user.get_player_name(user), "processing...")
		end
		return nil
	end
})






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
