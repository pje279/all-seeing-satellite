local All_Seeing_Satellite_Controller = require("control.controllers.all-seeing-satellite-controller")
local Constants = require("libs.constants.constants")
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local Fog_Of_War_Controller = require("control.controllers.fog-of-war-controller")
local Log = require("libs.log.log")
local Planet_Controller = require("control.controllers.planet-controller")
local Rocket_Silo_Controller = require("control.controllers.rocket-silo-controller")
local Satellite_Controller = require("control.controllers.satellite-controller")
local Scan_Chunk_Controller = require("control.controllers.scan-chunk-controller")
local Settings_Controller = require("control.controllers.settings-controller")
local Settings_Constants = require("libs.constants.settings-constants")

local nth_tick

if (not nth_tick or nth_tick.value <= 0) then
  nth_tick = Settings_Constants.settings.NTH_TICK.value
end

--
-- Register events

Log.info("Registering events")

script.on_init(init)

script.on_event(defines.events.on_tick, All_Seeing_Satellite_Controller.do_tick)

script.on_event(Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name, Fog_Of_War_Controller.toggle)
script.on_event(Custom_Input_Constants.TOGGLE_SCANNING.name, Fog_Of_War_Controller.toggle_scanning)
script.on_event(Custom_Input_Constants.CANCEL_SCANNING.name, Fog_Of_War_Controller.cancel_scanning)

script.on_event(defines.events.on_surface_created, Planet_Controller.on_surface_created)

script.on_event(defines.events.on_rocket_launch_ordered, Satellite_Controller.track_satellite_launches_ordered)

script.on_event(defines.events.on_runtime_mod_setting_changed, Settings_Controller.mod_setting_changed)

script.on_event(defines.events.on_player_selected_area, Scan_Chunk_Controller.stage_selected_chunk)
script.on_event(defines.events.on_player_controller_changed, function (event)
  -- Log.error(event)
  -- if (not storage.player_controllers) then storage.player_controllers = {} end
  -- storage.player_controllers[event.player_index] = event.old_type

  -- local player = game.get_player(chunk_to_chart.player_index)
  -- if (player) then
  --   player.set_controller({ type = defines.controllers.god })
  --   return
  -- end

end)

-- rocket-silo tracking
script.on_event(defines.events.on_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_built, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_revive, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_entity_died, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_destroy, Rocket_Silo_Controller.rocket_silo_mined_script, Rocket_Silo_Controller.filter)

Log.info("Finished registering events")