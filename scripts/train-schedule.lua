--- Adds a stop to a locomotive's schedule and returns the stop's index.
---@param train LuaTrain
---@param stop_name string
---@param temporary boolean?
---@return int?
function add_stop_to_train_schedule(train, stop_name, temporary)
  local existing_schedule = train.schedule
  if existing_schedule == nil then
    existing_schedule = {
      current = 1,
      records = {}
    }
  end

  local new_schedule = {
    current = existing_schedule.current,
    records = {}
  }
  for _, record in pairs(existing_schedule.records) do
    table.insert(new_schedule.records, record)
  end
  table.insert(new_schedule.records, {
    station = stop_name,
    wait_conditions = {},
    temporary = temporary
  })
  train.schedule = new_schedule

  return #train.schedule.records
end

---@param train LuaTrain
---@param stop_index int
function remove_stop_from_train_schedule(train, stop_index)
  if train == nil then return end
  local schedule = train.schedule
  if schedule == nil then return end
  if schedule.current == stop_index and stop_index > 1 then
    schedule.current = stop_index - 1
  end
  table.remove(schedule.records, stop_index)
  if next(schedule.records) == nil then schedule = nil end
  train.schedule = schedule
end

---@param train LuaTrain
---@param stop_name string
---@return boolean
function stop_is_accessible_to_train(train, stop_name)
  -- Get the train's current state
  local current_stop_index = nil
  if train.schedule ~= nil then
    current_stop_index = train.schedule.current
  end
  local manual_mode = train.manual_mode

  -- Instruct train to go to the station
  -- If this results in a path being assigned, the stop is accessible
  local test_stop_index = add_stop_to_train_schedule(train, stop_name, true)
  if test_stop_index == nil then return false end
  train.go_to_station(test_stop_index)
  local accessible = train.has_path

  -- Revert train back to its state before the test
  if current_stop_index ~= nil then
    train.go_to_station(current_stop_index)
  end
  train.manual_mode = manual_mode
  remove_stop_from_train_schedule(train, test_stop_index)

  return accessible
end

---@param train LuaTrain
---@param stop_names string[]
---@return string[]
function get_accessible_stops_to_train(train, stop_names)
  game.print("Starting accessibility test")

  -- Create a virtual train to test stops with
  local locomotive = train.locomotives["front_movers"][1]
  game.print(locomotive)
  local surface = locomotive.surface
  game.print(surface)
  local virtual_locomotive = surface.create_entity({
    name = "locomotive",
    position = locomotive.position,
    direction = locomotive.direction,
    force = locomotive.force,
    fast_replace = false,
    raise_built = false,
    create_build_effect_smoke = false,
    move_stuck_players = false,
  })

  game.print("Created virtual locomotive")

  if virtual_locomotive == nil then return {} end
  local virtual_train = virtual_locomotive.train

  game.print("Created virtual train")

  -- Filter stops by accessibility to virtual train
  local filtered_train_stop_names = {}
  -- Filtering is wrapped in a protected call so that errors can be masked until cleanup has run
  local success, error_message = pcall(function()
    for _, stop_name in ipairs(stop_names) do
      if stop_is_accessible_to_train(virtual_train, stop_name) then
        table.insert(filtered_train_stop_names, stop_name)
      end
    end
  end)

  game.print("Completed filtering, found " .. #filtered_train_stop_names)

  -- Clean up by deleting the virtual train
  virtual_locomotive.destroy({})

  game.print("Destroyed virtual train")

  -- Unmask any errors from the filtering
  if not success then error(error_message) end

  return filtered_train_stop_names
end
