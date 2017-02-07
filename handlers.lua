--
--physical handler
--

local function update_physical(pos, node)
	local node = node or minetest.get_node_or_nil(pos)
	if (block_physics.check_type(node.name) ~= "physical") then return false end

	
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
	

	if (block_physics.check_type(minusX.name) == "physical" and block_physics.check_type(plusX.name) == "physical") then
		B = B - 1
	end
	if (block_physics.check_type(minusZ.name) == "physical" and block_physics.check_type(plusZ.name) == "physical") then
		B = B - 1
	end
	if ((block_physics.check_type(under.name) == "physical" or block_physics.check_type(under.name) == "solid") and block_physics.check_type(above.name) == "physical") then
		B = B - 1
	end
	
	--check all horizontal sides for nodes and calculate there minH and maxF
	for _, side in ipairs({minusX, plusX, minusZ, plusZ}) do
		if (block_physics.check_type(side.name) == "physical") then
			local f = side.param2
			local h = side.param1
			
			sideH = math.min(h + B, sideH)
			sideF = math.max(math.min(f - weight * (h + B), shear * (factor - B)), sideF)
		end
	end
	
	--calc under force
	if (block_physics.check_type(under.name) == "physical") then

		underF = math.min(under.param2 - weight * B, compressive * (factor - B))
		underH = B
		
	elseif (block_physics.check_type(under.name) == "solid") then
		underF = compressive * (factor - B)
		underH = B
	end
	
	--calc above force
	
	if (block_physics.check_type(above.name) == "physical") then
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
		if not block_physics.drop_node(pos, node) then
			minetest.set_node(pos, {name = node.name, param2 = 0, param1 = 255}) --make sure nobody will depend on this block 
		end
	elseif returnvalue then
		--this block is supported properly but some value has changed -> update block
		minetest.set_node(pos, {name = node.name, param2 = force, param1 = hanging}) --this will trigger an update for the surrounding blocks
	end
	
	return returnvalue
end

block_physics.register_handler("physical", update_physical)

--
--deco handler
--

local function update_deco(pos, node)
	local node = node or minetest.get_node_or_nil(pos)
	local under = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local sides = {{x = pos.x - 1, y = pos.y, z = pos.z}, {x = pos.x + 1, y = pos.y, z = pos.z}, {x = pos.x, y = pos.y, z = pos.z - 1}, {x = pos.x, y = pos.y, z = pos.z + 1}}
	local neighbors = {{x = pos.x - 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z - 1},{x = pos.x + 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z + 1},{x = pos.x, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y + 1, z = pos.z}}
	local m = 0
	
	for i, posn in pairs(neighbors) do
		local n = minetest.get_node(posn)
		local nodetype = block_physics.check_type(n.name)
		if (nodetype == "solid" or (nodetype == "physical" and n.param1 ~= 255)) then
			m = m + 1
		end
	end
	
	if (m < minetest.registered_nodes[node.name].groups["deco"]) then
		--this block is not supported properly -> try to fall
		block_physics.drop_node(pos, node)
	end
end

block_physics.register_handler("deco", update_deco)

--
--atached handler
--

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
	local ntype = block_physics.check_type(nn)
	if ntype == "physical" or ntype == "solid" then
		return true
	end
	return false
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

block_physics.register_handler("attached_node", update_attached)