local nano_turret_item = table.deepcopy(data.raw["item"]["gun-turret"])
nano_turret_item.name = "blitz-nano-turret"
nano_turret_item.icon = "__blitz-warfare__/graphics/icons/nano-turret.png"
nano_turret_item.icon_size = 64
nano_turret_item.place_result = "blitz-nano-turret"
nano_turret_item.order = "c[blitz]-a[nano-turret]"

local nano_turret_entity = table.deepcopy(data.raw["ammo-turret"]["gun-turret"])
nano_turret_entity.name = "blitz-nano-turret"
nano_turret_entity.icon = "__blitz-warfare__/graphics/icons/nano-turret.png"
nano_turret_entity.icon_size = 64
nano_turret_entity.minable = {mining_time = 0.2, result = "blitz-nano-turret"}
nano_turret_entity.max_health = 300
nano_turret_entity.attack_parameters.cooldown = 4 -- ultra rapid fire
nano_turret_entity.attack_parameters.range = 18

-- Command Core (Headquarters for PvP)
local core_item = table.deepcopy(data.raw["item"]["radar"])
core_item.name = "blitz-command-core"
core_item.place_result = "blitz-command-core"
core_item.order = "c[blitz]-b[core]"

local core_entity = table.deepcopy(data.raw["radar"]["radar"])
core_entity.name = "blitz-command-core"
core_entity.max_health = 10000
core_entity.minable = nil -- cannot be picked up once placed
core_entity.energy_usage = "300kW"

data:extend({
  nano_turret_item,
  nano_turret_entity,
  core_item,
  core_entity
})
