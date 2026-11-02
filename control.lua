local skills = require("scripts.skills")
local pvp = require("scripts.pvp")
local gui = require("scripts.gui")

local function get_storage()
  return storage or global
end

local function on_init()
  local store = get_storage()
  store.players = store.players or {}
  store.temp_turrets = store.temp_turrets or {}
  store.match_active = false

  for _, player in pairs(game.players) do
    skills.init_player(player.index)
    gui.create_hud(player)
  end
end

script.on_init(on_init)
script.on_configuration_changed(on_init)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  skills.init_player(event.player_index)
  gui.create_hud(player)
  pvp.give_starter_kit(player)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.get_player(event.player_index)
  pvp.give_starter_kit(player)
end)

-- Skill custom inputs
script.on_event("blitz-skill-dash", skills.handle_dash)
script.on_event("blitz-skill-shield", skills.handle_shield)
script.on_event("blitz-skill-turret", skills.handle_turret)

-- Game loop tick
script.on_event(defines.events.on_tick, function(event)
  skills.clean_expired_turrets(event.tick)

  -- Update GUI every 15 ticks (~4 times per second)
  if event.tick % 15 == 0 then
    for _, player in pairs(game.connected_players) do
      gui.update_hud(player)
    end
  end
end)

-- PvP base destruction
script.on_event(defines.events.on_entity_died, pvp.handle_entity_died)

-- Admin / player commands
commands.add_command("blitz-start", "Start a new Blitz Warfare PvP match", function(cmd)
  pvp.init_match()
  for _, player in pairs(game.connected_players) do
    pvp.give_starter_kit(player)
  end
end)

commands.add_command("blitz-kit", "Re-arm with Blitz Warfare starter combat equipment", function(cmd)
  local player = game.get_player(cmd.player_index)
  if player then
    pvp.give_starter_kit(player)
  end
end)
