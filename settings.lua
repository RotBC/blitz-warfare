data:extend({
  {
    type = "int-setting",
    name = "blitz-dash-cooldown",
    setting_type = "runtime-global",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 30,
    order = "a-1"
  },
  {
    type = "int-setting",
    name = "blitz-shield-cooldown",
    setting_type = "runtime-global",
    default_value = 15,
    minimum_value = 3,
    maximum_value = 60,
    order = "a-2"
  },
  {
    type = "int-setting",
    name = "blitz-turret-cooldown",
    setting_type = "runtime-global",
    default_value = 25,
    minimum_value = 5,
    maximum_value = 120,
    order = "a-3"
  }
})
