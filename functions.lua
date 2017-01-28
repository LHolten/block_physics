--local nonSolids = {["air"] = true, ["fire:basic_flame"] = true, ["default:water_source"] = true, ["default:water_flowing"] = true, ["default:river_water_source"] = true, ["default:river_water_flowing"] = true, ["default:lava_source"] = true, ["default:lava_flowing"] = true}


local function check_type(name)
	if (name == "air") then return "non_solid" end
	
	if (minetest.registered_nodes[name].paramtype2 == "physics") then return "physical" end
	
	if (minetest.registered_nodes[name].groups["liquid"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flora"]) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["flammable"] == 4) then return "non_solid" end
	
	if (minetest.registered_nodes[name].groups["dig_immediate"] == 3) then return "non_solid" end
	
	return "solid"
end

local function update_single(pos, node)
	node = node or minetest.get_node_or_nil(pos)
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
	
	
	
	local poses = 		{{x = pos.x - 1, y = pos.y, z = pos.z},		{x = pos.x, y = pos.y, z = pos.z - 1},		{x = pos.x + 1, y = pos.y, z = pos.z},		{x = pos.x, y = pos.y, z = pos.z + 1}}
	--local underposes = 	{{x = pos.x - 1, y = pos.y - 1, z = pos.z},	{x = pos.x, y = pos.y - 1, z = pos.z - 1},	{x = pos.x + 1, y = pos.y - 1, z = pos.z},	{x = pos.x, y = pos.y - 1, z = pos.z + 1}}
	local maxF, m, minH	= 0, 0, 255
	
	
	--check all horizontal sides for nodes and calculate there minH and maxF
	for i,posn in pairs(poses) do
		local side = minetest.get_node(posn)
		
		if (check_type(side.name) == "physical") then
			local f = side.param2
			local h = side.param1
			if (h ~= 0) then
				m = m + 1
				
				minH = math.min(h, minH)
				maxF = math.max(f, maxF)
			end
		end
	end
	
	
	--set side force
	if (m ~= 0) then
		--this should be done for each side..
		sideF = math.min(maxF - weight * minH, shear)
		sideH = minH + 1
	end
	

	
	--calc under force
	if (check_type(under.name) == "physical") then
		underF = math.min(under.param2 - weight, compressive)
		underH = 1
		
		--if node is bedded set sideF to maxF
		if (m == 4) then
			sideF = math.max(maxF, math.min(under.param2, compressive))
			sideH = 0 --extra low to show it is fixed
		end--]]
		
	elseif (check_type(under.name) == "solid") then
		underF = compressive
		underH = 1
	end
	
	--calc above force
	
	if (check_type(above.name) == "physical") then
		aboveF = math.min(above.param2 - weight, tensile)
		aboveH = above.param1
	end
	
	if underF >= sideF and underF >= aboveF then
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
			for i,posn in pairs(poses) do
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


-- handling machine
local function thread()
	local next = next
	local start = os.clock()
	
	while true do
		--minetest.debug("test")
		if ((os.clock() - start) * 1000 > 1) then
			--has been running for long enough -> wait
			--minetest.after(0, function() minetest.debug("elapsed time: ".. tostring(block_physics.update_node() * 1000)) end)
			coroutine.yield(os.clock() - start)
			start = os.clock()
		end
		
		local i = next(time_table)
		
		if (i ~= nil) then
			local pos = minetest.string_to_pos(i)
			
			update_single(pos)
			
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

local function update_around_solid(p, node)
	if check_type(node.name) == "solid" then
		block_physics.add_neighbors(p)
	end
end
minetest.register_on_dignode(update_around_solid)
minetest.register_on_placenode(update_around_solid)


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
	end--]]
	
	def.on_construct = function(pos)
		block_physics.add_single(pos)
	end
	
	def.after_destruct = function(pos)
		block_physics.add_neighbors(pos)
	end
	
	def.paramtype2 = "physics"
	
	minetest.register_node(name,def)
end

--minetest.register_globalstep(function() minetest.debug("elapsed time: ".. tostring(block_physics.update_node() * 1000)) end)
minetest.register_globalstep(block_physics.update_node)