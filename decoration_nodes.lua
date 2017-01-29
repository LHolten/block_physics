default.register_fence(":default:fence_wood", block_physics.add_deco({
	description = "Wooden Fence",
	texture = "default_fence_wood.png",
	material = "default:wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, deco = 1},
	sounds = default.node_sound_wood_defaults()
}))

default.register_fence(":default:fence_acacia_wood", block_physics.add_deco({
	description = "Acacia Fence",
	texture = "default_fence_acacia_wood.png",
	material = "default:acacia_wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, deco = 1},
	sounds = default.node_sound_wood_defaults()
}))

default.register_fence(":default:fence_junglewood", block_physics.add_deco({
	description = "Junglewood Fence",
	texture = "default_fence_junglewood.png",
	material = "default:junglewood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, deco = 1},
	sounds = default.node_sound_wood_defaults()
}))

default.register_fence(":default:fence_pine_wood", block_physics.add_deco({
	description = "Pine Fence",
	texture = "default_fence_pine_wood.png",
	material = "default:pine_wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, deco = 1},
	sounds = default.node_sound_wood_defaults()
}))

default.register_fence(":default:fence_aspen_wood", block_physics.add_deco({
	description = "Aspen Fence",
	texture = "default_fence_aspen_wood.png",
	material = "default:aspen_wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, deco = 1},
	sounds = default.node_sound_wood_defaults()
}))

minetest.register_node(":default:glass", block_physics.add_deco({
	description = "Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"default_glass.png", "default_glass_detail.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, deco = 1},
	sounds = default.node_sound_glass_defaults(),
}))

minetest.register_node(":default:obsidian_glass", block_physics.add_deco({
	description = "Obsidian Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"default_obsidian_glass.png", "default_obsidian_glass_detail.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 3, deco = 1},
}))

minetest.register_node(":default:meselamp", block_physics.add_deco({
	description = "Mese Lamp",
	drawtype = "glasslike",
	tiles = {"default_meselamp.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, deco = 1},
	sounds = default.node_sound_glass_defaults(),
	light_source = default.LIGHT_MAX,
}))