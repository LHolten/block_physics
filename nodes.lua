local cobble = {cracky = 3, stone = 2, weight = 2, shear = 8, compressive = 14, tensile = 2}

block_physics.add_physical("default:cobble", cobble)

block_physics.add_physical("default:desert_cobble", cobble)


local mossycobble = {cracky = 3, stone = 1, weight = 2, shear = 8, compressive = 12, tensile = 2}

block_physics.add_physical("default:mossycobble", mossycobble)


local brick = {cracky = 3, weight = 2, shear = 12, compressive = 22, tensile = 5}

block_physics.add_physical("default:brick", brick)


local stonebrick = {cracky = 2, stone = 1, weight = 2, shear = 12, compressive = 20, tensile = 4}

block_physics.add_physical("default:stonebrick", stonebrick)

block_physics.add_physical("default:desert_stonebrick", stonebrick)


local sandstonebrick = {cracky = 2, weight = 2, shear = 10, compressive = 18, tensile = 4}

block_physics.add_physical("default:sandstonebrick", sandstonebrick)


local obsidianbrick = {cracky = 1, level = 2, weight = 2, shear = 16, compressive = 24, tensile = 6}

block_physics.add_physical("default:obsidianbrick", obsidianbrick)


local wood = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, wood = 1, weight = 1, shear = 12, compressive = 8, tensile = 6}

block_physics.add_physical("default:wood", wood)

block_physics.add_physical("default:junglewood", wood)

block_physics.add_physical("default:pine_wood", wood)

block_physics.add_physical("default:acacia_wood", wood)

block_physics.add_physical("default:aspen_wood", wood)


local coalblock = {cracky = 3, weight = 2, shear = 2, compressive = 20, tensile = 0}

block_physics.add_physical("default:coalblock", coalblock)


local metalblock = {cracky = 1, level = 2, weight = 3, shear = 24, compressive = 12, tensile = 30}

block_physics.add_physical("default:steelblock", metalblock)

block_physics.add_physical("default:copperblock", metalblock)

block_physics.add_physical("default:bronzeblock", metalblock)

block_physics.add_physical("default:mese", metalblock)


local goldblock = {cracky = 1, weight = 3, shear = 12, compressive = 6, tensile = 12}

block_physics.add_physical("default:goldblock", goldblock)


local diamondblock = {cracky = 1, level = 3, weight = 3, shear = 30, compressive = 15, tensile = 30}

block_physics.add_physical("default:diamondblock", diamondblock)