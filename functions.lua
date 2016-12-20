--local nonSolids = {["air"] = true, ["fire:basic_flame"] = true, ["default:water_source"] = true, ["default:water_flowing"] = true, ["default:river_water_source"] = true, ["default:river_water_flowing"] = true, ["default:lava_source"] = true, ["default:lava_flowing"] = true}


local function check_type(name)
	if (name == "air") then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["weight"]) then return "physical" end
	
	if (minetest.registered_nodes[name].groups["liquid"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flora"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["dig_immediate"] == 3) then return "non_solid" end
	
	return "solid"
end

local function update_single(pos, node)
	node = node or minetest.get_node_or_nil(pos)
	local shear = minetest.registered_nodes[node.name].groups["shear"] or 12
	local compressive = minetest.registered_nodes[node.name].groups["compressive"] or 10
	local weight = minetest.registered_nodes[node.name].groups["weight"] or 2
	local tensile = minetest.registered_nodes[node.name].groups["tensile"] or 6
	local returnvalue = false
	
	local force = node.param2
	
	
	local poses = 		{{x = pos.x - 1, y = pos.y, z = pos.z},		{x = pos.x, y = pos.y, z = pos.z - 1},		{x = pos.x + 1, y = pos.y, z = pos.z},		{x = pos.x, y = pos.y, z = pos.z + 1}}
	--local underposes = 	{{x = pos.x - 1, y = pos.y - 1, z = pos.z},	{x = pos.x, y = pos.y - 1, z = pos.z - 1},	{x = pos.x + 1, y = pos.y - 1, z = pos.z},	{x = pos.x, y = pos.y - 1, z = pos.z + 1}}
	local maxy, miny, m = 0, 16, 0
	
	--check all sides for nodes in group shear and calculate there max and min
	
	for i,posn in pairs(poses) do
		local side = minetest.get_node(posn)
		
		if (check_type(side.name) == "physical") then
			local f = side.param2
			
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
	
	if (check_type(under.name) == "physical") then
		underF = math.min(under.param2 - weight, compressive)
	elseif (check_type(under.name) == "solid") then
		underF = compressive
	end
	
	--calc above force
	
	if (check_type(above.name) == "physical") then
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
		if (check_type(under.name) ~= "non_solid") then
			for i,posn in pairs(poses) do
				local n = minetest.get_node(posn)
				local posm = {x = posn.x, y = posn.y - 1, z = posn.z}
				local m = minetest.get_node(posm)
				
				if ((check_type(n.name) == "non_solid") and (check_type(m.name) == "non_solid")) then
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
	local physical = (check_type(node.name) == "physical")
	local check = true
	
	if (physical) then
		check = (update_single(pos, node))
	end
	
	if (check) then
		local neighbors = {{x = pos.x - 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z - 1},{x = pos.x + 1, y = pos.y, z = pos.z},{x = pos.x, y = pos.y, z = pos.z + 1},{x = pos.x, y = pos.y - 1, z = pos.z},{x = pos.x, y = pos.y + 1, z = pos.z}}
		
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