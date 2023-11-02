---@param locomotive LuaEntity
---@param stop_name string
function add_stop_to_train_schedule(locomotive, stop_name)
  local train = locomotive.train
  if train == nil then return end
  local existing_schedule = train.schedule
  if existing_schedule == nil then return end
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
