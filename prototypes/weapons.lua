local combat_shotgun = table.deepcopy(data.raw["gun"]["shotgun"])
combat_shotgun.name = "blitz-combat-shotgun"
combat_shotgun.icon = "__blitz-warfare__/graphics/icons/combat-shotgun.png"
combat_shotgun.icon_size = 64
combat_shotgun.attack_parameters.cooldown = 18 -- Snappy rapid fire
combat_shotgun.attack_parameters.range = 18
combat_shotgun.attack_parameters.damage_modifier = 1.4
combat_shotgun.order = "a[blitz]-a[shotgun]"

local tactical_rifle = table.deepcopy(data.raw["gun"]["submachine-gun"])
tactical_rifle.name = "blitz-tactical-rifle"
tactical_rifle.icon = "__blitz-warfare__/graphics/icons/tactical-rifle.png"
tactical_rifle.icon_size = 64
tactical_rifle.attack_parameters.cooldown = 5 -- Rapid assault fire
tactical_rifle.attack_parameters.range = 24
tactical_rifle.attack_parameters.damage_modifier = 1.25
tactical_rifle.order = "a[blitz]-b[rifle]"

local emp_launcher = table.deepcopy(data.raw["gun"]["rocket-launcher"])
emp_launcher.name = "blitz-emp-launcher"
emp_launcher.icon = "__blitz-warfare__/graphics/icons/emp-launcher.png"
emp_launcher.icon_size = 64
emp_launcher.attack_parameters.cooldown = 40
emp_launcher.attack_parameters.range = 32
emp_launcher.order = "a[blitz]-c[emp-launcher]"

data:extend({
  combat_shotgun,
  tactical_rifle,
  emp_launcher
})
