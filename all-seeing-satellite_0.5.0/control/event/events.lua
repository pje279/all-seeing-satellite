local Constants = require("libs.constants.constants")
local Fog_Of_War = require("control.event.fog-of-war")
local Log = require("libs.log.log")
local Planet = require("control.event.planet")
-- local Rocket_Silo = require("control.event.rocket-silo")
local Rocket_Silo_Controller = require("control.controllers.rocket-silo-controller")
-- local Rocket_Utils = require("libs.utils.rocket-utils")
local Satellite = require("control.event.satellite")
local Satellite_Controller = require("control.controllers.satellite-controller")
local Scan_Chunk_Controller = require("control.controllers.scan-chunk-controller")
local Settings_Changed = require("control.event.settings-changed")
local Settings_Constants = require("libs.constants.settings-constants")

local nth_tick

if (not nth_tick or nth_tick.value <= 0) then
  nth_tick = Constants.ON_NTH_TICK.value
end

--
-- Register events

Log.info("Registering events")

script.on_init(init)

script.on_nth_tick(nth_tick + 1, Fog_Of_War.toggle_FoW)
script.on_event(Settings_Constants.HOTKEY_EVENT_NAME.name, Fog_Of_War.toggle)

script.on_event(defines.events.on_surface_created, Planet.on_surface_created)

-- script.on_nth_tick(nth_tick, Rocket_Utils.launch_rocket)
script.on_nth_tick(nth_tick, Rocket_Silo_Controller.launch_rocket)

-- script.on_event(defines.events.on_tick, Satellite.check_for_expired_satellites)
-- script.on_event(defines.events.on_rocket_launch_ordered, Satellite.track_satellite_launches_ordered)
script.on_nth_tick(nth_tick + 2, Satellite_Controller.check_for_expired_satellites)
script.on_event(defines.events.on_rocket_launch_ordered, Satellite_Controller.track_satellite_launches_ordered)

script.on_event(defines.events.on_runtime_mod_setting_changed, Settings_Changed.mod_setting_changed)

script.on_event(defines.events.on_player_selected_area, Scan_Chunk_Controller.scan_selected_chunk)

-- rocket-silo tracking
-- script.on_event(defines.events.on_built_entity, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.on_robot_built_entity, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.script_raised_built, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.script_raised_revive, Rocket_Silo.rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.on_player_mined_entity, Rocket_Silo.rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo.rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.on_entity_died, Rocket_Silo.rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
-- script.on_event(defines.events.script_raised_destroy, Rocket_Silo.rocket_silo_mined_script, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_built, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_revive, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_entity_died, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_destroy, Rocket_Silo_Controller.rocket_silo_mined_script, Rocket_Silo_Controller.filter)


Log.info("Finished registering events")