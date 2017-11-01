function block_physics.register_stair_and_slab(subname)
	block_physics.add_physical("stairs:stair_" .. subname, "deco")
	block_physics.add_physical("stairs:slab_" .. subname, "deco")
end


-- Register default stairs and slabs

block_physics.register_stair_and_slab("wood")

block_physics.register_stair_and_slab("junglewood")

block_physics.register_stair_and_slab("pine_wood")

block_physics.register_stair_and_slab("acacia_wood")

block_physics.register_stair_and_slab("aspen_wood")

block_physics.register_stair_and_slab("stone")

block_physics.register_stair_and_slab("cobble")

block_physics.register_stair_and_slab("stonebrick")

block_physics.register_stair_and_slab("desert_stone")

block_physics.register_stair_and_slab("desert_cobble")

block_physics.register_stair_and_slab("desert_stonebrick")

block_physics.register_stair_and_slab("sandstone")
		
block_physics.register_stair_and_slab("sandstonebrick")

block_physics.register_stair_and_slab("obsidian")

block_physics.register_stair_and_slab("obsidianbrick")

block_physics.register_stair_and_slab("brick")

block_physics.register_stair_and_slab("straw")

block_physics.register_stair_and_slab("steelblock")

block_physics.register_stair_and_slab("copperblock")

block_physics.register_stair_and_slab("bronzeblock")

block_physics.register_stair_and_slab("goldblock")
