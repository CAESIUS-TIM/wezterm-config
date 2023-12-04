-------------------------------------------------------------------------------
-- # require
-------------------------------------------------------------------------------
-- Pull in the wezterm API
local wezterm = require('wezterm')
local io = require('io')
local os = require('os')
local act = wezterm.action
local EDITOR = 'hx'
---@diagnostic disable-next-line: different-requires
require('init')

-------------------------------------------------------------------------------
-- # tools
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- # init
-------------------------------------------------------------------------------
-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
-------------------------------------------------------------------------------
-- # launch
-------------------------------------------------------------------------------
config.default_prog = { 'pwsh', '-NoLogo' }
config.launch_menu = {}

-- multi os
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  table.insert(config.launch_menu, {
    name = 'PowerShell',
    args = { 'pwsh', '-NoLogo' },
  })
  table.insert(config.launch_menu, {
    name = 'Command Prompt',
    args = { 'cmd', '/k C:\\Users\\26523\\.cmd_aliases.bat' },
  })
  table.insert(config.launch_menu, {
    label = 'Old Ubuntu (local)',
    args = { 'ssh', 'timxing@192.168.3.63' },
  })
  table.insert(config.launch_menu, {
    label = 'Old Ubuntu (ssh)',
    -- args = { 'wezterm ssh timxing@frp-bag.top:10600' },
    args = { 'ssh', ' timxing@frp-bag.top:10600' },
    -- args = { 'ssh', 'timxing@frp-bag.top -p 10600' },
    -- args = { 'pwsh', '-Command "ssh timxing@frp-bag.top -p 10600"' },
  })

  --- Find installed visual studio version(s) and add their compilation
  --- environment command prompts to the menu
  -- for _, vsvers in
  --   ipairs(
  --     wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files (x86)')
  -- do
  --   local year = vsvers:gsub('Microsoft Visual Studio/', '')
  --   table.insert(config.launch_menu, {
  --     label = 'x64 Native Tools VS ' .. year,
  --     args = {
  --       'cmd.exe',
  --       '/k',
  --       'C:/Program Files (x86)/'
  --         .. vsvers
  --         .. '/BuildTools/VC/Auxiliary/Build/vcvars64.bat',
  --     },
  --   })
  -- end
end

config.ssh_domains = {
  {
    name = 'old_ubuntu',
    remote_address = 'frp-bag.top:10600',
    username = 'timxing',
    -- multiplexing = 'None',
    -- assume_shell = 'Posix',
  },
}

-------------------------------------------------------------------------------
-- # colors & appearence & fonts
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- ## tab
-------------------------------------------------------------------------------
-- config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false

-- show time at right status
wezterm.on('update-right-status', function(window, _)
  -- "Wed 2023-09-27 08:14:06"
  local date = wezterm.strftime('%a %Y-%m-%d %H:%M:%S ')

  window:set_right_status(wezterm.format({
    { Text = wezterm.nerdfonts.fa_clock_o .. ' ' .. date },
  }))
end)

-------------------------------------------------------------------------------
-- ## color
-------------------------------------------------------------------------------
config.color_scheme = 'Catppuccin Frappe'
-- config.color_scheme = 'Tango (base16)'

config.window_background_opacity = 0.85
-- make helix's background opacity
config.text_background_opacity = 0.6

-------------------------------------------------------------------------------
-- ## font
-------------------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
  'ComicShannsMono Nerd Font Mono',
  'JetBrainsMono Nerd Font Mono',
  'Symbols Nerd Font Mono',
})
config.font_size = 11.0
config.window_frame = {
  font = wezterm.font_with_fallback({
    'Agency FB',
    'Bauhaus 93',
    'Blackadder ITC',
    'Forte',
    'French Script MT',
    'Gabriola',
    'Gloucester MT Extra Condensed',
    'Symbols Nerd Font Mono',
  }),
  font_size = 10.0,
  -- color stuff ...
}
-------------------------------------------------------------------------------
-- # binding
-------------------------------------------------------------------------------
config.use_dead_keys = false
config.keys = {}
-- local binding = require('binding/binding')
-- local vim = require('binding/vim')

-- local pane = require('binding/pane')
-- table.shallow_merge(config, binding)
-- table.shallow_merge(config, vim)
-- table.shallow_merge(config, pane)

-- load all text in the current terminal window to editor for editor
wezterm.on('trigger-editor-with-visible-text', function(window, pane)
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
    act.SpawnCommandInNewWindow({
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

table.insert(config.keys, {
  key = 'E',
  mods = 'SHIFT|CTRL',
  action = act.EmitEvent('trigger-editor-with-visible-text'),
})

-------------------------------------------------------------------------------
-- test
-------------------------------------------------------------------------------

-- and finally, return the configuration to wezterm
return config
