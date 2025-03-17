---@section BaseObject 1 _BASEOBJECT_
---@class BaseObject
---@field position LBVec
---@field rotation number
---@field width number
---@field height number
---@field name string
---@field id number
---@field shapes table
BaseObject = {
    ---@param self BaseObject
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _width number
    ---@param _height number
    ---@param _name string
    ---@return BaseObject
    new = function(self, _position, _rotation, _width, _height, _name)
        return LifeBoatAPI.lb_copy(self, {
            position = _position or LifeBoatAPI.LBVec:new(),
            rotation = _rotation or 0,
            width = _width or 0,
            height = _height or 0,
            name = _name or "",
            id = nil, -- ID will be assigned by the engine
            shapes = {}
        })
    end;

    ---@section GetForwards
    ---@param self BaseObject
    ---@param forwardsOffset number
    ---@return LBVec ForwardVector Returns the normalised forwards vector based on rotation and offset
    GetForwards = function(self, forwardsOffset)
        forwardOffset = forwardOffset or 0
        return LifeBoatAPI.LBVec:new(math.cos(self.rotation + forwardsOffset), math.sin(self.rotation + forwardsOffset))
    end;
    ---@endsection
    
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
        shape.id = #self.shapes
        table.insert(self.shapes, shape)
    end;
    ---@endsection
    
    ---@section SetColor
    ---@param self BaseShape
    ---@param color table
    SetColor = function (self, color)
        for _, shape in ipairs(self.shapes) do
            shape.color = color
        end
    end
}
---@endsection _BASEOBJECT_

---@section PhysicsObject 1 _PHYSICSOBJECT_
---@class PhysicsObject : BaseObject
---@field mass number
---@field velocity LBVec
PhysicsObject = LifeBoatAPI.lb_copy(BaseObject, {
    ---@param self PhysicsObject
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _width number
    ---@param _height number
    ---@param _name string
    ---@param _mass number
    ---@return PhysicsObject
    new = function(self, _position, _rotation, _width, _height, _name, _mass)
        local obj = BaseObject.new(self, _position, _rotation, _width, _height, _name)
        obj.mass = _mass or 1
        obj.velocity = LifeBoatAPI.LBVec:new()
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
    end
    ---@endsection
})
---@endsection _PHYSICSOBJECT_
