data:extend({
  {
    type = "technology",
    name = "blitz-advanced-warfare",
    icon = "__base__/graphics/technology/military.png",
    icon_size = 256,
    effects = {
      {type = "unlock-recipe", recipe = "blitz-emp-launcher"},
      {type = "unlock-recipe", recipe = "blitz-emp-missile"}
    },
    prerequisites = {"military"},
    unit = {
      count = 50,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    },
    order = "e-a-a"
  }
})
