-- Copyright (c) 2019 Christopher Maahs
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this
-- software and associated documentation files (the "Software"), to deal in the Software
-- without restriction, including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

--- === GlobalMute ===
---
--- With this Spoon you will be able ot globally mute and unmute your Microphone devices.
--- [https://github.com/cmaahs/global-mute-spoon](https://github.com/cmaahs/global-mute-spoon)
---
--- This spoon was inspired by one of my previous co-workers: https://github.com/jesselang/dotfiles
-- ## TODO

local obj={}
obj.__index = obj

-- Metadata
obj.name = "GlobalMute"
obj.version = "0.1"
obj.author = "Christopher Maahs <cmaahs@gmail.com>"
obj.homepage = "https://github.com/cmaahs/global-mute-spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- GlobalMute.logger
--- Variable
--- Accessible variable to adjust the logging level
local logger = hs.logger.new(obj.name)
obj._logger = logger
logger.i("Loading ".. obj.name)


-- ## Public variables

-- Comment: Lots of work here to save users a little work. Previous versions required users to call
-- GlobalMute:start() every time they changed GRID. The metatable work here watches for those changes and does the work :start() would have done.
package.path = package.path..";Spoons/".. ... ..".spoon/?.lua"

-- ## Internal

function setbackground(bgfile)
  if bgfile ~= nil then
    local screens = hs.screen.allScreens()
    for _, newScreen in ipairs(screens) do
      newScreen:desktopImageURL(bgfile)
    end
  end
end

-- ### Utilities

-- ## Public

--- GlobalMute:toggle()
--- Method
--- Mute all system sound input, force to mute
function obj:toggle()
  is_synced = true
  for _, device in pairs(hs.audiodevice.allInputDevices()) do
    is_muted = device:inputMuted()
    logger.d("Toggle Operation, Device Mute Status Was: ".. tostring(is_muted))

    if is_muted ~= self.muted then
        is_synced = false
    end
  end

  if self.muted then
    -- muted, now unmute
    self:unmute()
  else -- self.muted = false
    -- unmuted, please mute
    self:mute()
  end
end

--- GlobalMute:mute(force)
--- Method
--- Mute all system sound input, force to mute
function obj:mute(force)
  is_changed = force or false
  for _, device in pairs(hs.audiodevice.allInputDevices()) do
      is_muted = device:inputMuted()
      logger.d("Mute Operation, Device Mute Status Was: ".. tostring(is_muted))

      if not is_muted then
          device:setInputMuted(true)
          is_changed = true
      end
  end

  if is_changed then
    setbackground(self.mute_bg)
    self.muted = true
  end

  return is_changed
end

--- GlobalMute:unmute()
--- Method
--- UnMute all system sound input
function obj:unmute(force)
  is_changed = force or false
  for _, device in pairs(hs.audiodevice.allInputDevices()) do
      is_muted = device:inputMuted()
      logger.d("UnMute Operation, Device Mute Status Was: ".. tostring(is_muted))

      if is_muted then
          device:setInputMuted(false)
          is_changed = true
      end
  end

  if is_changed then
    setbackground(self.unmute_bg)
    self.muted = false
  end

  return is_changed
end

--- GlobalMute:microphone_changes(device_uid, event_name, event_scope, event_element)
--- Method
--- Callback function when audio input events happen
function obj:microphone_changes(device_uid, event_name, event_scope, event_element)
  logger.d("microphone_changes args: ".. device_uid ..", ".. event_name ..",".. event_scope ..",".. event_element)
  mic = hs.audiodevice.findDeviceByUID(device_uid)
  if event_name == 'mute' then

    is_synced = true
    is_muted = mic:inputMuted()

    if is_muted ~= self.muted then
        is_synced = false
    end

    if self.muted then
      if not is_synced then
        -- want muted, is now unmuted
        hs.alert('UNMUTED Externally', self.red)
        if self.enforce_state then
          self:mute(true)
        else
          self:unmute(true)
        end
      end
    else -- self.muted = false
      if not is_synced then
        -- want unmuted, now muted
        hs.alert('MUTED Externally', self.yellow)
        if self.enforce_state then
          self:unmute(true)
        else
          self:mute(true)
        end
      end
    end
  end
end

-- ## Spoon mechanics (`bind`, `init`)

obj.hotkeys   = {}
obj.unmute_bg = nil
obj.mute_bg   = nil
obj.muted     = nil
obj.enforce_state = false
obj.red = hs.fnutils.copy(hs.alert.defaultStyle)
obj.red.fillColor = {
    alpha = 0.7,
    red   = 1
}
obj.red.strokeColor = {
    alpha = 1,
    red   = 1
}
obj.yellow = hs.fnutils.copy(hs.alert.defaultStyle)
obj.yellow.fillColor = {
    alpha = 1,
    red   = 1,
    green = 1,
}
obj.yellow.strokeColor = {
    alpha = 1,
    red   = 0,
    green = 0,
    blue  = 0
}
obj.yellow.textColor = {
  alpha = 1,
  red   = 0,
  green = 0,
  blue  = 0
}

--- GlobalMute:bindHotkeys()
--- Method
--- Binds hotkeys for GlobalMute
---
--- Parameters:
---  * applist - A table containing hotkey details for defined applications:
---
--- A configuration example:
--- ``` lua
--- local hyper = {"ctrl", "alt", "cmd"}
--- hs.loadSpoon("GlobalMute")
--- spoon.GlobalMute:configure({
---   unmute_background = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png',
---   mute_background   = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png',
---   enforce_desired_state = true,
---})
--- spoon.GlobalMute:bindHotkeys({
---  unmute = {hyper, "u"},
---  mute   = {hyper, "m"},
---  toggle = {hyper, "space"}
--- })
--- spoon.GlobalMute._logger.level = 3
--- ```
---
function obj:bindHotkeys(mapping)
  logger.i("Bind Hotkeys for GlobalMute")

  -- `unmute` hotkey
  if mapping.unmute then
    self.hotkeys[#self.hotkeys + 1] = hs.hotkey.bind(
      mapping.unmute[1],
      mapping.unmute[2],
      function() self:unmute() end)
  end

  if mapping.mute then
    self.hotkeys[#self.hotkeys + 1] = hs.hotkey.bind(
      mapping.mute[1],
      mapping.mute[2],
      function() self:unmute() end,
      function() self:mute() end)
  end

  if mapping.toggle then
    self.hotkeys[#self.hotkeys + 1] = hs.hotkey.bind(
      mapping.toggle[1],
      mapping.toggle[2],
      function() self:toggle() end)
  end
end

--- GlobalMute:configure(conf)
--- Method
--- Set spoon level configuration
function obj:configure(conf)
  logger.i("Set configuration for GlobalMute")
  for key,confitem in pairs(conf) do
    if key == 'unmute_background' then
      self.unmute_bg = confitem
    end
    if key == 'mute_background' then
      self.mute_bg = confitem
    end
    if key == 'enforce_desired_state' then
      self.enforce_state = confitem
    end
  end
  if self.mute_bg == nil then
    self.mute_bg = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png'
  end
  if self.unmute_bg == nil then
    self.unmute_bg = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png'
  end
  self:mute(true)
  self.muted = true
end

--- GlobalMute:init()
--- Method
--- Currently does nothing (implemented so that treating this Spoon like others won't cause errors).
function obj:init()
  -- void (but it could be used to initialize the module)
  for _, device in pairs(hs.audiodevice.allInputDevices()) do
    device:watcherCallback(hs.fnutils.partial(self.microphone_changes, self)):watcherStart()
    logger.w("Setting up watcher for audio device ".. device:name())
  end
end

return obj