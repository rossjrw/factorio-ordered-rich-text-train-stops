require("scripts/rich-text-sort")
require("scripts/train-schedule")
require("scripts/train-stop-list-ui")

-- Construct list when locomotive UI is opened
script.on_event(
  defines.events.on_gui_opened,
  function(event)
    if event.entity == nil then return end
    if event.entity.type ~= "locomotive" then return end

    local player = game.get_player(event.player_index)
    if player == nil then return end

    make_train_stop_list_ui(player, event.entity)
  end
)

-- Destroy list when locomotive UI is closed
script.on_event(
  defines.events.on_gui_closed,
  function(event)
    if event.entity == nil then return end
    if event.entity.type ~= "locomotive" then return end

    local player = game.get_player(event.player_index)
    if player == nil then return end

    destroy_train_stop_list_ui(player)
  end
)

-- Add train to stop on button click
script.on_event(
  defines.events.on_gui_click,
  function(event)
    if event.element.tags == nil then return end
    if event.element.tags["action"] ~= "add_train_stop_to_schedule" then return end

    local player = game.get_player(event.player_index)
    if player == nil then return end

    ---@diagnostic disable-next-line: param-type-mismatch
    add_stop_to_train_schedule(player.opened, event.element.caption)
  end
)
