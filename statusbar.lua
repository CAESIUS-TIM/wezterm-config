local wezterm = require('wezterm')
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
local TABLE_ICON = utf8.char(0xf0ce)

local function enumerate(tbl, func) -- almost same as python's enumerate(map with index)
  local t = {}
  for idx, v in ipairs(tbl) do
    t[idx] = func(v, idx)
  end
  return t
end

-- https://gist.github.com/w13b3/5d8a80fae57ab9d51e285f909e2862e0
local function zip(...) -- almost same as python's zip
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

local function flatten1(tbls) -- flatten 1 level
  local result = {}
  ---@diagnostic disable-next-line: unused-local
  for index, tbl in next, tbls do
    for _, value in next, tbl do
      table.insert(result, value)
    end
  end
  return result
end

local function day_of_week_in_japan(weeknum)
  local days = { '日', '月', '火', '水', '木', '金', '土' }
  return days[weeknum + 1]
end

local function day_of_week_in_english(weeknum)
  local days = { 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' }
  return days[weeknum + 1]
end

-- https://open-meteo.com/en/docs
-- local function weather_symbol(weathercode)
--   local weathers = {
--     [-1] = '❓', -- undefined
--     [0] = '☀️',
--     [1] = '🌤',
--     [2] = '🌦',
--     [3] = '☁️',
--     [45] = '🌫',
--     [48] = '🌫',
--     [51] = '🌦',
--     [53] = '🌦',
--     [55] = '🌧',
--     [56] = '🌨',
--     [57] = '🌨',
--     [61] = '☂',
--     [63] = '☔',
--     [65] = '☔',
--     [66] = '☂',
--     [67] = '☔',
--     [71] = '⛄',
--     [73] = '☃',
--     [75] = '☃',
--     [77] = '🌨',
--     [80] = '🌧',
--     [81] = '☂',
--     [82] = '☔',
--     [85] = '🌨',
--     [86] = '🌨',
--     [95] = '⛈',
--     [96] = '⛈',
--     [99] = '⛈',
--   }
--   return weathers[weathercode]
-- end
local function weather_symbol(weathercode)
  --[[
    plus ➕ ⚠️
    green 🟩
    blue 🟦
    yellow 🟨
    orange 🟧
    red 🟥
  ]]
  local weathers = {
    [-1] = '❓', -- undefined
    ---
    ['晴'] = '☀️',
    ['少云'] = '🌤️',
    ['晴间多云'] = '🌤️',
    ['多云'] = '☁️',
    ['阴'] = '☁️',
    --
    ['有风'] = '🎐',
    ['平静'] = '🎐',
    ['微风'] = '🎐',
    ['和风'] = '🎐',
    ['清风'] = '🎐',
    ['强风/劲风'] = '💨',
    ['疾风'] = '💨',
    ['大风'] = '💨',
    ['烈风'] = '💨',
    ['风暴'] = '💨',
    ['狂爆风'] = '💨',
    ['飓风'] = '🌀',
    ['热带风暴'] = '🌀',
    --
    ['霾'] = '🌫',
    ['中度霾'] = '🌫',
    ['重度霾'] = '🌫',
    ['严重霾'] = '🌫',
    --
    ['阵雨'] = '🌩️',
    ['雷阵雨'] = '🌩️',
    ['雷阵雨并伴有冰雹'] = '⛈️',
    ['小雨'] = '🌦️',
    ['中雨'] = '🌧️',
    ['大雨'] = '🌧️',
    ['暴雨'] = '☔',
    ['大暴雨'] = '☔',
    ['特大暴雨'] = '☔',
    ['强阵雨'] = '☔',
    ['强雷阵雨'] = '⛈️',
    ['极端降雨'] = '☔',
    ['毛毛雨/细雨'] = '🌦️',
    ['雨'] = '🌧️',
    ['小雨-中雨'] = '🌦️',
    ['中雨-大雨'] = '🌧️',
    ['大雨-暴雨'] = '☔',
    ['暴雨-大暴雨'] = '☔',
    ['大暴雨-特大暴雨'] = '☔',
    ['雨雪天气'] = '🌨️',
    ['雨夹雪'] = '🌨️',
    ['阵雨夹雪'] = '🌨️',
    ['冻雨'] = '🌨️',
    --
    ['雪'] = '☃️',
    ['阵雪'] = '☃️',
    ['小雪'] = '☃️',
    ['中雪'] = '☃️',
    ['大雪'] = '❄️',
    ['暴雪'] = '❄️',
    ['小雪-中雪'] = '☃️',
    ['中雪-大雪'] = '❄️',
    ['大雪-暴雪'] = '❄️',
    --
    ['浮尘'] = '💨',
    ['扬沙'] = '💨',
    ['沙尘暴'] = '🌪️',
    ['强沙尘暴'] = '🌪️',
    ['龙卷风'] = '🌪️',
    --
    ['雾'] = '🌫️',
    ['浓雾'] = '🌫️',
    ['强浓雾'] = '🌫️',
    ['轻雾'] = '🌫️',
    ['大雾'] = '🌫️',
    ['特强浓雾'] = '🌫️',
    --
    ['热'] = '🥵',
    ['冷'] = '🥶',
    ['未知'] = '❓',
  }
  return weathers[weathercode]
end

local function styled_whether(weathercode, temperature_max, temperature_min)
  return {
    {
      Foreground = {
        Color = '#c0c0c0',
      },
    },
    {
      Text = string.format(' %s', weather_symbol(weathercode)),
    },
    {
      Foreground = {
        Color = '#f08300', -- hot color
      },
    },
    {
      Text = string.format('%s', temperature_max),
    },
    {
      Foreground = {
        Color = '#c0c0c0',
      },
    },
    {
      Text = '|',
    },
    {
      Foreground = {
        Color = '#89c3eb', -- cool color
      },
    },
    {
      Text = string.format('%s ', temperature_min),
    },
  }
end

local function powerline(styled_text, color) -- decorate right prompt
  return {
    {
      Foreground = {
        Color = color,
      },
    },
    {
      Text = SOLID_LEFT_ARROW,
    },
    {
      Background = {
        Color = color,
      },
    },
    table.unpack(styled_text),
  }
end

local function update_whether()
  ---@diagnostic disable-next-line: unused-local
  local success, stdout, stderr = wezterm.run_child_process({
    'curl',
    '--silent',
    --'https://api.open-meteo.com/v1/forecast?latitude=35.7&longitude=139.82&daily=weathercode,temperature_2m_max,temperature_2m_min&forecast_days=3&timezone=Asia%2FTokyo',
    -- 'https://api.open-meteo.com/v1/forecast?latitude=31.365&longitude=120.6357&daily=weathercode,temperature_2m_max,temperature_2m_min&forecast_days=3&timezone=Asia%2FSingapore',
    'http://restapi.amap.com/v3/weather/weatherInfo?key=a1331d8bbee7aa4d1b22fc506a3f46c4&city=320507&extensions=all',
  }) -- At Tokyo SkyTree
  if not success or not stdout then
    return
  end
  -- local res = wezterm.json_parse(stdout).daily
  local res = wezterm.json_parse(stdout).forecasts[1].casts
  wezterm.GLOBAL.daily_weather = res
end

local function styled_current_git_branch(current_dir)
  ---@diagnostic disable-next-line: unused-local
  local success, stdout, _stderr = wezterm.run_child_process({
    'git',
    '--git-dir',
    string.format('%s/.git', current_dir),
    'branch',
    '--show-current',
  })
  if success then
    return {
      {
        Foreground = {
          Color = '#c0c0c0',
        },
      },
      {
        Text = string.format(' %s ', string.gsub(stdout, '^(.+)\n$', '%1')),
      },
    }
  else
    return nil
  end
  -- return {
  --   {
  --     Foreground = {
  --       Color = '#c0c0c0',
  --     },
  --   },
  --   {
  --     Text = success
  --         and string.format(' %s ', string.gsub(stdout, '^(.+)\n$', '%1'))
  --       or ' ❓ ',
  --   },
  -- }
end

--- C:/Users/26523/Notes => c/u/2/Notes
--- /home/timxing/.config/wezterm => /h/t/./wezterm
---@param path string|nil
---@return string
local function short_path(path)
  if path == nil then
    return ''
  end
  if path:match('/') == nil then
    return path
  end

  local short = path:sub(1, 1) == '/' and '/' or ''

  if path:match('^[^/]+/$') then
    return path
  end

  for node in path:gmatch('[^/]+/') do
    short = short .. '/' .. node:sub(1, 1):lower()
  end

  return short:sub(1, -2) .. path:match('.*/([^/]+)')
end

---@diagnostic disable-next-line: unused-local
local function create_powerlines(window, pane)
  local current_dir
  if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    -- Windows: C:/Users/username/
    current_dir = (pane:get_current_working_dir() or ''):sub(9)
  else -- other: /home/username/
    current_dir = (pane:get_current_working_dir() or ''):sub(8)
  end
  local daily_weather = wezterm.GLOBAL.daily_weather
  -- local weather_infos = zip(
  --   daily_weather.weathercode,
  --   daily_weather.temperature_2m_max,
  --   daily_weather.temperature_2m_min
  -- )
  -- local weather_infos = {
  --   {daily_weather[1].dayweather,daily_weather[1].daytemp_float, daily_weather[1].nighttemp_float},
  --   {daily_weather[2].dayweather,daily_weather[2].daytemp_float, daily_weather[2].nighttemp_float},
  --   {daily_weather[3].dayweather,daily_weather[3].daytemp_float, daily_weather[3].nighttemp_float},
  -- }
  local weather_infos = {}
  local days = 4
  if daily_weather ~= nil then
    for i = 1, days do
      if daily_weather[i] == nil then
        break
      end
      table.insert(weather_infos, {
        daily_weather[i].dayweather,
        daily_weather[i].daytemp_float,
        daily_weather[i].nighttemp_float,
      })
    end
  end
  ---@diagnostic disable-next-line: unused-local
  local styled_whethers = enumerate(weather_infos, function(weather_info, index)
    return styled_whether(table.unpack(weather_info))
  end)
  local styled_texts = {}
  local name = window:active_key_table()
  if name then
    table.insert(styled_texts, {
      {
        Foreground = {
          Color = '#c0c0c0',
        },
      },
      {
        Text = ' ' .. name .. ' ',
      },
    })
    table.insert(styled_texts, {
      {
        Foreground = {
          Color = '#c0c0c0',
        },
      },
      {
        Text = TABLE_ICON,
      },
    })
  end
  for i = 1, days do
    if styled_texts[i] == nil then
      break
    end
    table.insert(styled_texts, styled_whethers[i])
  end
  local git_branch = styled_current_git_branch(current_dir)
  if git_branch ~= nil then
    table.insert(styled_texts, git_branch)
  end
  -- table.insert(styled_texts, git_branch)
  table.insert(styled_texts, {
    {
      Foreground = {
        Color = '#c0c0c0',
      },
    },
    {
      Text = string.format(' %s ', short_path(current_dir)),
      -- Text = string.format(' %s ', current_dir),
    },
  })
  table.insert(styled_texts, {
    {
      Foreground = {
        Color = '#c0c0c0',
      },
    },
    {
      Text = string.format(
        ' %s(%s) %s ',
        wezterm.strftime('%-m/%-d'),
        day_of_week_in_english(wezterm.strftime('%u')),
        wezterm.strftime('%H:%M:%S')
      ),
    },
  })
  return flatten1(enumerate(styled_texts, function(styled_text, index)
    local color =
      string.format('hsl(%sdeg 75%% 25%%)', index % 2 == 0 and 240 or 224)
    return powerline(styled_text, color)
  end))
end

wezterm.on('update-status', function(window, pane)
  local counter = wezterm.GLOBAL.weather_loop_counter or 0
  if counter % (3600 * 4) == 0 then -- every 4 hours
    update_whether()
  end
  wezterm.GLOBAL.weather_loop_counter = counter + 1

  window:set_right_status(wezterm.format(create_powerlines(window, pane)))
end)
