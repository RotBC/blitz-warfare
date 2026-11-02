local slug_shell = table.deepcopy(data.raw["ammo"]["shotgun-shell"])
slug_shell.name = "blitz-slug-shell"
slug_shell.ammo_type.action = {
  {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "damage",
          damage = {amount = 60, type = "physical"}
        },
        {
          type = "push-back",
          distance = 2.5
        }
      }
    }
  }
}
slug_shell.order = "b[blitz]-a[slug]"

local emp_missile = table.deepcopy(data.raw["ammo"]["rocket"])
emp_missile.name = "blitz-emp-missile"
emp_missile.ammo_type.action = {
  type = "direct",
  action_delivery = {
    type = "projectile",
    projectile = "rocket",
    starting_speed = 0.15,
    max_range = 32,
    target_effects = {
      {
        type = "nested-result",
        action = {
          type = "area",
          radius = 6.0,
          action_delivery = {
            type = "instant",
            target_effects = {
              {
                type = "damage",
                damage = {amount = 120, type = "electric"}
              },
              {
                type = "create-sticker",
                sticker = "slowdown-sticker"
              }
            }
          }
        }
      }
    }
  }
}
emp_missile.order = "b[blitz]-b[emp]"

data:extend({
  slug_shell,
  emp_missile
})
