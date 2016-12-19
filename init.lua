-- mods/modname/init.lua
-- =====================
-- See LICENSE.txt for licensing and README.md for other information.

block_physics = {}


local cobble = {cracky = 3, stone = 2, weight = 2, shear = 8, compressive = 14, tensile = 2}

minetest.register_node(":default:cobble", {
	description = "Cobblestone",
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	groups = cobble,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:desert_cobble", {
	description = "Desert Cobblestone",
	tiles = {"default_desert_cobble.png"},
	is_ground_content = false,
	groups = cobble,
	sounds = default.node_sound_stone_defaults(),
})

local mossycobble = {cracky = 3, stone = 1, weight = 2, shear = 8, compressive = 12, tensile = 2}

minetest.register_node(":default:mossycobble", {
	description = "Mossy Cobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	groups = mossycobble,
	sounds = default.node_sound_stone_defaults(),
})

local stonebrick = {cracky = 2, stone = 1, weight = 2, shear = 12, compressive = 20, tensile = 4}

minetest.register_node(":default:stonebrick", {
	description = "Stone Brick",
	tiles = {"default_stone_brick.png"},
	is_ground_content = false,
	groups = stonebrick,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:desert_stonebrick", {
	description = "Desert Stone Brick",
	tiles = {"default_desert_stone_brick.png"},
	is_ground_content = false,
	groups = stonebrick,
	sounds = default.node_sound_stone_defaults(),
})

local sandstonebrick = {cracky = 2, weight = 2, shear = 10, compressive = 18, tensile = 4}

minetest.register_node(":default:sandstonebrick", {
	description = "Sandstone Brick",
	tiles = {"default_sandstone_brick.png"},
	is_ground_content = false,
	groups = sandstonebrick,
	sounds = default.node_sound_stone_defaults(),
})

local obsidianbrick = {cracky = 1, level = 2, weight = 2, shear = 16, compressive = 24, tensile = 6}

minetest.register_node(":default:obsidianbrick", {
	description = "Obsidian Brick",
	tiles = {"default_obsidian_brick.png"},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	groups = obsidianbrick,
})

local wood = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, wood = 1, weight = 1, shear = 12, compressive = 8, tensile = 6}

minetest.register_node(":default:wood", {
	description = "Wooden Planks",
	tiles = {"default_wood.png"},
	is_ground_content = false,
	groups = wood,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(":default:acacia_wood", {
	description = "Acacia Wood Planks",
	tiles = {"default_acacia_wood.png"},
	is_ground_content = false,
	groups = wood,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(":default:aspen_wood", {
	description = "Aspen Wood Planks",
	tiles = {"default_aspen_wood.png"},
	is_ground_content = false,
	groups = wood,
	sounds = default.node_sound_wood_defaults(),
})

local coalblock = {cracky = 3, weight = 2, shear = 2, compressive = 20, tensile = 0}

minetest.register_node(":default:coalblock", {
	description = "Coal Block",
	tiles = {"default_coal_block.png"},
	is_ground_content = false,
	groups = coalblock,
	sounds = default.node_sound_stone_defaults(),
})

local metalblock = {cracky = 1, level = 2, weight = 3, shear = 24, compressive = 12, tensile = 30}

minetest.register_node(":default:steelblock", {
	description = "Steel Block",
	tiles = {"default_steel_block.png"},
	is_ground_content = false,
	groups = metalblock,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:copperblock", {
	description = "Copper Block",
	tiles = {"default_copper_block.png"},
	is_ground_content = false,
	groups = metalblock,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:bronzeblock", {
	description = "Bronze Block",
	tiles = {"default_bronze_block.png"},
	is_ground_content = false,
	groups = metalblock,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:mese", {
	description = "Mese Block",
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	groups = metalblock,
	sounds = default.node_sound_stone_defaults(),
	light_source = 3,
})

local goldblock = {cracky = 1, weight = 3, shear = 12, compressive = 6, tensile = 12}

minetest.register_node(":default:goldblock", {
	description = "Gold Block",
	tiles = {"default_gold_block.png"},
	is_ground_content = false,
	groups = goldblock,
	sounds = default.node_sound_stone_defaults(),
})

local diamondblock = {cracky = 1, level = 3, weight = 3, shear = 30, compressive = 15, tensile = 30}

minetest.register_node(":default:diamondblock", {
	description = "Diamond Block",
	tiles = {"default_diamond_block.png"},
	is_ground_content = false,
	groups = diamondblock,
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_abm({
	nodenames = {"group:shear","group:weight","group:compressive","group:tensile"},
	neighbors = {"air"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local shear = minetest.registered_nodes[node.name].groups["shear"] or 12
		local compressive = minetest.registered_nodes[node.name].groups["compressive"] or 10
		local weight = minetest.registered_nodes[node.name].groups["weight"] or 2
		local tensile = minetest.registered_nodes[node.name].groups["tensile"] or 6
		local nonBlocks = {air = true}
		
		local force = 0
		
		
		local poses = {{x = pos.x - 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z - 1},{x = pos.x + 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z + 1}}
		local underposes = {{x = pos.x - 1, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y - 1, z = pos.z - 1},{x = pos.x + 1, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y - 1, z = pos.z + 1}}
		local maxy, miny, m = 0, 16, 0
		
		--check all sides for nodes in group shear and calculate there max and min
		
		for i,posn in pairs(poses) do
			local n = minetest.get_node(posn)
			
			if (minetest.registered_nodes[n.name].groups["shear"]) then
				local f = n.param2
				
				m = m + 1
				miny = math.min(f, miny)
				maxy = math.max(f, maxy)
			end
		end
		
		--set varibles for force
		
		local under = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
		local above = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
		local sideF = 0
		local underF = 0
		local aboveF = 0
		
		--calc under force
		
		if (minetest.registered_nodes[under.name].groups["compressive"]) then
			underF = math.min(under.param2 - weight, compressive)
		elseif (under.name ~= "air") then
			underF = compressive
		end
		
		--calc above force
		
		if (minetest.registered_nodes[above.name].groups["tensile"]) then
			aboveF = math.min(above.param2 - weight, tensile)
		end
		
		--calc side forces
		
		if (m ~= 0) then
			sideF = math.min(maxy - weight * 2, shear)
		end
		
		force = math.max(underF, sideF, aboveF)
		
		if (force <= 0) then
			if (under.name ~= "air") then
				for i,posn in pairs(underposes) do
					local n = minetest.get_node(posn)
					
					if (n.name == "air") then
						minetest.set_node(pos, {name="air"})
						minetest.add_entity(posn, "__builtin:falling_node"):get_luaentity():set_node(node)
						break
					end
				end
			else
				minetest.set_node(pos, {name="air"})
				minetest.add_entity(pos, "__builtin:falling_node"):get_luaentity():set_node(node)
			end
		else
			minetest.set_node(pos, {name=node.name, param2=force})
		end
	end,
})

