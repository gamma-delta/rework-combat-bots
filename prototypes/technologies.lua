data:extend{{
  type = "technology",
  name = "pkrcb-combat-robotics",
  icon = "__base__/graphics/technology/follower-robots.png",
  icon_size = 256,
  prerequisites = {
    "space-science-pack",
    "robotics",
    "military-3",
  },
  unit = {
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"space-science-pack", 1}
    },
    -- Make it cheap cause it doesn't actually do anything
    count = 50,
    time = 30,
  },
  effects = {
    {
      type = "maximum-following-robots-count",
      modifier = 5,
    }
  }
}}

local defender = data.raw["technology"]["defender"]
local distractor = data.raw["technology"]["distractor"]
local destroyer = data.raw["technology"]["destroyer"]

defender.prerequisites = {
  "pkrcb-combat-robotics",
  "metallurgic-science-pack",
}
defender.unit.count = 1000
defender.unit.ingredients = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"military-science-pack", 1},
  {"chemical-science-pack", 1},
  {"space-science-pack", 1},
  {"metallurgic-science-pack", 1},
}

distractor.prerequisites = {
  "pkrcb-combat-robotics",
  "jellynut",
}
distractor.unit.count = 250
distractor.unit.ingredients = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"military-science-pack", 1},
  {"chemical-science-pack", 1},
  {"space-science-pack", 1},
}

destroyer.prerequisites = {
  "pkrcb-combat-robotics",
  "tesla-weapons",
}
-- Tesla ammo takes 1500
destroyer.unit.count = 1000
destroyer.unit.ingredients = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"military-science-pack", 1},
  {"chemical-science-pack", 1},
  {"space-science-pack", 1},
  {"electromagnetic-science-pack", 1},
}

-- The follower robot count techs are weirdly hard-coded
-- Each robot is more valuable so make them all do +5
for i = 1,5 do
  local upgrade_tech = data.raw["technology"]["follower-robot-count-" .. i]
  for _,effect in ipairs(upgrade_tech.effects) do
    if effect.type == "maximum-following-robots-count" then
      effect.modifier = 5
    end
  end
  upgrade_tech.prerequisites = {
    "pkrcb-combat-robotics",
  }
  if i > 1 then
    table.insert(upgrade_tech.prerequisites, "follower-robot-count-" .. (i - 1))
  end
  upgrade_tech.unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"military-science-pack", 1},
    {"chemical-science-pack", 1},
    {"space-science-pack", 1}
  }
  if i >= 3 then
    table.insert(upgrade_tech.unit.ingredients, {"utility-science-pack", 1})
  end
end
local infinite_tech = data.raw["technology"]["follower-robot-count-5"]
for _,effect in ipairs(infinite_tech.effects) do
  if effect.type == "maximum-following-robots-count" then
    effect.modifier = 5
  end
end

