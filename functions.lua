--local nonSolids = {["air"] = true, ["fire:basic_flame"] = true, ["default:water_source"] = true, ["default:water_flowing"] = true, ["default:river_water_source"] = true, ["default:river_water_flowing"] = true, ["default:lava_source"] = true, ["default:lava_flowing"] = true}


block_physics.check_type = function(name)
	if (name == "air") then return "non_solid" end
	
	if (minetest.registered_nodes[name].paramtype2 == "physics") then return "physical" end
	
	if (minetest.registered_nodes[name].groups["deco"]) then return "deco" end
	
	if (minetest.registered_nodes[name].groups["attached_node"]) then return "attached_node" end
	
	if (minetest.registered_nodes[name].paramtype2 == "wallmounted") then return "attached_node" end
	
	if (minetest.registered_nodes[name].groups["liquid"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flora"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flammable"] == 4) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["dig_immediate"] == 3) then return "non_solid" end
	
	return "solid"
end


--
-- Global callbacks
--

local function global_dignode(p, node)
	local nodetype = block_physics.check_type(node.name)
	
	if nodetype == "solid" or nodetype == "attached_node" then
		block_physics.add_neighbors(p)
	end
end

local function global_placenode(p, node)
	local nodetype = block_physics.check_type(node.name)
	
	if nodetype == "solid" or nodetype == "attached_node" then
		block_physics.add_single(p)
	end
end
minetest.register_on_dignode(global_dignode)
minetest.register_on_placenode(global_placenode)


function block_physics.add_physical( def)
	def.on_blast = function(pos, intensity)
		local node = minetest.get_node(pos)
		minetest.remove_node(pos)
		
		--add neighbors to the list
		block_physics.add_neighbors(pos)
		return minetest.get_node_drops(node.name, "")
	end
	
	local on_construct = def.on_construct
	def.on_construct = function(pos)
		block_physics.add_single(pos)
		
		if on_construct then
			on_construct(pos)
		end
	end
	
	local after_destruct = def.after_destruct
	def.after_destruct = function(pos, old_node)
		block_physics.add_neighbors(pos)
		
		if after_destruct then
			after_destruct(pos, old_node)
		end
	end
	
	def.paramtype2 = "physics"
	def.paramtype = "physics"
	
	return def
end

function block_physics.add_deco(def)
	def.on_blast = function(pos, intensity)
		local node = minetest.get_node(pos)
		minetest.remove_node(pos)
		
		--add neighbors to the list
		block_physics.add_neighbors(pos)
		return minetest.get_node_drops(node.name, "")
	end
	
	local on_construct = def.on_construct
	def.on_construct = function(pos)
		block_physics.add_single(pos)
		
		if on_construct then
			on_construct(pos)
		end
	end
	
	local after_destruct = def.after_destruct
	def.after_destruct = function(pos, old_node)
		block_physics.add_neighbors(pos)
		minetest.debug("deco updating")
		
		if after_destruct then
			after_destruct(pos, old_node)
		end
	end
	
	def.groups.deco = 1
	
	return def
end

function block_physics.drop_node(pos, node)
	local under = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local horizontalSides = {{x = pos.x - 1, y = pos.y, z = pos.z}, {x = pos.x + 1, y = pos.y, z = pos.z}, {x = pos.x, y = pos.y, z = pos.z - 1}, {x = pos.x, y = pos.y, z = pos.z + 1}}
	
	if (block_physics.check_type(under.name) ~= "non_solid") then
		-- block underneath is not air ->look for other directions to fall in
		for i, posn in pairs(horizontalSides) do
			local n = minetest.get_node(posn)
			local posm = {x = posn.x, y = posn.y - 1, z = posn.z}
			local m = minetest.get_node(posm)
			
			if ((block_physics.check_type(n.name) == "non_solid") and (block_physics.check_type(m.name) == "non_solid")) then
				minetest.set_node(pos, {name="air"})
				minetest.add_entity(posn, "__builtin:falling_node"):get_luaentity():set_node(node)
				return true -- block has fallen -> stop looking
			end
		end
	else
		--block underneath is air -> fall
		minetest.set_node(pos, {name="air"})
		minetest.add_entity(pos, "__builtin:falling_node"):get_luaentity():set_node(node)
		return true
	end
	return false
end