local skills = {}

local function get_storage()
  return storage or global
end

local DIRECTION_VECTORS = {
  [defines.direction.north] = {x = 0, y = -1},
  [defines.direction.northeast] = {x = 0.707, y = -0.707},
  [defines.direction.east] = {x = 1, y = 0},
  [defines.direction.southeast] = {x = 0.707, y = 0.707},
  [defines.direction.south] = {x = 0, y = 1},
  [defines.direction.southwest] = {x = -0.707, y = 0.707},
  [defines.direction.west] = {x = -1, y = 0},
  [defines.direction.northwest] = {x = -0.707, y = -0.707}
}

function skills.init_player(player_index)
  local store = get_storage()
  store.players = store.players or {}
  store.players[player_index] = store.players[player_index] or {
    dash_ready_tick = 0,
    shield_ready_tick = 0,
    turret_ready_tick = 0
  }
end

function skills.handle_dash(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character or not player.character.valid then return end

  local store = get_storage()
  local p_data = store.players[player.index]
  local current_tick = game.tick
  local cooldown = (settings.global["blitz-dash-cooldown"].value or 5) * 60

  if current_tick < p_data.dash_ready_tick then
    player.create_local_flying_text{
      text = {"blitz.cooldown-remaining", math.ceil((p_data.dash_ready_tick - current_tick) / 60)},
      position = player.position,
      color = {r = 1, g = 0.3, b = 0.3}
    }
    return
  end

  local direction = defines.direction.north
  if player.walking_state.walking then
    direction = player.walking_state.direction
  end

  local vec = DIRECTION_VECTORS[direction] or {x = 0, y = -1}
  local distance = 8.0
  local target_pos = {
    x = player.position.x + (vec.x * distance),
    y = player.position.y + (vec.y * distance)
  }

  local safe_pos = player.surface.find_non_colliding_position("character", target_pos, 4, 0.5)
  if safe_pos then
    player.surface.create_entity{name = "explosion", position = player.position}
    player.teleport(safe_pos)
    player.surface.create_entity{name = "explosion", position = safe_pos}
    p_data.dash_ready_tick = current_tick + cooldown
    player.create_local_flying_text{
      text = {"blitz.dash-used"},
      position = safe_pos,
      color = {r = 0.2, g = 0.8, b = 1}
    }
  end
end

function skills.handle_shield(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character or not player.character.valid then return end

  local store = get_storage()
  local p_data = store.players[player.index]
  local current_tick = game.tick
  local cooldown = (settings.global["blitz-shield-cooldown"].value or 15) * 60

  if current_tick < p_data.shield_ready_tick then
    player.create_local_flying_text{
      text = {"blitz.cooldown-remaining", math.ceil((p_data.shield_ready_tick - current_tick) / 60)},
      position = player.position,
      color = {r = 1, g = 0.3, b = 0.3}
    }
    return
  end

  -- Burst heal + temporary shield absorption effect
  local char = player.character
  char.health = math.min(char.max_health, char.health + 150)
  player.surface.create_entity{name = "flying-robot-damaged-explosion", position = player.position}
  p_data.shield_ready_tick = current_tick + cooldown

  player.create_local_flying_text{
    text = {"blitz.shield-used"},
    position = player.position,
    color = {r = 0.2, g = 1, b = 0.4}
  }
end

function skills.handle_turret(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character or not player.character.valid then return end

  local store = get_storage()
  local p_data = store.players[player.index]
  local current_tick = game.tick
  local cooldown = (settings.global["blitz-turret-cooldown"].value or 25) * 60

  if current_tick < p_data.turret_ready_tick then
    player.create_local_flying_text{
      text = {"blitz.cooldown-remaining", math.ceil((p_data.turret_ready_tick - current_tick) / 60)},
      position = player.position,
      color = {r = 1, g = 0.3, b = 0.3}
    }
    return
  end

  local spawn_pos = player.surface.find_non_colliding_position("blitz-nano-turret", player.position, 5, 0.5)
  if spawn_pos then
    local turret = player.surface.create_entity{
      name = "blitz-nano-turret",
      position = spawn_pos,
      force = player.force
    }
    if turret and turret.valid then
      turret.insert{name = "firearm-magazine", count = 50}
      p_data.turret_ready_tick = current_tick + cooldown

      -- Store temporary turret to despawn after 25 seconds
      store.temp_turrets = store.temp_turrets or {}
      table.insert(store.temp_turrets, {entity = turret, destroy_tick = current_tick + (25 * 60)})

      player.create_local_flying_text{
        text = {"blitz.turret-deployed"},
        position = spawn_pos,
        color = {r = 1, g = 0.8, b = 0.2}
      }
    end
  end
end

function skills.clean_expired_turrets(current_tick)
  local store = get_storage()
  if not store.temp_turrets then return end

  for i = #store.temp_turrets, 1, -1 do
    local item = store.temp_turrets[i]
    if current_tick >= item.destroy_tick then
      if item.entity and item.entity.valid then
        item.entity.surface.create_entity{name = "small-scorchmark", position = item.entity.position}
        item.entity.destroy()
      end
      table.remove(store.temp_turrets, i)
    end
  end
end

return skills
