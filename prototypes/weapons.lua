local combat_shotgun = table.deepcopy(data.raw["gun"]["shotgun"])
combat_shotgun.name = "blitz-combat-shotgun"
combat_shotgun.attack_parameters.cooldown = 20 -- Fast firing rate
combat_shotgun.attack_parameters.range = 18
combat_shotgun.attack_parameters.damage_modifier = 1.3
combat_shotgun.order = "a[blitz]-a[shotgun]"

local tactical_rifle = table.deepcopy(data.raw["gun"]["submachine-gun"])
tactical_rifle.name = "blitz-tactical-rifle"
tactical_rifle.attack_parameters.cooldown = 6 -- Rapid fire
tactical_rifle.attack_parameters.range = 22
tactical_rifle.attack_parameters.damage_modifier = 1.2
tactical_rifle.order = "a[blitz]-b[rifle]"

local emp_launcher = table.deepcopy(data.raw["gun"]["rocket-launcher"])
emp_launcher.name = "blitz-emp-launcher"
emp_launcher.attack_parameters.cooldown = 45
emp_launcher.attack_parameters.range = 30
emp_launcher.order = "a[blitz]-c[emp-launcher]"

data:extend({
  combat_shotgun,
  tactical_rifle,
  emp_launcher
})
