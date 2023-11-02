--- Construct list UI
---@param player LuaPlayer
---@param locomotive LuaEntity
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
---@param player LuaPlayer
function destroy_train_stop_list_ui(player)
  if player == nil then return end
  if not player.gui.relative.train_stop_list_container then return end
  player.gui.relative.train_stop_list_container.destroy()
end
