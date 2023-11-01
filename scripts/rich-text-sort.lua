-- Ordering behaviour for each tag type from https://wiki.factorio.com/Rich_text
local rich_text_tags = {
  {
    tag = "technology",
    prototypes = "technology_prototypes",
    order = function(p) return p.order end
  },
  {
    tag = "item-group",
    prototypes = "item_group_prototypes",
    order = function(p)
      if p.group == nil then return p.order end
      return p.group.order .. p.order
    end
  },
  {
    tag = "tile",
    prototypes = "tile_prototypes",
    order = function(p) return p.order end
  },
  {
    tag = "virtual-signal",
    prototypes = "virtual_signal_prototypes",
    order = function(p) return p.subgroup.order .. p.order end
  },
  {
    tag = "achievement",
    prototypes = "achievement_prototypes",
    order = function(p) return p.order end
  },
  {
    tag = "item",
    prototypes = "item_prototypes",
    order = function(p) return p.group.order .. p.subgroup.order .. p.order end
  },
  {
    tag = "entity",
    prototypes = "entity_prototypes",
    order = function(p) return p.group.order .. p.subgroup.order .. p.order end
  },
  {
    tag = "recipe",
    prototypes = "recipe_prototypes",
    order = function(p) return p.group.order .. p.subgroup.order .. p.order end
  },
  {
    tag = "fluid",
    prototypes = "fluid_prototypes",
    order = function(p) return p.group.order .. p.subgroup.order .. p.order end
  },
}

---@param game LuaGameScript
---@param rich_text_string string
---@return string
function replace_rich_text_tags_with_order_strings(game, rich_text_string)
  local ordered_rich_text_string = string.gsub(
    rich_text_string,
    "%[([a-z]+)=(.-)%]", -- e.g. [item=item-id], [fluid=fluid-id]
    function(object_tag, object_id)
      for index, rich_text_tag in ipairs(rich_text_tags) do
        if object_tag == rich_text_tag.tag then
          local prototype = game[rich_text_tag.prototypes][object_id]
          if prototype == nil then break end

          -- Order string is appended with "!" to sort them before non-rich-text-tag strings.
          -- Index is added to preserve relative order between different tag types.
          return "!" .. index .. rich_text_tag.order(prototype)
        end
      end

      -- No matches - do not substitute
      return nil
    end
  )
  return ordered_rich_text_string
end

---@param game LuaGameScript
---@param rich_text_string_1 string
---@param rich_text_string_2 string
---@return boolean
function sort_rich_text_strings(game, rich_text_string_1, rich_text_string_2)
  return replace_rich_text_tags_with_order_strings(game, rich_text_string_1) <
  replace_rich_text_tags_with_order_strings(game, rich_text_string_2)
end
