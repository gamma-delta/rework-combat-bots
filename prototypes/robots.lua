local sounds = require "__base__/prototypes/entity/sounds"

-- Make capsule bots good, and all the same tier, one per inner planet.

-- Defenders:
-- - From Vulcanus
-- - Stationary
-- - Basically like turret spam without needing to micro them
local defender = data.raw["combat-robot"]["defender"]
defender.is_military_target = true
defender.time_to_live = 30 * 60
defender.speed = 0
-- Still count against follower robot count
defender.follows_player = true
-- Give it low HP to discourage just yeeting it into a nest,
-- cause a spitter will blow it up
defender.max_health = 100
-- Slow it down to make it feel punchier?
defender.attack_parameters.cooldown = 35
defender.attack_parameters.ammo_type = 
  data.raw["ammo"]["uranium-rounds-magazine"].ammo_type
-- this is what the tank uses
defender.attack_parameters.sound = sounds.heavy_gunshot
-- How many are spawned is controlled in the *projectile*
-- Capsule item with throw effect ...
-- that creates a projectile ...
-- that spawns the combat-robot on reaching the target
data.raw["projectile"]["defender-capsule"]
  .action.action_delivery.target_effects[1]
  .offsets = {{0, -0.25}, {-0.25, 0.25}, {0.25, 0.25}}

-- Distractors:
-- - From Gleba
-- - Keep flying in the direction you shot them in
-- - Attract enemies to it
local distractor = data.raw["combat-robot"]["distractor"]
distractor.is_military_target = true
distractor.follows_player = true
-- run away!
-- it will always try to "return" to the player,
-- but because its speed is negative it will go the wrong way
distractor.range_from_player = 0.1
distractor.speed = -0.0015
-- so it doesn't accelerate forever
distractor.friction = 0.00001
-- same as a wall
distractor.max_health = 350
distractor.time_to_live = 15 * 60
distractor.attack_parameters = {
  type = "projectile",
  -- so it doesn't get bonuses
  ammo_category = "biological",
  cooldown = 1 * 60,
  cooldown_deviation = 0,
  range = 16,
  range_mode = "center-to-bounding-box",
  sound = nil,
  -- Not sure why it has to be nested like this
  -- See discharge-defense
  ammo_type = {
    type = "projectile",
    action = {
      {
        type = "area",
        radius = 8.0,
        force = "enemy",
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "script",
              effect_id = "pkrcb-distractor-capsule"
            }
          }
        }
      },
      -- TODO: direct trigger item with puff of smoke?
    }
  }
}
data.raw["projectile"]["distractor-capsule"]
  .action.action_delivery.target_effects[1].offsets = {{0, 0}}

-- Destroyers:
-- - From Fulgora
-- - Fire electric zappies that jump like the gun
-- - On death, explode into electric arcs
-- - Probably still the best capsule but what can I do
-- Frankly I was hoping to make this not hard-dep on SA,
-- but tesla ammo requires a LOT of infrastructure and I cba
local destroyer = data.raw["combat-robot"]["destroyer"]
destroyer.is_military_target = true
destroyer.time_to_live = 60 * 60
destroyer.max_health = 500
destroyer.attack_parameters.cooldown = 2 * 60
destroyer.attack_parameters.ammo_type = data.raw["ammo"]["tesla-ammo"].ammo_type
-- to not make it hideously overpowered, hopefully
destroyer.attack_parameters.damage_modifier = 0.5
-- for some reason this is not an array but the other two are
data.raw["projectile"]["destroyer-capsule"]
  .action.action_delivery.target_effects.offsets = {{-0.5, 0}, {0.5, 0}}

-- Give the player a warning before it explodes
-- Do this by !!SECRETLY!! replacing the entity with a different one
-- that does absolutely nothing and dies
local og_destroyer_death_effect = destroyer.dying_trigger_effect
-- Here's thing that actually does the friendly fire ...
local proposed_target_fx = table.deepcopy(og_destroyer_death_effect)
table.insert(
  proposed_target_fx,
  {
    type = "create-entity",
    entity_name = "destroyer-robot-explosion"
  }
)
data:extend{{
    type = "delayed-active-trigger",
    name = "pkrcb-destroyer-malfunction-splort",
    delay = 60,
    action = {
      {
        type = "area",
        radius = 6.0,
        -- Apply the tesla gun zap to every target in range. Blammo!
        -- This includes you, be careful
        action_delivery = data.raw["ammo"]["tesla-ammo"].ammo_type.action.action_delivery
      },
      {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = proposed_target_fx
        }
      },
    },
  }}
-- this one plays a spinning animation, waits a second,
-- then creates the splort above
-- in two different :extend calls because splort has to exist in the table
-- before this can use it
local destroyer_spin_count = 2
-- this needs to take exactly 60 ticks
local destroyer_ani_speed = 60 / 32 / destroyer_spin_count
data:extend{{
  type = "explosion",
  name = "pkrcb-destroyer-malfunction-sfx",
  flags = {"not-on-map"},
  hidden = true,
  subgroup = "capsule-explosions",
  -- after the normal exploder
  order = "c-c-b",

  -- Delay the explosion particle and friendly fire
  created_effect = {
    {
      type = "direct",
      action_delivery = {
        type = "delayed",
        delayed_trigger = "pkrcb-destroyer-malfunction-splort",
      }
    }
  },
  sound = {
    filename = "__base__/sound/spidertron/spidertron-deactivate.ogg",
    volume = 2.0,
    aggregation = {
      max_count = 1,
      remove = true,
      count_already_playing = true,
      priority = "newest",
    }
  },
  animations = {
    -- I'm in spain but the S is silent
    -- Use the bottom row of the spritesheet
    -- Unfortunately i cannot make it speed up spinning over time
   layers = {
      {
        filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
        priority = "high",
        line_length = 32,
        width = 88,
        height = 77,
        y = 77,
        frame_count = 32,
        shift = util.by_pixel(2.5, -1.25),
        scale = 0.5,
        repeat_count = destroyer_spin_count,
        animation_speed = destroyer_ani_speed,
      },
      {
        filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
        priority = "high",
        line_length = 32,
        width = 52,
        height = 42,
        y = 42,
        frame_count = 32,
        shift = util.by_pixel(2.5, -7),
        apply_runtime_tint = true,
        scale = 0.5,
        repeat_count = destroyer_spin_count,
        animation_speed = destroyer_ani_speed,
      }
    }
  }
}}
local destroyer_die_trigger = {
  {
      type = "create-entity",
      entity_name = "pkrcb-destroyer-malfunction-sfx"
  }
}
destroyer.dying_explosion = nil
-- vanilla combat bots do slightly different things when they expire
-- vs getting shot out of the sky.
-- but these both die the same way.
destroyer.dying_trigger_effect = destroyer_die_trigger
destroyer.destroy_action = {
  type="direct",
  action_delivery = {
    type = "instant",
    source_effects = destroyer_die_trigger
  }
}
