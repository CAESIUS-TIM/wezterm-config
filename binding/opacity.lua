local wezterm = require('wezterm')
local act = wezterm.action
local DETLA_OPACITY = 0.05

wezterm.on('toggle-opacity', function(window, _)
  local overrides = window:get_config_overrides() or {}
  if overrides.window_background_opacity ~= 1 then
    overrides.window_background_opacity = 1
  else
    overrides.window_background_opacity = 0.85
  end
  window:set_config_overrides(overrides)
end)

wezterm.on('increase-opacity', function(window, _)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 1.0
  else
    overrides.window_background_opacity = overrides.window_background_opacity
      + DETLA_OPACITY
    if overrides.window_background_opacity >= 1.0 then
      overrides.window_background_opacity = 1.0
    end
  end
  window:set_config_overrides(overrides)
end)

wezterm.on('decrease-opacity', function(window, _)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 1.0
  else
    overrides.window_background_opacity = overrides.window_background_opacity
      - DETLA_OPACITY
    if overrides.window_background_opacity <= 0.0 then
      overrides.window_background_opacity = 0.0
    end
  end
  window:set_config_overrides(overrides)
end)

return {
  keys = {
    -- BUG: <C-S-0>: about windows autokey
    -- {
    --   key = '0',
    --   mods = 'SHIFT|CTRL',
    --   action = act.EmitEvent('toggle-opacity'),
    -- },
    -- {
    --   key = ')',
    --   mods = 'SHIFT|CTRL',
    --   action = act.EmitEvent('toggle-opacity'),
    -- },
    {
      key = '=',
      mods = 'SHIFT|CTRL',
      action = act.EmitEvent('increase-opacity'),
    },
    {
      key = '+',
      mods = 'SHIFT|CTRL',
      action = act.EmitEvent('increase-opacity'),
    },
    {
      key = '-',
      mods = 'SHIFT|CTRL',
      action = act.EmitEvent('decrease-opacity'),
    },
    {
      key = '_',
      mods = 'SHIFT|CTRL',
      action = act.EmitEvent('decrease-opacity'),
    },
  },

  -- BUG: url regex issue
  -- - Text:
  --   [Quick start](https://wezfurlong.org/wezterm/config/files.html)
  -- - Get URL:
  --   https://wezfurlong.org/wezterm/config/files.html)
  --                                                   ^ <-- an extra ')' here.
  mouse_bindings = {
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
    {
      event = { Down = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = act({ PasteFrom = 'Clipboard' }),
    },
  },
}
