local Constants = require("libs.constants.constants")
local Fog_Of_War = require("control.event.fog-of-war")
local Log = require("libs.log")
local Planet = require("control.event.planet")
local Rocket_Silo = require("control.event.rocket-silo")
local Rocket_Utils = require("libs.utils.rocket-utils")
local Satellite = require("control.event.satellite")
local Settings_Changed = require("control.event.settings-changed")

local nth_tick

if (not nth_tick or nth_tick.value <= 0) then
  nth_tick = Constants.ON_NTH_TICK.value
end

--
-- Register events

Log.info("Registering events")

script.on_init(init)

script.on_nth_tick(nth_tick + 1, Fog_Of_War.toggle_FoW)
script.on_event("all-seeing-satellite-toggle", Fog_Of_War.toggle)

script.on_event(defines.events.on_surface_created, Planet.on_surface_created)

script.on_nth_tick(nth_tick, Rocket_Utils.launch_rocket)

script.on_event(defines.events.on_tick, Satellite.check_for_expired_satellites)
script.on_event(defines.events.on_rocket_launch_ordered, Satellite.track_satellite_launches_ordered)

script.on_event(defines.events.on_runtime_mod_setting_changed, Settings_Changed.mod_setting_changed)

-- rocket-silo tracking
script.on_event(defines.events.on_built_entity, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.script_raised_built, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.script_raised_revive, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo.rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo.rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_entity_died, Rocket_Silo.rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.script_raised_destroy, Rocket_Silo.rocket_silo_mined_script, {{ filter = "type", type = "rocket-silo" }})


Log.info("Finished registering events")