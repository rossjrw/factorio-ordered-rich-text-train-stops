--- Construct list UI
---@param player LuaPlayer
---@param locomotive LuaEntity
function make_train_stop_list_ui(player, locomotive)
  if player.gui.relative.train_stop_list_container ~= nil then
    destroy_train_stop_list_ui(player)
  end

  local train = locomotive.train
  if train == nil then return false end

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
  local train_stops = {}
  for _, train_stop in pairs(game.get_train_stops({
    surface = locomotive.surface
  })) do
    -- If a train stop with this name was already processed, just increment its count
    local seen_stop_with_name = false
    for index = 1, #train_stops do
      if train_stops[index].name == train_stop.backer_name then
        train_stops[index].count = train_stops[index].count + 1
        seen_stop_with_name = true
        break
      end
    end
    if not seen_stop_with_name then
      -- Otherwise register this stop and check its accessibility
      -- Note that accessibility check is per name, not per stop, so it only needs to be performed once for each stop name
      table.insert(
        train_stops,
        {
          name = train_stop.backer_name,
          stop = train_stop,
          count = 1,
          accessible = stop_is_accessible_to_train(train, train_stop.backer_name)
        }
      )
    end
  end

  -- Sort list of stops by their name and accessibility to this train
  table.sort(
    train_stops,
    function(stop_1, stop_2)
      if stop_1.accessible and not stop_2.accessible then return true end
      if not stop_1.accessible and stop_2.accessible then return false end
      return sort_rich_text_strings(game, stop_1.name, stop_2.name)
    end
  )

  -- Create a button in the UI for each stop
  local button_container = list.add({
    type = "table",
    column_count = 2,
    name = "train_stop_button_container"
  })
  button_container.style.horizontally_stretchable = true
  for index, train_stop in ipairs(train_stops) do
    local button = button_container.add({
      type = "button",
      name = "train_stop_button_" .. index,
      tags = { action = "add_train_stop_to_schedule" },
      caption = train_stop.stop.backer_name,
      style = (
        train_stop.accessible and "list_box_item" or "not_accessible_station_in_station_selection"
      )
    })
    button.style.horizontally_stretchable = true
    button.style.horizontally_squashable = true
    button.style.bottom_margin = -4

    if train_stop.count > 1 then
      local count = button_container.add({
        type = "label",
        name = "train_stop_button_" .. index .. "_count",
        caption = train_stop.count
      })
      count.style.left_margin = -20
      button.style.right_padding = 28
    else
      button_container.add({
        type = "empty-widget"
      })
    end
  end
end

-- Destroy list UI
---@param player LuaPlayer
function destroy_train_stop_list_ui(player)
  if player == nil then return end
  if player.gui.relative.train_stop_list_container == nil then return end
  player.gui.relative.train_stop_list_container.destroy()
end
