-- mods/modname/init.lua
-- =====================
-- See LICENSE.txt for licensing and README.md for other information.

block_physics = {}


local modpath = minetest.get_modpath("block_physics")

-- Load files

dofile(modpath .. "/nodes.lua")


local function update_single(pos, node)
	node = node or minetest.get_node_or_nil(pos)
	local shear = minetest.registered_nodes[node.name].groups["shear"] or 12
	local compressive = minetest.registered_nodes[node.name].groups["compressive"] or 10
	local weight = minetest.registered_nodes[node.name].groups["weight"] or 2
	local tensile = minetest.registered_nodes[node.name].groups["tensile"] or 6
	local nonSolids = {["air"] = true, ["fire:basic_flame"] = true, ["default:water_source"] = true, ["default:water_flowing"] = true, ["default:river_water_source"] = true, ["default:river_water_flowing"] = true, ["default:lava_source"] = true, ["default:lava_flowing"] = true}
	local returnvalue = false
	
	local force = node.param2
	
	
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
	elseif (not nonSolids[under.name]) then
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
	
	local newforce = math.max(underF, sideF, aboveF)
	if (force ~= newforce) then returnvalue = true end --something changed: check all surrounding blocks
	force = newforce
	
	if (force <= 0) then
		if (not nonSolids[under.name]) then
			for i,posn in pairs(underposes) do
				local n = minetest.get_node(posn)
				
				if (nonSolids[n.name]) then
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
	
	return returnvalue
end

local function update_physics(pos)
	local node = minetest.get_node_or_nil(pos)
	local neighbors = {{x = pos.x - 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z - 1},{x = pos.x + 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z + 1},{x = pos.x, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y + 1, z = pos.z}}
	
	if (minetest.registered_nodes[node.name].groups["weight"]) then
		if (update_single(pos, node)) then
			for i, posn in pairs(neighbors) do
				n = minetest.get_node_or_nil(posn)
				
				if minetest.registered_nodes[n.name].groups["weight"] then
					minetest.after(1, update_physics, posn)
				end
			end
		end
	else
		for i, posn in pairs(neighbors) do
			n = minetest.get_node_or_nil(posn)
			
			if minetest.registered_nodes[n.name].groups["weight"] then
				minetest.after(1, update_physics, posn)
			end
		end
	end
end

--
-- Global callbacks
--

local function on_placenode(p, node)
	if (minetest.registered_nodes[node.name].groups["weight"]) then
		minetest.after(0, update_physics, p)
	end
end
minetest.register_on_placenode(on_placenode)

local function on_dignode(p, node)
	minetest.after(0, update_physics, p)
end
minetest.register_on_dignode(on_dignode)

local function on_punchnode(p, node)
	if (minetest.registered_nodes[node.name].groups["weight"]) then
		minetest.after(0, update_physics, p)
	end
end
minetest.register_on_punchnode(on_punchnode)



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
