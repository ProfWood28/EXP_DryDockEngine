-- THE ENGINE CODE
-- Houses the code for things like handling objects
-- idk *exactly* how Im gonna do this tbh

GameEngine = {
    deltaTime = 1 / 60,
    gravity = 9.81,
    GameObjects = {},
    screenWidth = 0,
    screenHeight = 0,
}

---@section AddGameObject
function AddGameObject(gameObject)
    gameObject.id = #GameEngine.GameObjects + 1 -- Assign a unique ID
    table.insert(GameEngine.GameObjects, gameObject)
end
---@endsection

---@section RemoveGameObject
function RemoveGameObject(gameObject)
    for index, obj in ipairs(GameEngine.GameObjects) do
        if obj.id == gameObject.id then
            table.remove(GameEngine.GameObjects, index)
            break
        end
    end
end
---@endsection

---@section UpdateGameObject
function UpdateGameObject(gameObject)
    -- Call the Update method of the game object
    gameObject:Update()
end
---@endsection

---@section DrawGameObject
function DrawGameObject(gameObject)
    -- Call the Draw method of the game object
    gameObject:Draw()
end
---@endsection

---@section Update
function DoUpdate()
    for _, obj in ipairs(GameEngine.GameObjects) do
        UpdateGameObject(obj)
    end
end
---@endsection

---@section Draw
function DoDraw()
    GameEngine.screenWidth, GameEngine.screenHeight = screen.getWidth(), screen.getHeight()

    for _, obj in ipairs(GameEngine.GameObjects) do
        DrawGameObject(obj)
    end
end
---@endsection

---@section GetObjectFromID
---@param id number
---@return BaseObject
function GetObjectFromID(id)
    for _, obj in ipairs(GameEngine.GameObjects) do
        if(obj.id == id) then 
            return obj
        end
    end
    return nil
end
---@endsection

---@section GetObjectFromName
---@param name string
---@return BaseObject
function GetObjectFromName(name)
    for _, obj in ipairs(GameEngine.GameObjects) do
        if(obj.name == name) then 
            return obj
        end
    end
    return nil
end
---@endsection

