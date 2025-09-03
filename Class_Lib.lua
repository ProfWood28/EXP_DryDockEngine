ObjectTypes = {
    Base = "BaseObject",
    Physics = "PhysicsObject",
}

---@section BaseObject 1 _BASEOBJECT_
---@class BaseObject
---@field position LBVec
---@field rotation number
---@field scale number
---@field name string
---@field id number
---@field shapes table
---@field type string
BaseObject = {
    ---@param self BaseObject
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _width number
    ---@param _height number
    ---@param _name string
    ---@return BaseObject
    new = function(self, _position, _rotation, _scale, _name)
        return LifeBoatAPI.lb_copy(self, {
            position = _position or LifeBoatAPI.LBVec:new(),
            rotation = _rotation or 0,
            scale = _scale or 1,
            name = _name or "",
            id = nil, -- ID will be assigned by the engine
            shapes = {},
            type = ObjectTypes.Base,
        })
    end;
    
    ---@section Update
    ---@param self BaseObject
    Update = function(self)
        
    end;
    ---@endsection

    ---@section Draw
    ---@param self BaseObject
    Draw = function(self)
        for _, shape in ipairs(self.shapes) do
            shape.position = self.position
            shape.rotation = self.rotation
            shape:Draw()
        end
    end;
    ---@endsection
    
    ---@section AddShape
    ---@param self BaseObject
    ---@param shape BaseShape
    AddShape = function(self, shape)
        shape.id = #self.shapes + 1
        table.insert(self.shapes, shape)
    end;
    ---@endsection
    
    ---@section RemoveShape
    ---@param self BaseObject
    ---@param shape BaseShape
    RemoveShape = function(self, shape)
        table.remove(self.shapes, shape.id)
    end;
    ---@endsection
    
    ---@section SetColor
    ---@param self BaseShape
    ---@param color table
    ---@param id number
    SetColor = function(self, color, id)
        id = id or nil
        for _, shape in ipairs(self.shapes) do
            if id ~= nil then
                shape.color = (shape.id == id) and color
            else
                shape.color = color
            end
        end
    end;
    
    ---@section SetPosition
    ---@param self BaseShape
    ---@param vector LBVec
    SetPosition = function(self, vector)
        self.position = vector

        for _, shape in ipairs(self.shapes) do
            shape:SetPosition(vector)
        end
    end;
    ---@endsection
    
    ---@section SetRotation
    ---@param self BaseShape
    ---@param angle number
    SetRotation = function(self, angle)
        self.rotation = angle

        for _, shape in ipairs(self.shapes) do
            shape:SetRotation(angle)
        end
    end;
    ---@endsection
    
    ---@section SetScale
    ---@param self BaseShape
    ---@param s number
    SetScale = function(self, s)
        self.scale = s
        
        for _, shape in ipairs(self.shapes) do
            shape:SetScale(s)
        end
    end;
    ---@endsection
    
    ---@section GetAABB
    ---@param self BaseObject
    ---@return table
    GetAABB = function(self)
        local AABB = {
            minX = self.position.x, maxX = self.position.x,
            minY = self.position.y, maxY = self.position.y,
            width = 0,
            height = 0,
            center = self.position
        }

        for _, shape in ipairs(self.shapes) do
            local ShapeAABB = shape:GetAABB()

            if ShapeAABB.minX < AABB.minX then AABB.minX = ShapeAABB.minX end
            if ShapeAABB.maxX > AABB.maxX then AABB.maxX = ShapeAABB.maxX end
            if ShapeAABB.minY < AABB.minY then AABB.minY = ShapeAABB.minY end
            if ShapeAABB.maxY > AABB.maxY then AABB.maxY = ShapeAABB.maxY end
        end

        AABB.width = AABB.maxX - AABB.minX
        AABB.height = AABB.maxY - AABB.minY
        AABB.center = LifeBoatAPI.LBVec:new((AABB.minX+AABB.maxX)/2, (AABB.minY+AABB.maxY)/2)

        return AABB
    end;
    ---@endsection
    
    ---@section GetWorldVertices
    ---@param self BaseObject
    ---@return table
    GetWorldVertices = function(self)
        local verticeTable = {}
        
        for _, shape in ipairs(self.shapes) do
            table.insert(verticeTable, shape:GetWorldVertices())
        end

        return verticeTable
    end;
    ---@endsection

    ---@section GetForwards
    ---@param self BaseObject
    ---@param forwardsOffset number
    ---@return LBVec ForwardVector Returns the normalised forwards vector based on rotation and offset
    getForwards = function(self, forwardsOffset)
        forwardOffset = forwardOffset or 0
        return LifeBoatAPI.LBVec:new(math.cos(self.rotation + forwardsOffset), math.sin(self.rotation + forwardsOffset))
    end;
    ---@endsection

}
---@endsection _BASEOBJECT_

---@section PhysicsObject 1 _PHYSICSOBJECT_
---@class PhysicsObject : BaseObject
---@field mass number
---@field velocity LBVec
---@field type string
PhysicsObject = LifeBoatAPI.lb_copy(BaseObject, {
    ---@param self PhysicsObject
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _scale number
    ---@param _name string
    ---@param _mass number
    ---@return PhysicsObject
    new = function(self, _position, _rotation, _scale, _name, _mass)
        local obj = BaseObject.new(self, _position, _rotation, _scale, _name)
        obj.mass = _mass or 1
        obj.velocity = LifeBoatAPI.LBVec:new()
        obj.type = ObjectTypes.Physics
        return obj
    end;

    ---@section ApplyForce
    ---@param self PhysicsObject
    ---@param totalForce LBVec
    ApplyForce = function(self, totalForce)
        local acceleration = Acceleration(totalForce, self.mass)
        self.velocity = self.velocity:lbvec_add(acceleration:lbvec_scale(GameEngine.deltaTime))
        self.position = self.position:lbvec_add(self.velocity:lbvec_scale(GameEngine.deltaTime))
    end;
    ---@endsection
    
    ---@section CollisionDetection
    ---@param self PhysicsObject
    ---@return number, PhysicsObject
    CollisionDetection = function(self)
        
        -- Returns both the penetration depth and object it collided with
        -- nil if no collision

        -- TBA!!!
        return nil, nil
    end
    ---@endsection
})
---@endsection _PHYSICSOBJECT_
