require("scripts/rich-text-sort")
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
    add_stop_to_train_schedule(player.opened, event.element.caption)
  end
)

--- Construct list UI
function make_train_stop_list_ui(player, locomotive)
  if player.gui.relative.train_stop_list_container ~= nil then
    destroy_train_stop_list_ui(player)
  end

  local container = player.gui.relative.add({
    name = "train_stop_list_container",
    type = "frame",
    anchor = {
      gui = defines.relative_gui_type.train_gui,
      position = defines.relative_gui_position.left
    },
    caption = "Train stops",
    direction = "vertical"
  })
  container.style.vertically_stretchable = true

  local info_label = container.add({
    type = "label",
    caption = "Sorted with rich text icons ordered by inventory position. Click to add stop to the schedule"
  })
  info_label.style.single_line = false
  info_label.style.maximal_width = 300


  local list_container = container.add({
    name = "train_stop_list_container",
    type = "frame",
    style = "inside_deep_frame",
    direction = "vertical"
  })
  list_container.style.vertically_stretchable = true

  local list = list_container.add({
    name = "train_stop_list",
    type = "scroll-pane",
    style = "scroll_pane_with_dark_background_under_subheader",
    direction = "vertical"
  })
  list.style.vertically_stretchable = true
  list.style.minimal_width = 250
  list.style.maximal_width = 300

  -- Get list of train stops and sort them, respecting rich text
  surface_train_stops = game.get_train_stops({
    surface = locomotive.surface
  })
  table.sort(
    surface_train_stops,
    function(stop_1, stop_2)
      return sort_rich_text_strings(game, stop_1.backer_name, stop_2.backer_name)
    end
  )
  for index, train_stop in ipairs(surface_train_stops) do
    local button = list.add({
      type = "button",
      name = "train_stop_button_" .. index,
      tags = { action = "add_train_stop_to_schedule" },
      caption = train_stop.backer_name,
      style = "list_box_item"
    })
    button.style.horizontally_stretchable = true
  end
end

-- Destroy list UI
function destroy_train_stop_list_ui(player)
  if player == nil then return end
  if not player.gui.relative.train_stop_list_container then return end
  player.gui.relative.train_stop_list_container.destroy()
end

function add_stop_to_train_schedule(locomotive, stop_name)
  if locomotive.train == nil then return end
  local train = locomotive.train
  local existing_schedule = train.schedule
  local new_schedule = {
    current = existing_schedule.current,
    records = {}
  }
  for _, record in pairs(existing_schedule.records) do
    table.insert(new_schedule.records, record)
  end
  table.insert(new_schedule.records, {
    station = stop_name,
    wait_conditions = {}
  })
  train.schedule = new_schedule
end
