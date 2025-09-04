---@section TableContainsValue
---@param t table
---@param v any
---@return number
function TableContainsValue(t, v)
    for i, value in ipairs(t) do
        if value == v then
            return i
        end
    end
    return nil
end
---@endsection

---@section FindInTable
---@param t table
---@param predicate fun(value:any):boolean
---@return any, number
function FindInTable(t, predicate)
    for i, value in ipairs(t) do
        if predicate(value) then
            return value, i
        end
    end
    return nil, nil
end
---@endsection

---@section FindAllInTable
---@param t table
---@param predicate fun(value:any):boolean
---@return table
function FindAllInTable(t, predicate)
    local results = {}
    for _, value in ipairs(t) do
        if predicate(value) then
            table.insert(results, value)
        end
    end
    return results
end
---@endsection

---@section RemoveFromTable
---@param t table
---@param v any
---@return boolean
function RemoveFromTable(t, v)
    local id = TableContainsValue(t, v)
    if id then table.remove(t, id) end
    return id ~= nil
end
---@endsection

---@section RandomOnUnitRect
---@return number, number
function RandomOnUnitRect()
    local r = math.random()
    local x = math.min(1, math.max(0, math.abs((r * 4 - 0.5) % 4 - 2) - 0.5))
    local y = math.min(1, math.max(0, math.abs((r * 4 + 0.5) % 4 - 2) - 0.5))
    return x, y
end
---@endsection

---@section RandomOnRect
---@param position LBVec
---@param dimensions LBVec
function RandomOnRect(position, dimensions)
    local rx, ry = RandomOnUnitRect()
    return LifeBoatAPI.LBVec:new(position.x + rx * dimensions.x, position.y + ry * dimensions.y) 
end
---@endsection
