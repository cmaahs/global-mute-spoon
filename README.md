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

## Special Note for ZOOM users

ZOOM meetings through me for a bit of loop when I discovered that my MIC was being opened seemingly randomly.  It turns out that
ZOOM will now unmute your system mic devices at startup, independently of it's own MUTE operation.  Even opening the Settings/Audio
panel will unmute the system mic devices.  And of course this is BAD.  Bad, bad programmers at Zoom!  There doesn't seem to be a
way to stop this nefarious behavior through settings.

Presumably other collaboration/conference tools may also practice this behavior, so a callback was added to handle this change.

## The glories of Mojave

It turns out that some of my fellow MacOS users haven't upgraded to Mojave yet, and thus the whole changing the background colors doesn't
actually show through their menubar and dock.  How quickly one forgets that those didn't used to be transparent...

So, in with the OLD, and some extra options to add some text to make it more visible that you are unmuted... Which of course is the whole point.

I've brought back the Microphone icon from the original Push2Talk.lua script, and added an option to add a Title/Text component to it.

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

if grep -Fxq 'spoon.GlobalMute:bindHotkeys({ unmute = {lesshyper, "u"}, mute   = {lesshyper, "m"}, toggle = {hyper, "space"} })' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'spoon.GlobalMute:bindHotkeys({ unmute = {lesshyper, "u"}, mute   = {lesshyper, "m"}, toggle = {hyper, "space"} })' >> ~/.hammerspoon/init.lua
fi

if grep -Fxq 'spoon.GlobalMute:configure({ unmute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png", mute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png", enforce_desired_state = true,})' ~/.hammerspoon/init.lua
then
    echo "line already exists."
else
    echo 'spoon.GlobalMute:configure({ unmute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png", mute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png", enforce_desired_state = true,})' >> ~/.hammerspoon/init.lua
fi
```

## Configuration

The configuration file looks like this:

```lua
local hyper     = {"ctrl", "alt", "cmd"}
local lesshyper = {"ctrl", "alt"}
hs.loadSpoon("GlobalMute")
spoon.GlobalMute:bindHotkeys({
  unmute = {lesshyper, "u"},
  mute   = {lesshyper, "m"},
  toggle = {hyper, "space"}
})
spoon.GlobalMute:configure({
  unmute_background = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png',
  mute_background   = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png',
  enforce_desired_state = true,
  unmute_title = "<---- THEY CAN HEAR YOU -----",
  mute_title = "<-- MUTE",
})
spoon.GlobalMute._logger.level = 3
```

The `enforced_desired_state` is the flag that handles when external forces make changes to the mute at a system level.  If set to
`false` your background will change and the new mute state will be accepted.  If set to `true` the GlobalMute spoon will make a
course correction and reset the system mute level on the device to what your current setting was.

The mute_title and unmute_title text will appear to the right of the microphone icon in the menubar.  Hopefully making it easier to
pickup on when you are actually unmuted.  If you don't want the mute_title text, simply don't provide that option to the configure
routine.

## TODO / Thoughts

The downside is that one cannot just change the background color of the menu bar on the mac.  Though in Dark Mode it is generally transparent and thus setting a Red/Orange background image allows it to bleed through.  Set the "mute_background" to your normal image that you use and when you are muted (the normal mode) your background will be normal.  This will be a problem for those who have adopted any **active** type backgrounds.  Possibly there is a way to handle this, certainly some AppleScript must be able to configure that feature.  It isn't high on my list of things, so if you have a burning desire to set an active background, feel free to submit a PR.