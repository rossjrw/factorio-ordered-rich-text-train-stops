--- Adds a stop to a locomotive's schedule and returns the stop's index.
---@param locomotive LuaEntity
---@param stop_name string
---@param temporary boolean?
---@return int?
function add_stop_to_train_schedule(locomotive, stop_name, temporary)
  local train = locomotive.train
  if train == nil then return end
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

---@param locomotive LuaEntity
---@param stop_index int
function remove_stop_from_train_schedule(locomotive, stop_index)
  local train = locomotive.train
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

---@param locomotive LuaEntity
---@param stop_name string
---@return boolean
function stop_is_accessible_to_train(locomotive, stop_name)
  local train = locomotive.train
  if train == nil then return false end

  -- Get the train's current state
  local current_stop_index = nil
  if train.schedule ~= nil then
    current_stop_index = train.schedule.current
  end
  local manual_mode = train.manual_mode

  -- Instruct train to go to the station
  -- If this results in a path being assigned, the stop is accessible
  local test_stop_index = add_stop_to_train_schedule(locomotive, stop_name, true)
  if test_stop_index == nil then return false end
  train.go_to_station(test_stop_index)
  local accessible = train.has_path

  -- Revert train back to its state before the test
  if current_stop_index ~= nil then
    train.go_to_station(current_stop_index)
  end
  train.manual_mode = manual_mode
  remove_stop_from_train_schedule(locomotive, test_stop_index)

  return accessible
end
