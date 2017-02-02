--local nonSolids = {["air"] = true, ["fire:basic_flame"] = true, ["default:water_source"] = true, ["default:water_flowing"] = true, ["default:river_water_source"] = true, ["default:river_water_flowing"] = true, ["default:lava_source"] = true, ["default:lava_flowing"] = true}


local function check_type(name)
	if (name == "air") then return "non_solid" end
	
	if (minetest.registered_nodes[name].paramtype2 == "physics") then return "physical" end
	
	if (minetest.registered_nodes[name].groups["deco"]) then return "deco" end
	
	if (minetest.registered_nodes[name].groups["attached_node"]) then return "attached_node" end
	
	if (minetest.registered_nodes[name].groups["liquid"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flora"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flammable"] == 4) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["dig_immediate"] == 3) then return "non_solid" end
	
	return "solid"
end



local function update_single(pos, node)
	local node = node or minetest.get_node_or_nil(pos)
	if (check_type(node.name) ~= "physical") then return false end

	
	local shear = minetest.registered_nodes[node.name].groups["shear"] or 12
	local compressive = minetest.registered_nodes[node.name].groups["compressive"] or 10
	local weight = minetest.registered_nodes[node.name].groups["weight"] or 2
	local tensile = minetest.registered_nodes[node.name].groups["tensile"] or 6
	local returnvalue = false
	
	local force = node.param2
	local hanging = node.param1
	
		--set varibles for force
	
	local under = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local above = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
	local sideF = 0
	local sideH = 255
	local underF = 0
	local underH = 255
	local aboveF = 0
	local aboveH = 255
	local newforce
	local newhanging
	
	-- very important parameters
	
	local factor = 6
	local B = 4
	
	local horizontalSides = {{x = pos.x - 1, y = pos.y, z = pos.z}, {x = pos.x + 1, y = pos.y, z = pos.z}, {x = pos.x, y = pos.y, z = pos.z - 1}, {x = pos.x, y = pos.y, z = pos.z + 1}}
	local minusX = minetest.get_node(horizontalSides[1])
	local plusX = minetest.get_node(horizontalSides[2])
	local minusZ = minetest.get_node(horizontalSides[3])
	local plusZ = minetest.get_node(horizontalSides[4])
	

	if (check_type(minusX.name) == "physical" and check_type(plusX.name) == "physical") then
		B = B - 1
	end
	if (check_type(minusZ.name) == "physical" and check_type(plusZ.name) == "physical") then
		B = B - 1
	end
	if ((check_type(under.name) == "physical" or check_type(under.name) == "solid") and check_type(above.name) == "physical") then
		B = B - 1
	end
	
	--check all horizontal sides for nodes and calculate there minH and maxF
	for _, side in ipairs({minusX, plusX, minusZ, plusZ}) do
		if (check_type(side.name) == "physical") then
			local f = side.param2
			local h = side.param1
			
			sideH = math.min(h + B, sideH)
			sideF = math.max(math.min(f - weight * (h + B), shear * (factor - B)), sideF)
		end
	end
	
	--calc under force
	if (check_type(under.name) == "physical") then

		underF = math.min(under.param2 - weight * B, compressive * (factor - B))
		underH = B
		
	elseif (check_type(under.name) == "solid") then
		underF = compressive * (factor - B)
		underH = B
	end
	
	--calc above force
	
	if (check_type(above.name) == "physical") then
		aboveF = math.min(above.param2 - weight * B, tensile * (factor - B))
		aboveH = B
	end
	
	if underF / underH >= sideF / sideH and underF /underH >= aboveF / aboveH then
		newforce = underF
		newhanging = underH
	elseif sideF > aboveF then
		newforce = sideF
		newhanging = sideH
	else
		newforce = aboveF
		newhanging = aboveH
	end
	

	if (force ~= newforce or hanging ~= newhanging) then returnvalue = true end --this will make sure the block gets updated
	
	force = newforce
	hanging = newhanging
	
	
	if (force <= 0) then
		--this block is not supported properly -> try to fall
		if (check_type(under.name) ~= "non_solid") then
			-- block underneath is not air ->look for other directions to fall in
			for i, posn in pairs(horizontalSides) do
				local n = minetest.get_node(posn)
				local posm = {x = posn.x, y = posn.y - 1, z = posn.z}
				local m = minetest.get_node(posm)
				
				if ((check_type(n.name) == "non_solid") and (check_type(m.name) == "non_solid")) then
					minetest.set_node(pos, {name="air"})
					minetest.add_entity(posn, "__builtin:falling_node"):get_luaentity():set_node(node)
					break -- block has fallen -> stop looking
				end
			end
		else
			--block underneath is air -> fall
			minetest.set_node(pos, {name="air"})
			minetest.add_entity(pos, "__builtin:falling_node"):get_luaentity():set_node(node)
		end
	elseif returnvalue then
		--this block is supported properly and some value has changed -> update block
		minetest.set_node(pos, {name = node.name, param2 = force, param1 = hanging}) --this will trigger an update for the surrounding blocks
	end
	
	return returnvalue
end

local function update_deco(pos, node)
	local node = node or minetest.get_node_or_nil(pos)
	local under = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local sides = {{x = pos.x - 1, y = pos.y, z = pos.z}, {x = pos.x + 1, y = pos.y, z = pos.z}, {x = pos.x, y = pos.y, z = pos.z - 1}, {x = pos.x, y = pos.y, z = pos.z + 1}}
	local neighbors = {{x = pos.x - 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z - 1},{x = pos.x + 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z + 1},{x = pos.x, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y + 1, z = pos.z}}
	local m = 0
	
	for i, posn in pairs(neighbors) do
		local nodetype = check_type(minetest.get_node(posn).name)
		if (nodetype == "physical" or nodetype == "solid") then
			m = m + 1
		end
	end
	
	if (m < minetest.registered_nodes[node.name].groups["deco"]) then
		--this block is not supported properly -> try to fall
		if (check_type(under.name) ~= "non_solid") then
			-- block underneath is not air ->look for other directions to fall in
			for i, posn in pairs(sides) do
				local n = minetest.get_node(posn)
				local posm = {x = posn.x, y = posn.y - 1, z = posn.z}
				local m = minetest.get_node(posm)
				
				if ((check_type(n.name) == "non_solid") and (check_type(m.name) == "non_solid")) then
					minetest.set_node(pos, {name="air"})
					minetest.add_entity(posn, "__builtin:falling_node"):get_luaentity():set_node(node)
					break -- block has fallen -> stop looking
				end
			end
		else
			--block underneath is air -> fall
			minetest.set_node(pos, {name="air"})
			minetest.add_entity(pos, "__builtin:falling_node"):get_luaentity():set_node(node)
		end
	end
end

local function check_attached_node(p, n)
	local def = minetest.registered_nodes[n.name]
	local d = {x = 0, y = 0, z = 0}
	if def.paramtype2 == "wallmounted" then
		d = minetest.wallmounted_to_dir(n.param2)
	else
		d.y = -1
	end
	local p2 = vector.add(p, d)
	local nn = minetest.get_node(p2).name
	local def2 = minetest.registered_nodes[nn]
	if def2 and not def2.walkable then
		return false
	end
	return true
end

local function drop_attached_node(p)
	local nn = minetest.get_node(p).name
	minetest.remove_node(p)
	for _, item in ipairs(minetest.get_node_drops(nn, "")) do
		local pos = {
			x = p.x + math.random()/2 - 0.25,
			y = p.y + math.random()/2 - 0.25,
			z = p.z + math.random()/2 - 0.25,
		}
		minetest.add_item(pos, item)
	end
end

local function update_attached(pos, node)
	node = node or minetest.get_node(pos)
	if not check_attached_node(pos, node) then
		drop_attached_node(pos)
	end
end

local time_table = {}
-- table containing all the nodes that need an update
-- index is the position of the node

function block_physics.add_neighbors(pos)
	local neighbors = {{x = pos.x - 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z - 1},{x = pos.x + 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z + 1},{x = pos.x, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y + 1, z = pos.z}}
	
	for i, posn in pairs(neighbors) do
		local str = minetest.pos_to_string(posn)
		
		time_table[str] = true
		--minetest.debug("added "..str)
	end
end

function block_physics.add_single(pos)
	local str = minetest.pos_to_string(pos)
	time_table[str] = true
end

--
-- handling machine
--

local function thread()
	local next = next
	local start = os.clock()
	
	while true do
		--minetest.debug("test")
		if ((os.clock() - start) * 1000 > 0.1) then
			--has been running for long enough -> wait
			--minetest.after(0, function() minetest.debug("elapsed time: ".. tostring(block_physics.update_node() * 1000)) end)
			--minetest.debug("processing")
			coroutine.yield(os.clock() - start)
			start = os.clock()
		end
		
		local i = next(time_table)
		
		if (i ~= nil) then
			local pos = minetest.string_to_pos(i)
			local nodetype = check_type(minetest.get_node(pos).name)
			
			if nodetype == "physical" then
				update_single(pos)
			elseif nodetype == "deco" then
				update_deco(pos)
			elseif nodetype == "attached_node" then
				update_attached(pos)
			end
			
			--[[if update_single(pos) then
				--minetest.debug("check around "..i)
				block_physics.add_neighbors(pos)
			end--]]
			
			--minetest.debug("updated "..i)
			time_table[i] = nil
			
		else
			--all nodes have been updated -> wait
			coroutine.yield(os.clock() - start)
			start = os.clock()
		end
	end
end

block_physics.update_node = coroutine.wrap(thread)



--
-- Global callbacks
--

local function global_update(p, node)
	local nodetype = check_type(node.name)
	
	if nodetype == "solid" then
		block_physics.add_neighbors(p)
	elseif nodetype == "deco" then
		--block_physics.add_single(p)
	end
end
minetest.register_on_dignode(global_update)
minetest.register_on_placenode(global_update)


function block_physics.register_node(name, def)
	def.on_blast = function(pos, intensity)
		node = minetest.get_node(pos)
		minetest.remove_node(pos)
		--add neighbors to the list
		block_physics.add_neighbors(pos)
		return minetest.get_node_drops(node.name, "")
	end
	
	--[[def.after_place_node = function(pos)
		block_physics.add_single(pos)
	end]]
	
	def.on_construct = function(pos)
		block_physics.add_single(pos)
	end
	
	def.after_destruct = function(pos, old_node)
		block_physics.add_neighbors(pos)
	end
	
	def.paramtype2 = "physics"
	
	minetest.register_node(name,def)
end

function block_physics.add_deco(def)
	def.on_construct = function(pos)
		block_physics.add_single(pos)
	end
	return def
end

--minetest.register_globalstep(function() minetest.debug("elapsed time: ".. tostring(block_physics.update_node() * 1000)) end)
minetest.register_globalstep(block_physics.update_node)