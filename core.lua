local time_table = {}
local handlers = {}
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
			block_physics.isProcessing = true
			coroutine.yield(os.clock() - start)
			start = os.clock()
		end
		
		local i = next(time_table)
		
		if (i ~= nil) then
			local pos = minetest.string_to_pos(i)
			local nodetype = block_physics.check_type(minetest.get_node(pos).name)
			
			if handlers[nodetype] then
				handlers[nodetype](pos)
			end
			
			--remove this position from the que even when the handler modified it.
			time_table[i] = nil
			
		else
			--all nodes have been updated -> wait
			block_physics.isProcessing = false
			coroutine.yield(os.clock() - start)
			start = os.clock()
		end
	end
end

block_physics.update_node = coroutine.wrap(thread)

--minetest.register_globalstep(function() minetest.debug("elapsed time: ".. tostring(block_physics.update_node() * 1000)) end)
minetest.register_globalstep(block_physics.update_node)

function block_physics.register_handler(nodetype, handler)
	handlers[nodetype] = handler
	minetest.debug("handler registered for "..nodetype)
end

function block_physics.get_handler(nodetype)
	return handlers[nodetype]
end