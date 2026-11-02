local pvp = {}

local function get_storage()
  return storage or global
end

local TEAM_COLORS = {
  ["Team Red"] = {r = 1.0, g = 0.2, b = 0.2},
  ["Team Blue"] = {r = 0.2, g = 0.5, b = 1.0},
  ["Team Green"] = {r = 0.2, g = 0.9, b = 0.3},
  ["Team Yellow"] = {r = 1.0, g = 0.9, b = 0.2}
}

function pvp.init_match()
  local store = get_storage()
  store.match_active = true
  store.team_cores = store.team_cores or {}

  -- Ensure forces exist
  local red = game.forces["Team Red"] or game.create_force("Team Red")
  local blue = game.forces["Team Blue"] or game.create_force("Team Blue")

  red.set_friend(blue, false)
  blue.set_friend(red, false)
  red.set_cease_fire(blue, false)
  blue.set_cease_fire(red, false)

  local surface = game.surfaces[1]

  -- Spawn Team Red Core at (-100, 0)
  local red_core_pos = surface.find_non_colliding_position("blitz-command-core", {-100, 0}, 20, 1) or {-100, 0}
  local red_core = surface.create_entity{name = "blitz-command-core", position = red_core_pos, force = red}
  store.team_cores["Team Red"] = red_core

  -- Spawn Team Blue Core at (100, 0)
  local blue_core_pos = surface.find_non_colliding_position("blitz-command-core", {100, 0}, 20, 1) or {100, 0}
  local blue_core = surface.create_entity{name = "blitz-command-core", position = blue_core_pos, force = blue}
  store.team_cores["Team Blue"] = blue_core

  game.print({"blitz.match-started"})
end

function pvp.give_starter_kit(player)
  if not player or not player.character then return end
  local inv = player.get_main_inventory()
  if not inv then return end

  inv.clear()
  inv.insert{name = "blitz-combat-shotgun", count = 1}
  inv.insert{name = "blitz-tactical-rifle", count = 1}
  inv.insert{name = "blitz-slug-shell", count = 60}
  inv.insert{name = "firearm-magazine", count = 150}
  inv.insert{name = "light-armor", count = 1}

  -- Fast starter logistics
  inv.insert{name = "burner-mining-drill", count = 6}
  inv.insert{name = "stone-furnace", count = 6}
  inv.insert{name = "coal", count = 50}
  inv.insert{name = "iron-plate", count = 50}
  inv.insert{name = "copper-plate", count = 50}
end

function pvp.handle_entity_died(event)
  local entity = event.entity
  if not entity or not entity.valid then return end

  if entity.name == "blitz-command-core" then
    local losing_force = entity.force.name
    local winning_force = (losing_force == "Team Red") and "Team Blue" or "Team Red"
    game.print({"blitz.team-eliminated", losing_force, winning_force})
  end
end

return pvp
