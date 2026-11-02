data:extend({
  {
    type = "recipe",
    name = "blitz-combat-shotgun",
    enabled = true,
    energy_required = 3,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 15},
      {type = "item", name = "iron-gear-wheel", amount = 5}
    },
    results = {{type = "item", name = "blitz-combat-shotgun", amount = 1}}
  },
  {
    type = "recipe",
    name = "blitz-tactical-rifle",
    enabled = true,
    energy_required = 4,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 20},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "copper-plate", amount = 10}
    },
    results = {{type = "item", name = "blitz-tactical-rifle", amount = 1}}
  },
  {
    type = "recipe",
    name = "blitz-slug-shell",
    enabled = true,
    energy_required = 2,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 3},
      {type = "item", name = "copper-plate", amount = 2}
    },
    results = {{type = "item", name = "blitz-slug-shell", amount = 2}}
  },
  {
    type = "recipe",
    name = "blitz-emp-launcher",
    enabled = false,
    energy_required = 8,
    ingredients = {
      {type = "item", name = "steel-plate", amount = 10},
      {type = "item", name = "electronic-circuit", amount = 10}
    },
    results = {{type = "item", name = "blitz-emp-launcher", amount = 1}}
  },
  {
    type = "recipe",
    name = "blitz-emp-missile",
    enabled = false,
    energy_required = 4,
    ingredients = {
      {type = "item", name = "electronic-circuit", amount = 4},
      {type = "item", name = "copper-plate", amount = 5},
      {type = "item", name = "iron-plate", amount = 5}
    },
    results = {{type = "item", name = "blitz-emp-missile", amount = 1}}
  }
})
