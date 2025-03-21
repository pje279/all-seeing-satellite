-- If already defined, return
if _rocket_utils and _rocket_utils.all_seeing_satellite then
  return _rocket_utils
end

local Constants = require("libs.constants.constants")
local Initialization = require("control.initialization")
local Log = require("libs.log")
local String_Utils = require("libs.utils.string-utils")
local Validations = require("libs.validations")

local rocket_utils = {}

function rocket_utils.mine_rocket_silo(event)
  local rocket_silo = event.entity

  if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not Validations.is_storage_valid()) then
      Log.warn("Storage is invalid; initializing")
      Initialization.init()
    else
      local surface_rocket_silos = storage.rocket_silos[rocket_silo.surface.name]

      for i=1, #surface_rocket_silos do
        if (surface_rocket_silos[i] and surface_rocket_silos[i].entity == rocket_silo) then
          table.remove(surface_rocket_silos, i)
        end
      end
    end
  end
end

function rocket_utils.add_rocket_silo(--[[required]]rocket_silo, --[[optional]]is_init)
  -- Validate inputs
  is_init = is_init or false -- default value

  if (not Validations.is_storage_valid()) then
    Log.warn("Storage is invalid; initializing")
    Initialization.init()
  end

  if (not storage.rocket_silos) then
    if (is_init) then
      Log.info("Initializing storage.rocket_silos")
      storage.rocket_silos = {}
    else
      Log.error("Storage is invalid; initializing")
      Initialization.init()
    end
    return
  end

  if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
    and not storage.rocket_silos[rocket_silo.surface.name])
  then
    storage.rocket_silos[rocket_silo.surface.name] = {}
  end

  if (storage.rocket_silos[rocket_silo.surface.name]) then
    table.insert(storage.rocket_silos[rocket_silo.surface.name], {
      unit_number = rocket_silo.unit_number,
      entity = rocket_silo,
      valid = rocket_silo.valid
    })
  else
    Log.error("This shouldn't be possible")
    Log.debug(rocket_silo.surface.name)
  end
end

function rocket_utils.launch_rocket(event)
  if (not Validations.is_storage_valid()) then
    Log.warn("Storage is invalid; initializing")
    Initialization.init()
  end

  local tick = event.tick
  local nth_tick = event.nth_tick

  local tick_mod = tick % nth_tick

  if (storage.rocket_silos) then
    for _, planet in pairs(Constants.get_planets(false)) do
      for _, rocket_silo_unit_numbers in pairs(storage.rocket_silos) do
        for i=1, #rocket_silo_unit_numbers do
          local rocket_silos = storage.rocket_silos[planet.name]
          local rocket_silo = nil

          if (rocket_silos and rocket_silos[i] and rocket_silos[i].entity) then
            rocket_silo = rocket_silos[i].entity
          end

          if (rocket_silo and rocket_silo.valid) then
            local inventory = rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
            if (inventory) then
              for _, item in ipairs(inventory.get_contents()) do
                if (item.name == "satellite") then
                  local rocket = rocket_silo.rocket

                  if (rocket and rocket.valid) then
                    local cargo_pod = rocket.attached_cargo_pod

                    if (cargo_pod and cargo_pod.valid) then
                      cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.orbit }
                    end
                  end

                  if (rocket_silo.launch_rocket()) then
                    Log.info("Launched satellite: " .. serpent.block(rocket_silo))
                  else
                    Log.info("Failed to launch satellite: " .. serpent.block(rocket_silo))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

rocket_utils.all_seeing_satellite = true

local _rocket_utils = rocket_utils

return rocket_utils