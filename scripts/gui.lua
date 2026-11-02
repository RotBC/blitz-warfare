local gui = {}

local function get_storage()
  return storage or global
end

function gui.create_hud(player)
  if not player or not player.valid then return end
  local top = player.gui.top
  if top.blitz_hud then top.blitz_hud.destroy() end

  local frame = top.add{
    type = "frame",
    name = "blitz_hud",
    direction = "horizontal",
    style = "blitz_hud_frame"
  }

  local flow = frame.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", name = "lbl_dash", caption = "Dash [SHIFT+SPC]: RDY"}
  flow.add{type = "label", caption = " | "}
  flow.add{type = "label", name = "lbl_shield", caption = "Shield [V]: RDY"}
  flow.add{type = "label", caption = " | "}
  flow.add{type = "label", name = "lbl_turret", caption = "Turret [X]: RDY"}
end

function gui.update_hud(player)
  if not player or not player.valid then return end
  local frame = player.gui.top.blitz_hud
  if not frame then
    gui.create_hud(player)
    return
  end

  local store = get_storage()
  local p_data = store.players and store.players[player.index]
  if not p_data then return end

  local current_tick = game.tick
  local flow = frame.children[1]
  if not flow then return end

  -- Dash
  local dash_left = math.max(0, math.ceil((p_data.dash_ready_tick - current_tick) / 60))
  flow.lbl_dash.caption = (dash_left == 0) and "Dash [SHIFT+SPC]: RDY" or ("Dash [SPC]: " .. dash_left .. "s")

  -- Shield
  local shield_left = math.max(0, math.ceil((p_data.shield_ready_tick - current_tick) / 60))
  flow.lbl_shield.caption = (shield_left == 0) and "Shield [V]: RDY" or ("Shield [V]: " .. shield_left .. "s")

  -- Turret
  local turret_left = math.max(0, math.ceil((p_data.turret_ready_tick - current_tick) / 60))
  flow.lbl_turret.caption = (turret_left == 0) and "Turret [X]: RDY" or ("Turret [X]: " .. turret_left .. "s")
end

return gui
