local defender = data.raw["recipe"]["defender-capsule"]
local distractor = data.raw["recipe"]["distractor-capsule"]
local destroyer = data.raw["recipe"]["destroyer-capsule"]

defender.energy_required = 5
distractor.energy_required = 5
destroyer.energy_required = 5

defender.ingredients = {
  {type="item", name="flying-robot-frame", amount=3},
  {type="item", name="electronic-circuit", amount=10},
  {type="item", name="piercing-rounds-magazine", amount=3},
  {type="item", name="tungsten-plate", amount=3},
}
distractor.ingredients = {
  {type="item", name="flying-robot-frame", amount=1},
  {type="item", name="electronic-circuit", amount=2},
  -- Yumako or jelly? not sure it really makes a difference
  -- But jelly makes you go fast when you eat it
  -- so that's thematic i guess
  {type="item", name="jelly", amount=5},
}
destroyer.ingredients = {
  {type="item", name="flying-robot-frame", amount=2},
  {type="item", name="electronic-circuit", amount=5},
  {type="item", name="tesla-ammo", amount=5},
}
