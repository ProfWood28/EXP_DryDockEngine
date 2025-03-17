
# The Dry Dock Engine

The Dry Dock Engine is a class-based 2D game engine library.

It is made with for use in combination with the LifeBoatAPI and the Stormworks Lua VSCode Extension by [@nameouschangey](https://github.com/nameouschangey).


You can add libraries to the extension via GitHub link. 
Simply right-click your folders, and then select 'Stormworks: Add Library From Url'. Now copy-paste this into the textbox that shows up:
```
https://github.com/ProfWood28/DryDockEngine.git
```
If all went well, you should now have the library! You should be able to find it under: `_build\libs\ProfWood28\DryDockEngine`.
When you want to use the engine, simply add the filepath in a `require()` as follows:
```lua
-- This assumes that you used the 'Add Library From Url'
-- It will add the entire engine, though rest assured, it strips anything you do not use
require("ProfWood28.DryDockEngine.DryDockEngine")

-- You can also add only parts of the whole library like this:
require("ProfWood28.DryDockEngine.Class_Lib")
```

If needed, outside restarting the editor, you can also always update the library from the same right-click menu as where you found 'Add Library From Url'. 
It will be called 'Stormworks: Update Libraries', and after clicking it, you should be up-to-date with the latest version.


Active work is being done, and some features are very much not working/inefficient/weirdly done/incomplete. 
This is very much still a WIP.

Feel free to contact me about any questions or feedback you might have. Have fun and good luck!
## Features

- Class-based logic
- Lua, but using Object-Oriented-Programming (OOP) principles
- Object and Shape libraries
- Physics library


## Authors

- [@ProfWood28](https://github.com/ProfWood28)


## Acknowledgements

 - [LifeBoatAPI](https://github.com/nameouschangey/Stormworks_LifeBoatAPI_MC)
 - [Stormworks Lua VSCode Extension](https://github.com/nameouschangey/Stormworks_VSCodeExtension)


## Usage/Examples

Here is how you can create and add a simple object to the engine:
```lua
-- Creating a new object:
object = BaseObject:new(LifeBoatAPI.LBVec:new(xPos, yPos), rot, width, height, "Name")

-- Adding the object to the game engine:
AddGameObject(object)

-- The object currently does not have anything to render, so add a shape to it:
-- Create new shape, in this case a filled rectangle with some basic parameters
rect = RotatedRectangle:new(object.position, object.rotation, object.width, object.height, true)
-- Add it to the object
object:AddShape(rect)

-- The default colour is white, but we can change it for every shape like this:
object:SetColor({255, 0, 255, 255})

-- Now to actually update and render your object, do the following:
function onTick()
    DoUpdate()
end

function onDraw()
    DoDraw()
end
```
