--- THIS IS A WORK IN PROGRESS
--- IF IT IS NOT MORE COMPACT FOR A REASONABLE NUMBER OF OBJECTS
--- I WILL PUT IT ON THE BACK BURNER


---@section AddObjectToPrefabs
function AddObjectToPrefabs(object, name)
    if not Prefabs[name] then
        Prefabs[name] = object
    end
end
---@endsection

---@section AddClassToIndex
function AddClassToIndex(class, shorthand)
    if not Classes[shorthand] then
        Classes[shorthand] = class
    end
end
---@endsection

---@section CreateObjectFromProperty
function CreateObjectFromProperty(propertyName)
    -- 128 character limit per text property
    --[[
    The structure should be as the constructor is done, in the same order.
    Syntax:
        n: Number
        s: String
        b: Boolean
            o: True
            x: False
        v: Vector
        t: Table
        c: Class
            BS = BaseShape
            PG = Polygon
            CI = Circle
            BO = BaseObject
            PO = PhysicsObject
        f: Shape (Prefab)
        l: Layer
    ]]

    --Example: c:PO;v:144,80;n:0;n:1;s:"Player";n:12;l:"Asteroids"s:"PlayerShape";
    
end
---@endsection

---@section CreateObjectsFromTable
function CreateObjectsFromTable(table)
    for _, objString in ipairs(table) do
        CreateObjectFromProperty(objString)
    end
end
---@endsection