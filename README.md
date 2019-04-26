# Global Mute

With this script you can manage the mute/unmute of your computer's microphone at the system level.
Thus avoiding having to un-bury whatever window holds the button you need to click to mute or unmute
yourself.

This Spoon has three possible bindings: mute, unmute, and toggle.

If you don't specify a key binding for toggle, then you MUST specify a mute AND unmute key binding.
You can specify only the key binding for toggle and not define the other two.  The mute key binding
can be HELD down and used similarly to a walkie-talkie button.

One of my previous co-workers initially provided me with this particular feature in Hammerspoon.  His
original work can be found here: [Jesse Lang](https://github.com/jesselang/dotfiles)
The initial work contained an alert that would flash on a timer, keeping you aware that the MIC was
hot.  As I added monitors however, that alert would only flash on the monitor containing the front
most application.  As I made modifications, I also figured I would convert it to a Spoon format,
using the [Miro Windows Manager](https://github.com/miromannino/miro-windows-manager) code as my
baseline.

## Installation

This will create a ~/tmp temp file in your home directory and clone the repository into it, then move the Spoon to the ~/.hammerspoon/Spoons install directory.  Then add the base loading lines into your ~/.hammerspoon/init.lua file.  Once complete you can clean up the ~/tmp/global-mute-spoon directory as you see fit.

```bash
mkdir ~/tmp

cd ~/tmp && git clone https://github.com/cmaahs/global-mute-spoon.git
cd ~/tmp/global-mute-spoon
mv GlobalMute.spoon ~/.hammerspoon/Spoons

if grep -Fxq 'local hyper = {"ctrl", "alt", "cmd"}' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'local hyper = {"ctrl", "alt", "cmd"}' >> ~/.hammerspoon/init.lua
fi
if grep -Fxq 'local lesshyper = {"ctrl", "alt"}' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'local lesshyper = {"ctrl", "alt"}' >> ~/.hammerspoon/init.lua
fi

if grep -Fxq 'hs.loadSpoon("GlobalMute")' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'hs.loadSpoon("GlobalMute")' >> ~/.hammerspoon/init.lua
fi

if grep -Fxq 'spoon.GlobalMute:configure({ unmute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png", mute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png",})' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'spoon.GlobalMute:configure({ unmute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png", mute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png",})' >> ~/.hammerspoon/init.lua
fi

if grep -Fxq 'spoon.GlobalMute:bindHotkeys({ unmute = {lesshyper, "u"}, mute   = {lesshyper, "m"}, toggle = {hyper, "space"} })' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'spoon.GlobalMute:bindHotkeys({ unmute = {lesshyper, "u"}, mute   = {lesshyper, "m"}, toggle = {hyper, "space"} })' >> ~/.hammerspoon/init.lua
fi
```

## Configuration

The configuration file looks like this:

```lua
local hyper     = {"ctrl", "alt", "cmd"}
local lesshyper = {"ctrl", "alt"}
hs.loadSpoon("GlobalMute")
spoon.GlobalMute:configure({
  unmute_background = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png',
  mute_background   = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png',
})
spoon.GlobalMute:bindHotkeys({
  unmute = {lesshyper, "u"},
  mute   = {lesshyper, "m"},
  toggle = {hyper, "space"}
})
spoon.GlobalMute._logger.level = 3
```

## TODO / Thoughts

The downside is that one cannot just change the background color of the menu bar on the mac.  Though in Dark Mode it is generally transparent and thus setting a Red/Orange background image allows it to bleed through.  Set the "mute_background" to your normal image that you use and when you are muted (the normal mode) your background will be normal.  This will be a problem for those who have adopted any **active** type backgrounds.  Possibly there is a way to handle this, certainly some AppleScript must be able to configure that feature.  It isn't high on my list of things, so if you have a burning desire to set an active background, feel free to submit a PR.