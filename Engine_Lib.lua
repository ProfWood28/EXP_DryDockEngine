-- THE ENGINE CODE
-- Houses the code for things like handling objects
-- idk *exactly* how Im gonna do this tbh

GameEngine = {
    deltaTime = 1 / 60,
    gravity = 9.81,
    GameObjects = {},
    ScheduledRemovals = {},
    screenWidth = 0,
    screenHeight = 0,
    ticks = 0,
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

---@section ScheduleRemoveGameObject
function ScheduleRemoveGameObject(gameObject)
    if not FindInTable(GameEngine.ScheduledRemovals, function(o) return o.id == gameObject.id end) then table.insert(GameEngine.ScheduledRemovals, gameObject) end
end
---@endsection

---@section HandleScheduledRemovals
function HandleScheduledRemovals()
    local toRemove = {}
    for _, obj in ipairs(GameEngine.ScheduledRemovals) do
        local _, index = FindInTable(GameEngine.GameObjects, function(o) return o.id == obj.id end)
        if index then
            table.insert(toRemove, index)
        end
    end
    table.sort(toRemove, function(a,b) return a>b end)
    for _, index in ipairs(toRemove) do
        table.remove(GameEngine.GameObjects, index)
    end
    GameEngine.ScheduledRemovals = {}
end
---@endsection

---@section UpdateGameObject
function UpdateGameObject(gameObject)
    -- Call the Update method of the game object
    gameObject:Update()
    GameEngine.ticks = GameEngine.ticks + 1
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
    HandleScheduledRemovals()
    
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
    local obj = FindInTable(GameEngine.GameObjects, function(o)
        return o.id == id
    end)
    return obj
end
---@endsection

---@section GetObjectFromName
---@param name string
---@return BaseObject
function GetObjectFromName(name)
    local obj = FindInTable(GameEngine.GameObjects, function(o)
        return o.name == name
    end)
    return obj
end
---@endsection

---@section GetObjectsFromLayer
---@param layer string
---@return table
function GetObjectsFromLayer(layer)
    return FindAllInTable(GameEngine.GameObjects, function(obj)
        return TableContainsValue(obj.layers, layer) ~= nil
    end)
end
---@endsection

---@section HandleCollisions
function HandleCollisions()
    local allObjects = GameEngine.GameObjects

    for i = 1, #allObjects - 1 do
        for j = i + 1, #allObjects do
            local o1, o2 = allObjects[i], allObjects[j]

            -- Skip if they share no layers
            if not ShareLayer(o1.layers, o2.layers) then
                goto continue
            end

            local depth, normal = AdvancedCollision(o1, o2)

            if normal then
                o1:OnCollision(o2, depth, normal)
                o2:OnCollision(o1, depth, normal:lbvec_scale(-1))
            end

            ::continue::
        end
    end
end
---@endsection

---@section ShareLayer
function ShareLayer(layers1, layers2)
    for _, l1 in ipairs(layers1) do
        for _, l2 in ipairs(layers2) do
            if l1 == l2 then
                return true
            end
        end
    end
    return false
end
---@endsection
