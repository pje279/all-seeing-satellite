-- If already defined, return
if _planet_utils and _planet_utils.all_seeing_satellite then
  return _planet_utils
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Settings_Constants = require("libs.constants.settings-constants")
local Settings_Service = require("control.services.settings-service")
local Storage_Service = require("control.services.storage-service")
-- local Validations = require("control.validations.validations")

local planet_utils = {}

function planet_utils.allow_toggle(surface_name)
  if (not Settings_Service.get_require_satellites_in_orbit()) then return true end

  if (surface_name) then
    return  Storage_Service.is_storage_valid()
        and Storage_Service.get_satellites_launched(surface_name) >= planet_utils.planet_launch_threshold(surface_name)
  end
  return false
end

function planet_utils.planet_launch_threshold(surface_name)
  if (not surface_name) then
    -- Intentionally calling with nil parameter to each, so as to get the default_value for each setting
    return Settings_Service.get_global_launch_satellite_threshold() * Settings_Service.get_global_launch_satellite_threshold_modifier()
  end

  local planet_magnitude = get_planet_magnitude(surface_name)
  local return_val = Settings_Service.get_global_launch_satellite_threshold(surface_name) * Settings_Service.get_global_launch_satellite_threshold_modifier(surface_name) * planet_magnitude^2

  if (planet_magnitude < 1) then
    Log.debug("floor")
    return_val = math.floor(return_val)
  else
    Log.debug("ceil")
    return_val = math.ceil(return_val)
  end

  return return_val
end

function planet_utils.allow_scan(surface_name)
  if (not Settings_Service.get_restrict_satellite_scanning()) then return true end

  if (surface_name) then
    return  Storage_Service.is_storage_valid()
        and Storage_Service.get_satellites_launched(surface_name)
        and Storage_Service.get_satellites_launched(surface_name) > 0
  end
  return false
end

function get_planet_magnitude(surface_name)
  local planets = Constants.get_planets()
  local planet_magnitude = 1

  if (planets) then
    for _, planet in ipairs(planets) do
      if (planet and planet.name == surface_name) then
        planet_magnitude = planet.magnitude
        break
      end
    end
  end

  Log.info(planet_magnitude)

  if (not planet_magnitude) then
    planet_magnitude = 1
  end

  return planet_magnitude
end

planet_utils.all_seeing_satellite = true

local _planet_utils = planet_utils

return planet_utils