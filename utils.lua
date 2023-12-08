module = {}

---@param tbl table
---@param func function
---@return table
function module.enumerate(tbl, func) -- almost same as python's enumerate(map with index)
  local t = {}
  for idx, v in ipairs(tbl) do
    t[idx] = func(v, idx)
  end
  return t
end

-- https://gist.github.com/w13b3/5d8a80fae57ab9d51e285f909e2862e0
---@diagnostic disable-next-line: unused-function, unused-local
function module.zip(...) -- almost same as python's zip
  local idx, ret, args = 1, {}, { ... }
  while true do -- loop smallest table-times
    local sub_table = {}
    local value
    for _, table_ in ipairs(args) do
      value = table_[idx] -- becomes nil if index is out of range
      if value == nil then
        break
      end -- break for-loop
      table.insert(sub_table, value)
    end
    if value == nil then
      break
    end -- break while-loop
    table.insert(ret, sub_table) -- insert the sub result
    idx = idx + 1
  end
  return ret
end

---@param tbl any
function module.dump(tbl)
  module.dump_helper(tbl, 0, true)
end

module.dump_space = '  '
---@param tbl any
---@param depth number
---@param root boolean
function module.dump_helper(tbl, depth, root)
  if root then
    print('{')
  end
  for k, v in pairs(tbl) do
    if type(k) == 'number' then
      k = '[' .. k .. ']'
    elseif type(k) == 'string' then
      k = '\'' .. k .. '\''
    end
    if type(v) == 'table' then
      print(module.dump_space:rep(depth + 1) .. k .. ': {')
      module.dump_helper(v, depth + 1, false)
    else
      print(module.dump_space:rep(depth + 1) .. k .. ': ' .. v .. ',')
    end
  end
  if root then
    print('}')
  else
    print(module.dump_space:rep(depth) .. '},')
  end
end

---@param tbls  table
function module.flatten1(tbls) -- flatten 1 level
  local result = {}
  ---@diagnostic disable-next-line: unused-local
  for index, tbl in next, tbls do
    for _, value in next, tbl do
      table.insert(result, value)
    end
  end
  return result
end

--- C:/Users/26523/Notes => c/u/2/Notes
--- /home/timxing/.config/wezterm => /h/t/./wezterm
---@param path string|nil
---@return string
function module.short_path(path)
  if path == nil then
    return ''
  end
  if path:sub(-1) == '/' then
    path = path:sub(1, -2)
  end
  path = string.gsub(path, '([^/])[^/]-/', function(s)
    -- return s:lower() .. '/'
    return s .. '/'
  end)
  print(path)
  return path
end

-- 用于计算颜色亮度的函数
---@param color table color@{u8,u8,u8}
---@return number
function module.calculate_brightness(color)
  return 0.299 * color[1] + 0.587 * color[2] + 0.114 * color[3]
end

-- 通过字符串哈希生成颜色
---@param title string
---@return string
function module.generate_window_color(title)
  local target_brightness = 127  -- 你可以调整目标亮度的阈值
  print('--- utils.generate_window_color ---[[')
  -- 计算字符串哈希值
  local hash = 0
  for i = 1, #title do
    hash = (hash << 5) - hash + title:byte(i)
  end

  -- 将哈希值映射到RGB颜色空间
  local r = (hash & 0xFF0000) >> 16
  local g = (hash & 0x00FF00) >> 8
  local b = hash & 0x0000FF

  -- 计算亮度
  local brightness = module.calculate_brightness({r, g, b})
  print('hash: ' .. string.format("%x", hash))
  print('rgb: ' .. string.format("%02x,%02x,%02x", r,g,b))
  print('brightness: ' .. brightness)

  -- 调整亮度，确保颜色相对亮
  if brightness < target_brightness then
    local brightness_factor = target_brightness / brightness

    r = math.min(255, math.floor(r * brightness_factor))
    g = math.min(255, math.floor(g * brightness_factor))
    b = math.min(255, math.floor(b * brightness_factor))
    print('target rgb: ' .. string.format("%02x,%02x,%02x", r,g,b))
  end

  local color = (r << 16) | (g << 8) | b
  print('color: ' .. string.format("%06x", color))
  print('--- utils.generate_window_color ---]] ')
  return string.format('#%06x',color)
end

return module
