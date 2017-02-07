-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.

-- Register stairs.
-- Node will be called stairs:stair_<subname>

function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	groups.stair = 1
	minetest.register_node(":stairs:stair_" .. subname, block_physics.add_deco({
		description = description,
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:getpos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)
			end

			if p0.y - 1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
		on_construct = function(pos)
			block_physics.add_single(pos)
		end,
	}))
end


-- Register slabs.
-- Node will be called stairs:slab_<subname>

function stairs.register_slab(subname, recipeitem, groups, images, description, sounds)
	groups.slab = 1
	minetest.register_node(":stairs:slab_" .. subname, block_physics.add_deco({
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- If it's being placed on an another similar one, replace it with
			-- a full block
			local slabpos = nil
			local slabnode = nil
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local n0 = minetest.get_node(p0)
			local n1 = minetest.get_node(p1)
			local param2 = 0

			local n0_is_upside_down = (n0.name == "stairs:slab_" .. subname and
					n0.param2 >= 20)

			if n0.name == "stairs:slab_" .. subname and not n0_is_upside_down and
					p0.y + 1 == p1.y then
				slabpos = p0
				slabnode = n0
			elseif n1.name == "stairs:slab_" .. subname then
				slabpos = p1
				slabnode = n1
			end
			if slabpos then
				-- Remove the slab at slabpos
				minetest.remove_node(slabpos)
				-- Make a fake stack of a single item and try to place it
				local fakestack = ItemStack(recipeitem)
				fakestack:set_count(itemstack:get_count())

				pointed_thing.above = slabpos
				local success
				fakestack, success = minetest.item_place(fakestack, placer,
					pointed_thing)
				-- If the item was taken from the fake stack, decrement original
				if success then
					itemstack:set_count(fakestack:get_count())
				-- Else put old node back
				else
					minetest.set_node(slabpos, slabnode)
				end
				return itemstack
			end
			
			-- Upside down slabs
			if p0.y - 1 == p1.y then
				-- Turn into full block if pointing at a existing slab
				if n0_is_upside_down  then
					-- Remove the slab at the position of the slab
					minetest.remove_node(p0)
					-- Make a fake stack of a single item and try to place it
					local fakestack = ItemStack(recipeitem)
					fakestack:set_count(itemstack:get_count())

					pointed_thing.above = p0
					local success
					fakestack, success = minetest.item_place(fakestack, placer,
						pointed_thing)
					-- If the item was taken from the fake stack, decrement original
					if success then
						itemstack:set_count(fakestack:get_count())
					-- Else put old node back
					else
						minetest.set_node(p0, n0)
					end
					return itemstack
				end

				-- Place upside down slab
				param2 = 20
			end

			-- If pointing at the side of a upside down slab
			if n0_is_upside_down and p0.y + 1 ~= p1.y then
				param2 = 20
			end

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
	}))
end



function stairs.register_stair_and_slab(subname, recipeitem, groups, images,
		desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds)
end


-- Register default stairs and slabs

stairs.register_stair_and_slab("wood", "default:wood",
		{snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
		{"default_wood.png"},
		"Wooden Stair",
		"Wooden Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("junglewood", "default:junglewood",
		{snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
		{"default_junglewood.png"},
		"Junglewood Stair",
		"Junglewood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("pine_wood", "default:pine_wood",
		{snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
		{"default_pine_wood.png"},
		"Pine Wood Stair",
		"Pine Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("acacia_wood", "default:acacia_wood",
		{snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
		{"default_acacia_wood.png"},
		"Acacia Wood Stair",
		"Acacia Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("aspen_wood", "default:aspen_wood",
		{snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
		{"default_aspen_wood.png"},
		"Aspen Wood Stair",
		"Aspen Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("stone", "default:stone",
		{cracky = 3},
		{"default_stone.png"},
		"Stone Stair",
		"Stone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("cobble", "default:cobble",
		{cracky = 3},
		{"default_cobble.png"},
		"Cobblestone Stair",
		"Cobblestone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("stonebrick", "default:stonebrick",
		{cracky = 3},
		{"default_stone_brick.png"},
		"Stone Brick Stair",
		"Stone Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("desert_stone", "default:desert_stone",
		{cracky = 3},
		{"default_desert_stone.png"},
		"Desertstone Stair",
		"Desertstone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("desert_cobble", "default:desert_cobble",
		{cracky = 3},
		{"default_desert_cobble.png"},
		"Desert Cobblestone Stair",
		"Desert Cobblestone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("desert_stonebrick", "default:desert_stonebrick",
		{cracky = 3},
		{"default_desert_stone_brick.png"},
		"Desert Stone Brick Stair",
		"Desert Stone Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("sandstone", "default:sandstone",
		{crumbly = 1, cracky = 3},
		{"default_sandstone.png"},
		"Sandstone Stair",
		"Sandstone Slab",
		default.node_sound_stone_defaults())
		
stairs.register_stair_and_slab("sandstonebrick", "default:sandstonebrick",
		{cracky = 2},
		{"default_sandstone_brick.png"},
		"Sandstone Brick Stair",
		"Sandstone Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("obsidian", "default:obsidian",
		{cracky = 1, level = 2},
		{"default_obsidian.png"},
		"Obsidian Stair",
		"Obsidian Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("obsidianbrick", "default:obsidianbrick",
		{cracky = 1, level = 2},
		{"default_obsidian_brick.png"},
		"Obsidian Brick Stair",
		"Obsidian Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("brick", "default:brick",
		{cracky = 3},
		{"default_brick.png"},
		"Brick Stair",
		"Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("straw", "farming:straw",
		{snappy = 3, flammable = 4},
		{"farming_straw.png"},
		"Straw Stair",
		"Straw Slab",
		default.node_sound_leaves_defaults())

stairs.register_stair_and_slab("steelblock", "default:steelblock",
		{cracky = 1, level = 2},
		{"default_steel_block.png"},
		"Steel Block Stair",
		"Steel Block Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("copperblock", "default:copperblock",
		{cracky = 1, level = 2},
		{"default_copper_block.png"},
		"Copper Block Stair",
		"Copper Block Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("bronzeblock", "default:bronzeblock",
		{cracky = 1, level = 2},
		{"default_bronze_block.png"},
		"Bronze Block Stair",
		"Bronze Block Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("goldblock", "default:goldblock",
		{cracky = 1},
		{"default_gold_block.png"},
		"Gold Block Stair",
		"Gold Block Slab",
		default.node_sound_stone_defaults())
