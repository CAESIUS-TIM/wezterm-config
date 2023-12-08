--# require and alias
local wezterm = require('wezterm')
local io = require('io')
local os = require('os')
local act = wezterm.action
local mux = wezterm.mux

require('statusbar')

--# init
-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

--# constant
--## env
local EDITOR = 'hx'

--## icon
local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
local SOLID_LEFT_MOST = utf8.char(0x2588)
local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local ADMIN_ICON = utf8.char(0xf49c)

local CMD_ICON = utf8.char(0xe62a)
local NU_ICON = utf8.char(0xe7a8)
local PS_ICON = utf8.char(0xe70f)
local ELV_ICON = utf8.char(0xfc6f)
local WSL_ICON = utf8.char(0xe712)
local YORI_ICON = utf8.char(0xf1d4)
local NYA_ICON = utf8.char(0xf61a)
local SSH_ICON = utf8.char(0xeb3a)

local VIM_ICON = utf8.char(0xe62b)
local HX_ICON = utf8.char(0xe272)
local PAGER_ICON = utf8.char(0xf718)
local FUZZY_ICON = utf8.char(0xf0b0)
local HOURGLASS_ICON = utf8.char(0xf252)
-- local SUNGLASS_ICON = utf8.char(0xf9df)
-- local WINDOWS_ICON = utf8.char(0xf2d2)
local CPU_ICON = utf8.char(0xf4bc)
local FOLDER_ICON = utf8.char(0xf07c)

local PYTHON_ICON = utf8.char(0xe73c)
local NODE_ICON = utf8.char(0xe718)
local DENO_ICON = utf8.char(0xe628)
local LAMBDA_ICON = utf8.char(0xfb26)

local SUP_IDX = {
  '¹',
  '²',
  '³',
  '⁴',
  '⁵',
  '⁶',
  '⁷',
  '⁸',
  '⁹',
  '¹⁰',
  '¹¹',
  '¹²',
  '¹³',
  '¹⁴',
  '¹⁵',
  '¹⁶',
  '¹⁷',
  '¹⁸',
  '¹⁹',
  '²⁰',
}
local SUB_IDX = {
  '₁',
  '₂',
  '₃',
  '₄',
  '₅',
  '₆',
  '₇',
  '₈',
  '₉',
  '₁₀',
  '₁₁',
  '₁₂',
  '₁₃',
  '₁₄',
  '₁₅',
  '₁₆',
  '₁₇',
  '₁₈',
  '₁₉',
  '₂₀',
}

--# function
--- Equivalent to POSIX basename(3)
--- Given "/foo/bar" returns "bar"
--- Given "c:\\foo\\bar" returns "bar"
---@param s string
---@return string
local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

--# on
wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local edge_background = '#121212'
    local background = '#4E4E4E'
    local foreground = '#1C1B19'
    local dim_foreground = '#3A3A3A'

    if tab.is_active then
      background = '#FBB829'
      foreground = '#1C1B19'
    elseif hover then
      background = '#FF8700'
      foreground = '#1C1B19'
    end

    local edge_foreground = background
    local process_name = tab.active_pane.foreground_process_name
    local pane_title = tab.active_pane.title
    local exec_name = basename(process_name):gsub('%.exe$', '')
    local title_with_icon

    if exec_name == 'nu' then
      title_with_icon = NU_ICON .. ' NuShell'
    elseif exec_name == 'pwsh' then
      title_with_icon = PS_ICON .. ' PS'
    elseif exec_name == 'cmd' then
      title_with_icon = CMD_ICON .. ' CMD'
    elseif exec_name == 'elvish' then
      title_with_icon = ELV_ICON .. ' Elvish'
    elseif exec_name == 'wsl' or exec_name == 'wslhost' then
      title_with_icon = WSL_ICON .. ' WSL'
    elseif exec_name == 'nyagos' then
      title_with_icon = NYA_ICON
        .. ' '
        .. pane_title:gsub('.*: (.+) %- .+', '%1')
    elseif exec_name == 'yori' then
      title_with_icon = YORI_ICON .. ' ' .. pane_title:gsub(' %- Yori', '')
    elseif exec_name == 'ssh' then
      title_with_icon = SSH_ICON .. ' SSH'
    elseif exec_name == 'nvim' then
      title_with_icon = VIM_ICON
        .. pane_title:gsub('^(%S+)%s+(%d+/%d+) %- nvim', ' %2 %1')
    elseif exec_name == 'hx' then
      title_with_icon = HX_ICON .. ' Helix'
    elseif exec_name == 'bat' or exec_name == 'less' or exec_name == 'moar' then
      title_with_icon = PAGER_ICON .. ' ' .. exec_name:upper()
    elseif exec_name == 'fzf' or exec_name == 'hs' or exec_name == 'peco' then
      title_with_icon = FUZZY_ICON .. ' ' .. exec_name:upper()
    elseif exec_name == 'btm' or exec_name == 'ntop' then
      title_with_icon = CPU_ICON .. ' ' .. exec_name:upper()
    elseif exec_name == 'lf' or exec_name == 'ranger' then
      title_with_icon = FOLDER_ICON .. ' ' .. exec_name:upper()
    elseif exec_name == 'python' or exec_name == 'hiss' then
      title_with_icon = PYTHON_ICON .. ' ' .. exec_name
    elseif exec_name == 'node' then
      title_with_icon = NODE_ICON .. ' ' .. exec_name:upper()
    elseif exec_name == 'deno' then
      title_with_icon = DENO_ICON .. ' ' .. exec_name:upper()
    elseif
      exec_name == 'bb'
      or exec_name == 'cmd-clj'
      or exec_name == 'janet'
      or exec_name == 'hy'
    then
      title_with_icon = LAMBDA_ICON
        .. ' '
        .. exec_name:gsub('bb', 'Babashka'):gsub('cmd%-clj', 'Clojure')
    else
      title_with_icon = HOURGLASS_ICON .. ' ' .. exec_name
    end
    if pane_title:match('^Administrator: ') then
      title_with_icon = title_with_icon .. ' ' .. ADMIN_ICON
    end
    local left_arrow = SOLID_LEFT_ARROW
    if tab.tab_index == 0 then
      left_arrow = SOLID_LEFT_MOST
    end
    local id = SUB_IDX[tab.tab_index + 1]
    local pid = SUP_IDX[tab.active_pane.pane_index + 1]
    local title = ' '
      .. wezterm.truncate_right(title_with_icon, max_width - 6)
      .. ' '

    return {
      { Attribute = { Intensity = 'Bold' } },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = left_arrow },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = id },
      { Text = title },
      { Foreground = { Color = dim_foreground } },
      { Text = pid },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
      { Attribute = { Intensity = 'Normal' } },
    }
  end
)

-- wezterm.on('update-right-status', function(window, pane)
--   local name = window:active_key_table()
--   if name then
--     name = 'TABLE: ' .. name
--   end
--   window:set_right_status(name or '')
-- end)

-- TODO
-- show time at right status
-- wezterm.on('update-right-status', function(window, _)
--   -- "Wed 2023-09-27 08:14:06"
--   local date = wezterm.strftime('%a %Y-%m-%d %H:%M:%S ')
--   window:set_right_status(wezterm.format({
--     { Text = wezterm.nerdfonts.fa_clock_o .. ' ' .. date },
--   }))
-- end)

wezterm.on('trigger-vim-with-visible-text', function(window, pane)
  -- Retrieve the current viewport's text.
  --
  -- Note: You could also pass an optional number of lines (eg: 2000) to
  -- retrieve that number of lines starting from the bottom of the viewport.
  local viewport_text = pane:get_lines_as_text()

  -- Create a temporary file to pass to vim
  local name = os.tmpname()
  local f = io.open(name, 'w+')

  if f == nil then
    return
  end

  f:write(viewport_text)
  f:flush()
  f:close()

  -- Open a new window running vim and tell it to open the file
  window:perform_action(
    act.SpawnCommandInNewTab({
      args = { EDITOR, name },
    }),
    pane
  )

  -- Wait "enough" time for vim to read the file before we remove it.
  -- The window creation and process spawn are asynchronous wrt. running
  -- this script and are not awaitable, so we just pick a number.
  --
  -- Note: We don't strictly need to remove this file, but it is nice
  -- to avoid cluttering up the temporary directory.
  wezterm.sleep_ms(1000)
  os.remove(name)
end)

-- maximize on startup
wezterm.on('gui-startup', function(_)
  local _, _, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  gui_window:maximize()
end)

-- full screen on startup
-- wezterm.on('gui-startup', function(_)
--   local _, pane, window = mux.spawn_window(cmd or {})
--   local gui_window = window:gui_window()
--   gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
-- end)

-- -- TODO
-- config.keys = {}
-- for i = 1, 8 do
--   -- CTRL+ALT + number to move to that position
--   table.insert(config.keys, {
--     key = tostring(i),
--     mods = 'LEADER|ALT',
--     action = act.MoveTab(i - 1),
--   })
-- end

--# conifg
--## appearence
config.window_decorations = 'RESIZE' -- no title bar -- TODO
-- config.color_scheme = 'srcery'
config.color_scheme = 'Catppuccin Frappe'
config.font_dirs = { 'fonts' } -- TODO
config.font_size = 14.0
config.dpi = 96.0
config.freetype_load_target = 'Normal' -- TODO
config.font = wezterm.font_with_fallback({
  'JetBrainsMono Nerd Font Mono',
  -- 'JetBrainsMono NFM',
  -- 'Iosevka Mayukai Codepro',
  -- 'Sarasa Mono Slab CL',
})
config.tab_max_width = 60
config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.85
config.text_background_opacity = 1
config.colors = {
  tab_bar = {
    background = '#121212',
    new_tab = {
      bg_color = '#121212',
      fg_color = '#FCE8C3',
      intensity = 'Bold',
    },
    new_tab_hover = {
      bg_color = '#121212',
      fg_color = '#FBB829',
      intensity = 'Bold',
    },
    active_tab = { bg_color = '#121212', fg_color = '#FCE8C3' },
  },
}
config.window_background_gradient = {
  orientation = 'Vertical',
  interpolation = 'Linear',
  blend = 'Rgb',
  colors = {
    '#121212',
    '#202020',
  },
}
--## launch
config.default_prog = { 'nu.exe' }
config.set_environment_variables = {
  LANG = 'en_US.UTF-8',
  PATH = wezterm.executable_dir .. ';' .. os.getenv('PATH'),
}
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
config.launch_menu = { -- TODO
  {
    label = 'LF',
    args = { 'lf.exe' },
  },
  {
    label = 'Bottom',
    args = { 'btm.exe' },
  },
  {
    label = 'ntop',
    args = { 'ntop.exe' },
  },
  {
    label = 'Cmder',
    args = {
      'cmd.exe',
      '/s',
      '/k',
      'C:/Users/26523/scoop/apps/cmder/current/vendor/init.bat',
      -- 'D:/Scoop/apps/cmder/current/vendor/init.bat',
      -- '/f',
      -- '/nix_tools',
      -- '0',
    },
  },
  {
    label = 'Pwsh',
    args = { 'pwsh.exe', '-nol', '-noe' },
  },
  {
    label = 'NyaGOS',
    args = { 'nyagos.exe', '--glob' },
  },
  {
    label = 'NuShell',
    args = { 'nu.exe' },
  },
  {
    label = 'Elvish',
    args = { 'elvish.exe' },
  },
  {
    label = 'Yori',
    args = { 'yori.exe' },
  },
  {
    label = 'VS',
    args = {
      'cmd.exe',
      '/k',
      'D:/Scoop/apps/cmder/current/vendor/init.bat',
      '/f',
      '/nix_tools',
      '0',
      '/VS',
    },
  },
  {
    label = 'PSVS',
    args = {
      'pwsh.exe',
      '-noe',
      '-c',
      '&{Import-Module "D:\\dev_env\\vs\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell 1c952f20}',
    },
  },
}
--## key
config.disable_default_key_bindings = true
config.leader = { key = 'f', mods = 'ALT' }
--[[
    1. window
    2. workspace
    3. tab
    4. pane

    1. new/close
    2. switch
    3. size
  ]]
config.keys = {
  --# 1 window
  --## size TODO
  { key = 'Enter', mods = 'ALT', action = 'ToggleFullScreen' },
  {
    key = 'Insert',
    mods = 'SHIFT',
    action = act({ PasteFrom = 'PrimarySelection' }),
  },
  { -- TODO: What is it?
    key = 'Insert',
    mods = 'CTRL',
    action = act({ CopyTo = 'PrimarySelection' }),
  },
  --# 2 workspace
  --## 2.0 special
  { -- both new and switch
    key = 'B',
    mods = 'LEADER|SHIFT',
    action = act.ShowLauncherArgs({
      flags = 'WORKSPACES',
    }),
  },
  --## 2.1 new/close TODO
  {
    key = 'N',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine({
      description = wezterm.format({
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      }),
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace({
              name = line,
            }),
            pane
          )
        end
      end),
    }),
  },
  --## 2.2 switch TODO
  {
    key = '}',
    mods = 'CTRL|SHIFT',
    action = act.SwitchWorkspaceRelative(-1),
  },
  { key = '{', mods = 'CTRL|SHIFT', action = act.SwitchWorkspaceRelative(1) },
  {
    key = 'N',
    mods = 'LEADER|SHIFT',
    action = act.SwitchWorkspaceRelative(-1),
  },
  {
    key = 'P',
    mods = 'LEADER|SHIFT',
    action = act.SwitchWorkspaceRelative(1),
  },
  --# 3 tab
  --## 3.1 new/close TODO
  { key = 'f', mods = 'LEADER', action = 'ShowLauncher' },
  {
    key = 'T',
    mods = 'CTRL|SHIFT',
    action = act.SpawnTab('CurrentPaneDomain'),
  },
  {
    key = 'x',
    mods = 'LEADER|SHIFT',
    action = act({ CloseCurrentTab = { confirm = true } }),
  },
  --## 3.2 switch
  --### 3.2.0 misc
  { key = 'o', mods = 'LEADER', action = 'ActivateLastTab' },
  { key = 'b', mods = 'LEADER', action = 'ShowTabNavigator' },
  --### 3.2.1 relative
  {
    key = 'Tab',
    mods = 'CTRL',
    action = act({
      ActivateTabRelative = 1,
    }),
  },
  {
    key = 'Tab',
    mods = 'CTRL|SHIFT',
    action = act({ ActivateTabRelative = -1 }),
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act({
      ActivateTabRelative = 1,
    }),
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = act({ ActivateTabRelative = -1 }),
  },
  --### 3.2.2 absolute
  {
    key = '1',
    mods = 'LEADER',
    action = act({ ActivateTab = 0 }),
  },
  {
    key = '2',
    mods = 'LEADER',
    action = act({ ActivateTab = 1 }),
  },
  {
    key = '3',
    mods = 'LEADER',
    action = act({ ActivateTab = 2 }),
  },
  {
    key = '4',
    mods = 'LEADER',
    action = act({ ActivateTab = 3 }),
  },
  {
    key = '5',
    mods = 'LEADER',
    action = act({ ActivateTab = 4 }),
  },
  {
    key = '6',
    mods = 'LEADER',
    action = act({ ActivateTab = 5 }),
  },
  {
    key = '7',
    mods = 'LEADER',
    action = act({ ActivateTab = 6 }),
  },
  {
    key = '8',
    mods = 'LEADER',
    action = act({ ActivateTab = 7 }),
  },
  {
    key = '9',
    mods = 'LEADER',
    action = act({ ActivateTab = 8 }),
  },
  --## 3.3 move
  { key = '<', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '>', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
  --# 4 pane
  --## 4.1 new/close
  {
    key = 'v',
    mods = 'LEADER',
    action = act({
      SplitHorizontal = { domain = 'CurrentPaneDomain' },
    }),
  },
  {
    key = 's',
    mods = 'LEADER',
    action = act({
      SplitVertical = { domain = 'CurrentPaneDomain' },
    }),
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = act({ CloseCurrentPane = { confirm = true } }),
  },
  --# 4.2 switch
  {
    key = 'h',
    mods = 'LEADER',
    action = act({ ActivatePaneDirection = 'Left' }),
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act({ ActivatePaneDirection = 'Down' }),
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act({ ActivatePaneDirection = 'Up' }),
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act({ ActivatePaneDirection = 'Right' }),
  },
  --## 4.3 move TODO
  --## 4.4 size TODO
  { key = 'z', mods = 'LEADER', action = 'TogglePaneZoomState' },
  --# 5 extra mod
  {
    key = '/',
    mods = 'LEADER',
    action = act({ Search = { CaseInSensitiveString = '' } }),
  },
  {
    key = 'y',
    mods = 'LEADER',
    action = 'ActivateCopyMode',
  },
  {
    key = '?',
    mods = 'LEADER|SHIFT',
    action = 'ActivateCommandPalette',
  },
  { key = 'q', mods = 'LEADER', action = 'QuickSelect' },
  {
    key = 'Q',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.QuickSelectArgs({
      label = 'open url',
      patterns = {
        '\\b\\w+://\\S+[/a-zA-Z0-9-]+',
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. url)
        wezterm.open_with(url)
      end),
    }),
  },
  --# 6 misc TODO
  { key = 'V', mods = 'SHIFT|CTRL', action = act.PasteFrom('Clipboard') },
  { key = 'U', mods = 'CTRL|SHIFT', action = act.ScrollByPage(-0.5) },
  { key = 'D', mods = 'CTRL|SHIFT', action = act.ScrollByPage(0.5) },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  -- TODO: category
  {
    key = 'E',
    mods = 'SHIFT|CTRL',
    action = act.EmitEvent('trigger-vim-with-visible-text'),
  },
  { key = 'R', mods = 'LEADER|SHIFT', action = 'ReloadConfiguration' },
  { key = '`', mods = 'LEADER', action = 'ShowDebugOverlay' },
  --# 7 key table
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable({
      name = 'resize_pane',
      one_shot = false,
    }),
  },
  {
    key = 'e',
    mods = 'LEADER',
    action = act.ActivateKeyTable({
      name = 'explore',
      one_shot = false,
    }),
  },
  -- If use '`' as LEADER
  -- {
  --   key = '`',
  --   mods = 'LEADER',
  --   action = act({ SendString = '`' }),
  -- },
}
config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_pane = { -- TESTED
    { key = 'LeftArrow', action = act.AdjustPaneSize({ 'Left', 1 }) },
    { key = 'h', action = act.AdjustPaneSize({ 'Left', 1 }) },
    { key = 'H', mods = 'SHIFT', action = act.AdjustPaneSize({ 'Left', 5 }) },

    { key = 'RightArrow', action = act.AdjustPaneSize({ 'Right', 1 }) },
    { key = 'l', action = act.AdjustPaneSize({ 'Right', 1 }) },
    { key = 'L', mods = 'SHIFT', action = act.AdjustPaneSize({ 'Right', 5 }) },

    { key = 'UpArrow', action = act.AdjustPaneSize({ 'Up', 1 }) },
    { key = 'k', action = act.AdjustPaneSize({ 'Up', 1 }) },
    { key = 'K', mods = 'SHIFT', action = act.AdjustPaneSize({ 'Up', 5 }) },

    { key = 'DownArrow', action = act.AdjustPaneSize({ 'Down', 1 }) },
    { key = 'j', action = act.AdjustPaneSize({ 'Down', 1 }) },
    { key = 'J', mods = 'SHIFT', action = act.AdjustPaneSize({ 'Down', 5 }) },

    -- no recursion
    {
      key = 'r',
      mods = 'LEADER',
      action = 'Nop',
    },
    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'q', action = 'PopKeyTable' },
  },
  explore = {
    { key = 'k', action = act.ScrollByLine(-1) },
    { key = 'j', action = act.ScrollByLine(1) },
    { key = 'u', action = act.ScrollByPage(-0.5) },
    { key = 'd', action = act.ScrollByPage(0.5) },
    { key = 'b', action = act.ScrollByPage(-1) },
    { key = 'f', action = act.ScrollByPage(1) },
    { key = 'g', action = 'ScrollToTop' },
    { key = 'G', mods = 'SHIFT', action = 'ScrollToBottom' },

    -- no recursion
    {
      key = 'e',
      mods = 'LEADER',
      action = 'Nop',
    },
    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'q', action = 'PopKeyTable' },
  },
}
config.mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection('ClipboardAndPrimarySelection'),
  },
  -- Bind 'Up' event of CTRL-Click to open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
  -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.Nop,
  },
  -- Bind 'Down' event of CTRL-RightClick to paste from clipboard
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act({ PasteFrom = 'Clipboard' }),
  },
}

return config
