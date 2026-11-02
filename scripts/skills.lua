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
  store.invulnerable_characters = store.invulnerable_characters or {}
  store.shielded_characters = store.shielded_characters or {}
  store.temp_turrets = store.temp_turrets or {}
end

-- 1. Dark Souls Roll (Dodge Roll with i-frames)
function skills.handle_dash(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character or not player.character.valid then return end

  local store = get_storage()
  store.players = store.players or {}
  local p_data = store.players[player.index]
  if not p_data then
    skills.init_player(player.index)
    p_data = store.players[player.index]
  end

  local current_tick = game.tick
  local cooldown = (settings.global["blitz-dash-cooldown"].value or 4) * 60

  if current_tick < p_data.dash_ready_tick then
    player.create_local_flying_text{
      text = {"blitz.cooldown-remaining", math.ceil((p_data.dash_ready_tick - current_tick) / 60)},
      position = player.position,
      color = {r = 1, g = 0.3, b = 0.3}
    }
    return
  end

  -- Determine direction: walking direction first, or character facing direction
  local char = player.character
  local dir = (player.walking_state and player.walking_state.walking) and player.walking_state.direction or char.direction
  local vec = DIRECTION_VECTORS[dir] or {x = 0, y = -1}

  -- Compact dodge distance (DS roll feel ~ 3.2 tiles)
  local roll_distance = 3.2
  local target_pos = {
    x = player.position.x + (vec.x * roll_distance),
    y = player.position.y + (vec.y * roll_distance)
  }

  local safe_pos = player.surface.find_non_colliding_position("character", target_pos, 2.5, 0.2)
  if safe_pos then
    local start_pos = player.position

    -- Smoke and dust at start position
    player.surface.create_trivial_smoke{name = "smoke-fast", position = start_pos}

    -- Teleport character for snappy roll feel
    player.teleport(safe_pos)

    -- Visual trail and dust at landing
    player.surface.create_trivial_smoke{name = "smoke-fast", position = safe_pos}

    -- Visual i-frame pulse (cyan ring)
    rendering.draw_circle{
      color = {r = 0.3, g = 0.8, b = 1.0, a = 0.6},
      radius = 0.8,
      width = 2,
      filled = false,
      target = char,
      surface = player.surface,
      time_to_live = 20
    }

    -- Dark Souls i-frames: Invulnerability for 20 ticks (~0.33 seconds)
    char.destructible = false
    store.invulnerable_characters = store.invulnerable_characters or {}
    store.invulnerable_characters[char.unit_number] = {
      character = char,
      restore_tick = current_tick + 20
    }

    p_data.dash_ready_tick = current_tick + cooldown

    player.create_local_flying_text{
      text = {"blitz.dash-used"},
      position = safe_pos,
      color = {r = 0.4, g = 0.9, b = 1.0}
    }
  end
end

-- 2. Energy Shield with Visual Barrier Dome & Lighting
function skills.handle_shield(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character or not player.character.valid then return end

  local store = get_storage()
  store.players = store.players or {}
  local p_data = store.players[player.index]
  if not p_data then
    skills.init_player(player.index)
    p_data = store.players[player.index]
  end

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

  local char = player.character
  local shield_duration_ticks = 180 -- 3 seconds of energy barrier

  -- Visual Energy Barrier Dome: Outer glowing ring
  rendering.draw_circle{
    color = {r = 0.1, g = 0.8, b = 1.0, a = 0.8},
    radius = 1.5,
    width = 3,
    filled = false,
    target = char,
    surface = player.surface,
    time_to_live = shield_duration_ticks
  }

  -- Inner translucent energy field
  rendering.draw_circle{
    color = {r = 0.1, g = 0.5, b = 1.0, a = 0.25},
    radius = 1.4,
    filled = true,
    target = char,
    surface = player.surface,
    time_to_live = shield_duration_ticks
  }

  -- Energy light aura around player
  rendering.draw_light{
    sprite = "utility/light_medium",
    scale = 2.0,
    intensity = 1.0,
    minimum_darkness = 0,
    target = char,
    surface = player.surface,
    time_to_live = shield_duration_ticks
  }

  -- Spark burst on trigger
  player.surface.create_entity{name = "flying-robot-damaged-explosion", position = player.position}

  -- Invulnerability/high defense state during barrier
  char.destructible = false
  store.invulnerable_characters = store.invulnerable_characters or {}
  store.invulnerable_characters[char.unit_number] = {
    character = char,
    restore_tick = current_tick + shield_duration_ticks
  }

  p_data.shield_ready_tick = current_tick + cooldown

  player.create_local_flying_text{
    text = {"blitz.shield-used"},
    position = player.position,
    color = {r = 0.2, g = 1.0, b = 0.4}
  }
end

-- 3. Deployable Nano-Turret (Spawned in front of the player without collision)
function skills.handle_turret(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character or not player.character.valid then return end

  local store = get_storage()
  store.players = store.players or {}
  local p_data = store.players[player.index]
  if not p_data then
    skills.init_player(player.index)
    p_data = store.players[player.index]
  end

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

  -- Calculate position 3.0 tiles IN FRONT of the player
  local char = player.character
  local dir = (player.walking_state and player.walking_state.walking) and player.walking_state.direction or char.direction
  local vec = DIRECTION_VECTORS[dir] or {x = 0, y = 1}

  local forward_pos = {
    x = player.position.x + (vec.x * 3.0),
    y = player.position.y + (vec.y * 3.0)
  }

  -- Find safe position near forward_pos (away from the player character)
  local spawn_pos = player.surface.find_non_colliding_position("blitz-nano-turret", forward_pos, 4, 0.5)
  if spawn_pos then
    local turret = player.surface.create_entity{
      name = "blitz-nano-turret",
      position = spawn_pos,
      force = player.force
    }
    if turret and turret.valid then
      turret.insert{name = "firearm-magazine", count = 50}

      -- Deployment visual & sound
      player.surface.create_trivial_smoke{name = "smoke-fast", position = spawn_pos}
      rendering.draw_circle{
        color = {r = 1.0, g = 0.8, b = 0.2, a = 0.5},
        radius = 1.0,
        width = 2,
        filled = false,
        target = turret,
        surface = player.surface,
        time_to_live = 40
      }

      p_data.turret_ready_tick = current_tick + cooldown

      -- Temporary turret lifetime: 25 seconds
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

-- Clean expired temporary states on tick
function skills.on_tick(current_tick)
  local store = get_storage()

  -- 1. Restore destructible state after i-frames / shield expire
  if store.invulnerable_characters then
    for unit_number, data in pairs(store.invulnerable_characters) do
      if current_tick >= data.restore_tick then
        if data.character and data.character.valid then
          data.character.destructible = true
        end
        store.invulnerable_characters[unit_number] = nil
      end
    end
  end

  -- 2. Clean up expired temporary turrets
  if store.temp_turrets then
    for i = #store.temp_turrets, 1, -1 do
      local item = store.temp_turrets[i]
      if current_tick >= item.destroy_tick then
        if item.entity and item.entity.valid then
          item.entity.surface.create_entity{name = "small-scorchmark", position = item.entity.position}
          item.entity.surface.create_trivial_smoke{name = "smoke-fast", position = item.entity.position}
          item.entity.destroy()
        end
        table.remove(store.temp_turrets, i)
      end
    end
  end
end

return skills
