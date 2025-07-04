-- If already defined, return
if _player_controller and _player_controller.all_seeing_satellite then
  return _player_controller
end

local Character_Repository = require("scripts.repositories.character-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Planet_Utils = require("scripts.utils.planet-utils")
local Player_Service = require("scripts.services.player-service")
local Player_Repository = require("scripts.repositories.player-repository")
local Research_Utils = require("scripts.utils.research-utils")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Settings_Service = require("scripts.services.settings-service")
local String_Utils = require("scripts.utils.string-utils")

local player_controller = {}

player_controller.filter = {{ filter = "name", name = "character" }}

function player_controller.toggle_satellite_mode(event)
  Log.debug("player_controller.toggle_satellite_mode")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player = game.get_player(event.player_index)
  if (not player or not player.valid) then return end

  local surface = player.surface
  if (not surface or not surface.valid) then return end

  if (String_Utils.find_invalid_substrings(surface.name)) then
    player.print("Satellite mode is currently not allowed")
    return
  end

  local player_data = Player_Repository.get_player_data(event.player_index)
  if (not player_data.valid) then
    player_data = Player_Repository.save_player_data(event.player_index)
    if (not player_data.valid) then
      player.print("Satellite mode is currently not allowed")
      return
    end
  end

  if (player_data.in_space) then
    player.print("Satellite mode is currently not allowed")
    return
  end

  local allow_satellite_mode = false
  if (player.controller_type == defines.controllers.god) then
    allow_satellite_mode = true
  end

  if (not allow_satellite_mode and not Research_Utils.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
    if (Settings_Service.get_restrict_satellite_mode()) then
      player.print("Rocket Silo/Satellite not researched yet")
      return
    end
  end

  if (not allow_satellite_mode and not Planet_Utils.allow_satellite_mode(surface.name)) then
    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface.name)
    if (not satellite_meta_data.valid) then
      player.print("Satellite mode is currently not allowed")
      return
    end
    player.print("Insufficient satellite(s) orbiting "
      .. surface.name
      .. " : "
      .. satellite_meta_data.satellites_in_orbit
      .. " orbiting, "
      .. Planet_Utils.planet_launch_threshold(surface.name)
      .. " minimum"
    )
    return
  end

  if (not allow_satellite_mode and not player_data.satellite_mode_allowed) then
    if (player_data.in_space or Settings_Service.get_restrict_satellite_mode()) then
      player.print("Satellite mode is currently not allowed")
      return
    end
  end

  Player_Service.toggle_satellite_mode(event)
end

function player_controller.player_created(event)
  Log.debug("player_controller.player_created")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.pre_player_died(event)
  Log.debug("player_controller.pre_player_died")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.player_died(event)
  Log.debug("player_controller.player_died")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.entity_died(event)
  Log.debug("player_controller.entity_died")
  Log.info(event)

  if (not event) then return end
  if (not event.entity or not event.entity.name) then return end
  if (event.entity.name ~= "character") then return end

  local all_character_data = Character_Repository.get_all_character_data()

  local character_data = nil

  for _, _character_data in pairs(all_character_data) do
    if (_character_data.unit_number == event.entity.unit_number) then
      character_data = _character_data
      break
    end
  end

  if (character_data) then
    local player = game.get_player(character_data.player_index)
    if (not player or not player.valid) then return end

    if (player.controller_type == defines.controllers.character) then return end

    local player_data = Player_Repository.get_player_data(player.index)
    if (not player_data or not player_data.valid) then return end

    if (player_data.satellite_mode_toggled) then
      Player_Service.disable_satellite_mode_and_die({ player_index = character_data.player_index, character = event.entity })
    end
  end
end

function player_controller.player_respawned(event)
  Log.debug("player_controller.player_respawned")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.player_joined_game(event)
  Log.debug("player_controller.player_joined_game")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.update_player_data({ player_index = event.player_index })
end

function player_controller.pre_player_left_game(event)
  Log.debug("player_controller.pre_player_left_game")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.pre_player_removed(event)
  Log.debug("player_controller.pre_player_removed")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.delete_player_data(event.player_index)
end

function player_controller.surface_cleared(event)
  Log.debug("player_controller.surface_cleared")
  Log.info(event)

  if (not event) then return end
  if (not event.surface_index) then return end

  local all_player_data = Player_Repository.get_all_player_data()

  for player_index, player_data in pairs(all_player_data) do
    if (player_data.surface_index and player_data.surface_index == event.surface_index) then
      Player_Repository.save_player_data(player_index)
    end
  end
end

function player_controller.surface_deleted(event)
  Log.debug("player_controller.surface_deleted")
  Log.info(event)

  if (not event) then return end
  if (not event.surface_index) then return end

  local all_player_data = Player_Repository.get_all_player_data()

  for player_index, player_data in pairs(all_player_data) do
    if (player_data.surface_index and player_data.surface_index == event.surface_index) then
      Player_Repository.save_player_data(player_index)
    end
  end
end

function player_controller.changed_surface(event)
  Log.debug("player_controller.changed_surface")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end
  if (not event.surface_index) then return end
  if (not event.launched_by_rocket) then return end
  local player = game.get_player(event.player_index)

  if (player.controller_type == defines.controllers.character) then
    Log.debug("1")
    Player_Repository.save_player_data(event.player_index)
  elseif (player.controller_type == defines.controllers.remote) then
    Log.debug("2")
  elseif (player.controller_type == defines.controllers.god) then
    Log.debug("3")
  else
    Log.debug("4")
  end
end

function player_controller.cargo_pod_finished_ascending(event)
  Log.debug("player_controller.cargo_pod_finished_ascending")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.cargo_pod_finished_descending(event)
  Log.debug("player_controller.cargo_pod_finished_descending")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player_data = Player_Repository.get_player_data(event.player_index)
  if (not player_data.valid) then return end -- This should, in theory, only happen if the player does not exist

  if (not event.launched_by_rocket) then
    player_data.in_space = false
    player_data.satellite_mode_allowed = player_data.satellite_mode_stashed
    Player_Repository.save_player_data(event.player_index)
  end
end

function player_controller.rocket_launch_ordered(event)
  Log.debug("player_controller.rocket_launch_ordered")
  Log.info(event)

  if (not event) then return end
  if (not event.rocket or not event.rocket.valid) then return end
  local rocket = event.rocket
  if (not rocket.cargo_pod or not rocket.cargo_pod.valid) then return end
  local cargo_pod = rocket.cargo_pod
  local passenger = cargo_pod.get_passenger()
  if (not passenger or not passenger.valid) then return end

  if (passenger and passenger.valid and passenger.player and passenger.player.valid) then
    local player_data = Player_Repository.get_player_data(passenger.player.index)

    if (not player_data.valid) then return end -- This should, in theory, only happen if the player does not exist

    player_data.in_space = true
    player_data.satellite_mode_stashed = player_data.satellite_mode_stashed or player_data.satellite_mode_allowed
    player_data.satellite_mode_allowed = false
    Player_Repository.save_player_data(passenger.player.index)
  end
end

function player_controller.player_toggled_map_editor(event)
  Log.debug("player_controller.player_toggled_map_editor")
  Log.info(event)

  if (not game) then return end
  if (not event) then return end
  if (not event.player_index) then return end

  local player_data = Player_Repository.get_player_data(event.player_index)
  if (not player_data.valid) then
    player_data = Player_Repository.save_player_data(event.player_index)
    if (not player_data.valid) then return end
  end

  if (not player_data.editor_mode_toggled) then
    if (not player_data.character_data.character or not player_data.character_data.character.valid) then
      local character_data = Character_Repository.save_character_data(player_data.player_index)
      if (character_data.valid) then
        Player_Repository.update_player_data({
          player_index = player_data.player_index,
          satellite_mode_allowed = player_data.satellite_mode_stashed,
        })
      end
    else
      Player_Repository.update_player_data({
        player_index = player_data.player_index,
        satellite_mode_allowed = player_data.satellite_mode_stashed,
      })
    end
  end
end

function player_controller.pre_player_toggled_map_editor(event)
  Log.debug("player_controller.pre_player_toggled_map_editor")
  Log.info(event)

  if (not game) then return end
  if (not event) then return end
  if (not event.player_index) then return end
  local player = game.get_player(event.player_index)
  if (not player or not player.valid) then return end
  local surface = player.surface
  if (not surface or not surface.valid) then return end

  local player_data = Player_Repository.get_player_data(event.player_index)
  if (not player_data.valid) then
    player_data = Player_Repository.save_player_data(event.player_index)
    if (not player_data.valid) then return end
  end

  if (player_data.editor_mode_toggled) then
    Player_Repository.update_player_data({
      player_index = player_data.player_index,
      editor_mode_toggled = false,
      satellite_mode_allowed = player_data.satellite_mode_stashed,
    })
  elseif (not player_data.editor_mode_toggled) then
    if (player_data.satellite_mode_toggled) then
      Player_Service.toggle_satellite_mode(event)
    end
    Player_Repository.update_player_data({
      player_index = player_data.player_index,
      force_index_stashed = player_data.force_index,
      satellite_mode_stashed = player_data.satellite_mode_stashed or player_data.satellite_mode_allowed,
      satellite_mode_allowed = false,
      editor_mode_toggled = true,
    })
  end
end

function player_controller.cutscene_cancelled(event)
  Log.debug("player_controller.cutscene_cancelled")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index or event.player_index < 1) then return end

  Player_Repository.save_player_data(event.player_index)
end

function player_controller.cutscene_finished(event)
  Log.debug("player_controller.cutscene_finished")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index or event.player_index < 1) then return end

  Player_Repository.save_player_data(event.player_index)
end

player_controller.all_seeing_satellite = true

local _player_controller = player_controller

return player_controller