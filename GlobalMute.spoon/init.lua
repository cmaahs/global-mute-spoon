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
  local screens = hs.screen.allScreens()
  for _, newScreen in ipairs(screens) do
    newScreen:desktopImageURL(bgfile)
  end
end

-- ### Utilities

-- ## Public

--- GlobalMute:toggle()
--- Method
--- Mute all system sound input, force to mute
function obj:toggle()
  if self.muted then
    -- muted, now unmute
    self:unmute()
  else
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
function obj:unmute()
  is_changed = false
  for _, device in pairs(hs.audiodevice.allInputDevices()) do
      is_muted = device:inputMuted()

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

-- ## Spoon mechanics (`bind`, `init`)

obj.hotkeys   = {}
obj.unmute_bg = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png'
obj.mute_bg   = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png'
obj.muted     = nil

--- GlobalMute:bindHotkeys()
--- Method
--- Binds hotkeys for CacadeWindows
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
  end
  self:mute(true)
  self.muted = true
end


--- GlobalMute:init()
--- Method
--- Currently does nothing (implemented so that treating this Spoon like others won't cause errors).
function obj:init()
  -- void (but it could be used to initialize the module)
  self:mute(true)
  self.muted = true
end

return obj