local Custom_Input_Constants = require("libs.constants.custom-input-constants")

local satellite_target = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
satellite_target.name = "satellite-target"

-- log(serpent.block(satellite_target))

data:extend({
  -- satellite_target
  {
    type = "artillery-flare",
    name = "satellite-flare",
    icon = "__core__/graphics/shoot-cursor-green.png",
    flags = { "placeable-off-grid", "not-on-map" },
    hidden = true,
    map_color = { 1, 0.5, 0 },
    life_time = 60 * 60,
    initial_height = 0,
    initial_vertical_speed = 0,
    initial_frame_speed = 1,
    shots_per_flare = 0,
    early_death_ticks = 3 * 60,
    pictures =
    {
      {
        filename = "__core__/graphics/shoot-cursor-green.png",
        priority = "low",
        width = 258,
        height = 183,
        scale = 1,
        flags = { "icon" }
      }
    },
    trigger_created_entity = true,
    trigger_effect = { type = "script", effect_id = Custom_Input_Constants.SCAN_SELECTED_CHUNK.name },
    regular_trigger_effect = { type = "script", effect_id = Custom_Input_Constants.SCAN_SELECTED_CHUNK.name }
  },
})