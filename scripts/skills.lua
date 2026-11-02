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
  store.rolling_characters = store.rolling_characters or {}
  store.invulnerable_characters = store.invulnerable_characters or {}
  store.temp_turrets = store.temp_turrets or {}
end

-- 1. Dark Souls Dodge Roll (Smooth glide over 10 ticks with i-frames & dust trail)
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

  local char = player.character
  local dir = (player.walking_state and player.walking_state.walking) and player.walking_state.direction or char.direction
  local vec = DIRECTION_VECTORS[dir] or {x = 0, y = -1}

  -- Grant i-frames during the roll
  char.destructible = false

  -- Register active rolling physics
  store.rolling_characters = store.rolling_characters or {}
  store.rolling_characters[char.unit_number] = {
    player = player,
    character = char,
    vec = vec,
    ticks_left = 10,
    speed_per_tick = 0.35 -- 10 * 0.35 = 3.5 tiles smooth roll
  }

  p_data.dash_ready_tick = current_tick + cooldown

  -- Starting dust puff
  player.surface.create_trivial_smoke{name = "smoke-fast", position = player.position}

  -- Cyan i-frame indicator ring at start
  rendering.draw_circle{
    color = {r = 0.3, g = 0.9, b = 1.0, a = 0.8},
    radius = 0.8,
    width = 2,
    filled = false,
    target = char,
    surface = player.surface,
    time_to_live = 15
  }

  player.create_local_flying_text{
    text = {"blitz.dash-used"},
    position = player.position,
    color = {r = 0.4, g = 0.9, b = 1.0}
  }
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
    color = {r = 0.1, g = 0.85, b = 1.0, a = 0.85},
    radius = 1.6,
    width = 3,
    filled = false,
    target = char,
    surface = player.surface,
    time_to_live = shield_duration_ticks
  }

  -- Inner translucent energy field
  rendering.draw_circle{
    color = {r = 0.1, g = 0.5, b = 1.0, a = 0.25},
    radius = 1.5,
    filled = true,
    target = char,
    surface = player.surface,
    time_to_live = shield_duration_ticks
  }

  -- Energy light aura around player
  rendering.draw_light{
    sprite = "utility/light_medium",
    scale = 2.2,
    intensity = 1.0,
    minimum_darkness = 0,
    target = char,
    surface = player.surface,
    time_to_live = shield_duration_ticks
  }

  -- Spark burst on trigger
  player.surface.create_entity{name = "flying-robot-damaged-explosion", position = player.position}

  -- Invulnerability / absorption during barrier
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

-- 3. Deployable Nano-Turret (Placed forward, no collision with character)
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

  local char = player.character
  local dir = (player.walking_state and player.walking_state.walking) and player.walking_state.direction or char.direction
  local vec = DIRECTION_VECTORS[dir] or {x = 0, y = 1}

  local forward_pos = {
    x = player.position.x + (vec.x * 3.0),
    y = player.position.y + (vec.y * 3.0)
  }

  local spawn_pos = player.surface.find_non_colliding_position("blitz-nano-turret", forward_pos, 4, 0.5)
  if spawn_pos then
    local turret = player.surface.create_entity{
      name = "blitz-nano-turret",
      position = spawn_pos,
      force = player.force
    }
    if turret and turret.valid then
      turret.insert{name = "firearm-magazine", count = 50}

      -- Deployment smoke & ring
      player.surface.create_trivial_smoke{name = "smoke-fast", position = spawn_pos}
      rendering.draw_circle{
        color = {r = 1.0, g = 0.8, b = 0.2, a = 0.6},
        radius = 1.0,
        width = 2,
        filled = false,
        target = turret,
        surface = player.surface,
        time_to_live = 40
      }

      p_data.turret_ready_tick = current_tick + cooldown

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

-- Tick handler: updates smooth rolling physics and cleans temporary entities
function skills.on_tick(current_tick)
  local store = get_storage()

  -- 1. Smooth Dodge Roll Physics Update (10 ticks glide)
  if store.rolling_characters then
    for unit_number, roll in pairs(store.rolling_characters) do
      local char = roll.character
      if char and char.valid then
        local next_pos = {
          x = char.position.x + (roll.vec.x * roll.speed_per_tick),
          y = char.position.y + (roll.vec.y * roll.speed_per_tick)
        }

        local safe = char.surface.find_non_colliding_position("character", next_pos, 0.4, 0.1)
        if safe then
          char.teleport(safe)
          -- Dust trail every 2 frames
          if roll.ticks_left % 2 == 0 then
            char.surface.create_trivial_smoke{name = "smoke-fast", position = char.position}
          end
        else
          -- Wall/cliff hit, stop roll early
          roll.ticks_left = 0
        end

        roll.ticks_left = roll.ticks_left - 1
        if roll.ticks_left <= 0 then
          -- Restore vulnerability if not shielded
          local is_shielded = store.invulnerable_characters and store.invulnerable_characters[unit_number]
          if not is_shielded then
            char.destructible = true
          end
          store.rolling_characters[unit_number] = nil
        end
      else
        store.rolling_characters[unit_number] = nil
      end
    end
  end

  -- 2. Restore vulnerability after Shield expires
  if store.invulnerable_characters then
    for unit_number, data in pairs(store.invulnerable_characters) do
      if current_tick >= data.restore_tick then
        if data.character and data.character.valid then
          local is_rolling = store.rolling_characters and store.rolling_characters[unit_number]
          if not is_rolling then
            data.character.destructible = true
          end
        end
        store.invulnerable_characters[unit_number] = nil
      end
    end
  end

  -- 3. Clean up expired temporary turrets
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
