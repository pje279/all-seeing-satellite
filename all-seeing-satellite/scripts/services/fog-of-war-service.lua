-- If already defined, return
if _fog_of_war_service and _fog_of_war_service.all_seeing_satellite then
  return _fog_of_war_service
end

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Log = require("libs.log.log")
local Planet_Utils = require("scripts.utils.planet-utils")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")

local fog_of_war_service = {}

--- @param planet planet-data
function fog_of_war_service.toggle_FoW(planet)
  Log.debug("fog_of_war_controller.toggle_FoW")
  Log.info(planet)

  if (not planet or not planet.valid) then return end
  if (not planet.surface or not planet.surface.valid) then return end

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.name)
  if (not satellite_meta_data.valid) then return end
  local player = satellite_meta_data.satellite_toggled_by_player
  local satellite_toggle_data = satellite_meta_data.satellites_toggled

  if (  satellite_toggle_data
    and satellite_toggle_data.toggle
    and player
    and player.valid
    and player.force
    and player.force.valid
    and player.surface
    and player.surface.valid
    and player.surface.name == satellite_toggle_data.planet_name)
  then
    if (Planet_Utils.allow_toggle(satellite_toggle_data.planet_name)) then
      game.forces[player.force.index].rechart(player.surface)
      return
    end
  end
end

fog_of_war_service.all_seeing_satellite = true

local _fog_of_war_service = fog_of_war_service

return fog_of_war_service