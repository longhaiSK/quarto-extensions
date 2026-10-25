-- Remove every {.sol} div when the document sets `show_solutions: false`
-- (in the YAML header or with `quarto render ... -M show_solutions:false`).
-- Solutions are shown when the option is absent or true.

local show = true

local function is_false(v)
  if v == nil then return false end
  if type(v) == 'boolean' then return not v end
  local s = pandoc.utils.stringify(v):lower()
  return s == 'false' or s == 'no' or s == '0'
end

return {
  {
    Meta = function(meta)
      if is_false(meta.show_solutions) then show = false end
    end
  },
  {
    Div = function(div)
      if not show and div.classes:includes('sol') then
        return {}
      end
    end
  }
}
