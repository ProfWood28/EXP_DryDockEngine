-- CONTAINS CLASSES FOR RENDERING DIFFERENT SHAPES

-- This rewrite moves to a different model, where we have BaseShape, Triangle and Convex N-sided Polyon.
-- This would allow easier creation of more complex shapes.

-- Honestly, I am not sure we even need BaseShape...?

ShapeTypes = {
    Base = "BaseShape",
    Polygon = "Polygon",
    Circle = "Circle",
    Triangle = "Triangle"
}

---@section BaseShape 1 _BASESHAPE_
---@class BaseShape
---@field int id
---@field position LBVec
---@field rotation number
---@field scale number
---@field color table
---@field type string
BaseShape = {
    ---@param self BaseShape
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _scale number
    ---@return BaseShape
    new = function(self, _position, _rotation, _scale)
        return LifeBoatAPI.lb_copy(self, {
            id = nil,
            position = _position,
            rotation = _rotation,
            scale = _scale,
            color = {255, 255, 255, 255},
            type = ShapeTypes.Base,
        })
    end;

    ---@section SetPosition
    ---@param self BaseShape
    SetPosition = function (self, vector)
        self.position = vector
    end;
    ---@endsection

    ---@section SetRotation
    ---@param self BaseShape
    SetRotation = function (self, angle)
        self.rotation = angle
    end;
    ---@endsection

    ---@section SetScale
    ---@param self BaseShape
    SetScale = function (self, s)
        self.scale = s
    end;
    ---@endsection

    ---@section SetColor
    ---@param self BaseShape
    SetColor = function (self, r,g,b,a)
        self.color = {r,g,b,a}
    end;
    ---@endsection
    
    ---@section GetAABB
    ---@param self BaseShape
    ---@return table
    getAABB = function(self)
        return {minX=self.position.x, maxX=self.position.x,
                minY=self.position.y, maxY=self.position.y}
    end;
    ---@endsection

    ---@section Draw
    ---@param self BaseShape
    Draw = function(self) end;
    ---@endsection
}
---@endsection _BASESHAPE_


---@section Polygon 1 _POLYGON_
---@class Polygon
---@field id number
---@field position LBVec
---@field rotation number
---@field scale number
---@field color table
---@field type string
---@field vertices table
Polygon = LifeBoatAPI.lb_copy(BaseShape, {
    ---@section SortVertices
    ---@param self Polygon
    ---@param vertices table 
    ---@return table
    SortVertices = function (self, vertices)
        local t_x, t_y = 0, 0
        for _, vertice in ipairs(vertices) do
            t_x = t_x + vertice.x
            t_y = t_y + vertice.y
        end
        local a_x, a_y = t_x / #vertices, t_y / #vertices

        local angleVertices = {}
        for i, vertice in ipairs(vertices) do
            local angle = math.atan(vertice.y - a_y, vertice.x - a_x)
            angleVertices[i] = {vertex = vertice, angle = angle}
        end

        table.sort(angleVertices, function(a, b)
            return a.angle < b.angle
        end)

        local sorted = {}
        for i, pair in ipairs(angleVertices) do
            sorted[i] = pair.vertex
        end

        local finalVertices = {}
        local n = #sorted
        for i = 1, n do
            local prev = sorted[(i - 2) % n + 1]
            local curr = sorted[i]
            local next = sorted[i % n + 1]

            local area = (prev.x - curr.x)*(next.y - curr.y) - (next.x - curr.x)*(prev.y - curr.y)

            if math.abs(area) > 1e-8 then
                finalVertices[#finalVertices + 1] = curr
            end
        end

        return finalVertices
    end;
    ---@endsection

    ---@param self Polygon
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _scale number
    ---@param _vertices table
    ---@param _doFill boolean
    ---@return Polygon
    new = function(self, _position, _rotation, _scale, _vertices, _doFill)
        local obj = BaseShape.new(self, _position, _rotation, _scale)
        local vertices = Polygon.SortVertices(_vertices)
        obj.vertices = vertices
        obj.doFill = _doFill
        obj.type = ShapeTypes.Polygon
        return obj
    end;

    ---@section Triangulate
    ---@param self Polygon
    ---@param vertices table
    ---@return table
    Triangulate = function (self, vertices)
        local tris, anchor = {}, vertices[1]
        for i = 1, #vertices-2 do
            tris[i] = {anchor, vertices[i+1], vertices[i+2]}
        end

        return tris
    end;
    ---@endsection
    
    
    ---@section GetScaledVertices
    ---@param self Polygon
    ---@param vertices table
    ---@return table
    GetScaledVertices = function (self, vertices)
        local scaledVertices = {}
        for i, vertice in ipairs(vertices) do
            scaledVertices[i] = vertice:lbvec_scale(self.scale)
        end
        return scaledVertices
    end;
    ---@endsection

    ---@section GetRotatedVertices
    ---@param self Polygon
    ---@param vertices table
    ---@return table
    GetRotatedVertices = function (self, vertices)
        local cosR, sinR, rotatedVertices = math.cos(self.rotation), math.sin(self.rotation), {}
        for i, vertice in ipairs(vertices) do
            local rotatedX = vertice.x * cosR - vertice.y * sinR
            local rotatedY = vertice.x * sinR + vertice.y * cosR
            rotatedVertices[i] = LifeBoatAPI.LBVec:new(rotatedX, rotatedY)
        end
        return rotatedVertices
    end;
    ---@endsection
    
    ---@section GetTransformedVertices
    ---@param self Polygon
    ---@param vertices table
    ---@return table
    GetTransformedVertices = function (self, vertices)
        local transformedVerices = {}
        for i, vertice in ipairs(vertices) do
            transformedVerices[i] =  self.position:lbvec_add(vertice)
        end
        return transformedVerices
    end;
    ---@endsection

    ---@section Draw
    ---@param self Polygon
    Draw = function (self)
        local modifiedVertices = self.GetTransformedVertices(self.GetRotatedVertices(self.GetScaledVertices(self.vertices)))
        
        screen.setColor(self.color[1], self.color[2], self.color[3], self.color[4])

        if self.doFill then 
            local triangles = self.Triangulate(modifiedVertices)
            for _, triangle in ipairs(triangles) do
                screen.drawTriangleF(triangle[1], triangle[2], triangle[3])
            end
        else
            for i = 1, #modifiedVertices-1 do
                local v1, v2 = modifiedVertices[i], modifiedVertices[i+1]
                screen.drawLine(v1.x, v1.y, v2.x, v2.y)
            end
            local v1, v2 = modifiedVertices[#modifiedVertices], modifiedVertices[1]
            screen.drawLine(v1.x, v1.y, v2.x, v2.y)
        end
    end;
    ---@endsection
})
---@endsection _POLYGON_