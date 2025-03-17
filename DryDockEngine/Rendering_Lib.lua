-- CONTAINS CLASSES FOR RENDERING DIFFERENT SHAPES
-- EVERYTHING NEEDS TO BE POLYGONS >:[

---@section BaseShape 1 _BASESHAPE_
---@class BaseShape
---@field int id
---@field position LBVec
---@field rotation number
---@field width number
---@field height number
---@field color table
BaseShape = {
    ---@param self BaseShape
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _width number
    ---@param _height number
    ---@return BaseShape
    new = function(self, _position, _rotation, _width, _height)
        return LifeBoatAPI.lb_copy(self, {
            id = nil,
            position = LifeBoatAPI.LBVec:new(LifeBoatAPI.LBMaths.lbmaths_round(_position.x), LifeBoatAPI.LBMaths.lbmaths_round(_position.y)),
            rotation = _rotation,
            width = _width,
            height = _height,
            color = {255, 255, 255, 255},
        })
    end;

    ---@section GetActualDimensions
    ---@param self BaseShape
    ---@return number, number
    GetActualDimensions = function(self)
        return self.width, self.height
    end;
    ---@endsection
}
---@endsection _BASESHAPE_

---@section Polygon 1 _POLYGON_
---@class Polygon : BaseShape
---@field vertices table
---@field doFill boolean
Polygon = LifeBoatAPI.lb_copy(BaseShape, {
    ---@param self Polygon
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _vertices table
    ---@param _doFill boolean
    ---@return Polygon
    new = function(self, _position, _rotation, _vertices, _doFill)
        local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
        for _, v in ipairs(_vertices) do
            minX, maxX = math.min(minX, v.x), math.max(maxX, v.x)
            minY, maxY = math.min(minY, v.y), math.max(maxY, v.y)
        end

        local width = maxX - minX
        local height = maxY - minY
        local obj = BaseShape.new(self, _position, _rotation, width, height)
        obj.vertices = _vertices -- Store local (unrotated) vertices
        obj.doFill = _doFill
        return obj
    end;

    ---@section GetRotatedVertices
    ---@param self Polygon
    ---@return table
    GetRotatedVertices = function(self)
        local rotatedVertices = {}
        local cosR, sinR = math.cos(self.rotation), math.sin(self.rotation)
        
        for index, vertice in ipairs(self.vertices) do
            local rotatedX = vertice.x * cosR - vertice.y * sinR
            local rotatedY = vertice.x * sinR + vertice.y * cosR
            rotatedVertices[index] = LifeBoatAPI.LBVec:new(rotatedX, rotatedY)
        end
        
        return rotatedVertices
    end;
    ---@endsection

    ---@section GetActualDimensions
    ---@param self Polygon
    ---@return number, number
    GetActualDimensions = function(self)
        local rotatedVertices = self:GetRotatedVertices()
        local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge

        for _, v in ipairs(rotatedVertices) do
            minX, maxX = math.min(minX, v.x), math.max(maxX, v.x)
            minY, maxY = math.min(minY, v.y), math.max(maxY, v.y)
        end

        return maxX - minX, maxY - minY
    end;
    ---@endsection
    
    ---@section Draw
    ---@param self Polygon
    Draw = function(self)
        screen.setColor(self.color[1], self.color[2], self.color[3], self.color[4])

        local verticesToDraw = self:GetRotatedVertices()
        local triangle = self.doFill and screen.drawTriangleF or screen.drawTriangle
        triangle(
            verticesToDraw[1].x + self.position.x, verticesToDraw[1].y + self.position.y, 
            verticesToDraw[2].x + self.position.x, verticesToDraw[2].y + self.position.y, 
            verticesToDraw[3].x + self.position.x, verticesToDraw[3].y + self.position.y
        )
    end;
    ---@endsection
})
---@endsection _POLYGON_


---@section RotatedRectangle 1 _ROTATEDRECTANGLE_
---@class RotatedRectangle : BaseShape
---@field corners table
---@field polygons table
---@field doFill boolean
RotatedRectangle = {
    ---@param self RotatedRectangle
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _width number
    ---@param _height number
    ---@param _doFill boolean
    ---@return RotatedRectangle
    new = function(self, _position, _rotation, _width, _height, _doFill)
        local corners = {
            LifeBoatAPI.LBVec:new(-(_width / 2), -(_height / 2)), -- Top-left
            LifeBoatAPI.LBVec:new((_width / 2), -(_height / 2)),  -- Top-right
            LifeBoatAPI.LBVec:new((_width / 2), (_height / 2)),   -- Bottom-right
            LifeBoatAPI.LBVec:new(-(_width / 2), (_height / 2)),  -- Bottom-left
        }

        local obj = BaseShape.new(self, _position, _rotation, _width, _height)
        obj.doFill = _doFill
        obj.corners = corners

        if _doFill then
            -- Create triangles (polygons) for a filled rectangle
            obj.polygons = {
                Polygon:new(_position, _rotation, { corners[1], corners[2], corners[4] }, _doFill),
                Polygon:new(_position, _rotation, { corners[4], corners[3], corners[2] }, _doFill),
            }
        else
            -- No polygons needed for an unfilled rectangle
            obj.polygons = nil
        end

        return obj
    end;

    ---@section GetActualDimensions
    ---@param self RotatedRectangle
    ---@return number, number
    GetActualDimensions = function(self)
        local cosR = math.abs(math.cos(self.rotation))
        local sinR = math.abs(math.sin(self.rotation))
        local rotatedWidth = self.width * cosR + self.height * sinR
        local rotatedHeight = self.width * sinR + self.height * cosR
        return rotatedWidth, rotatedHeight
    end;
    ---@endsection

    ---@section Draw
    ---@param self RotatedRectangle
    Draw = function(self)
        screen.setColor(self.color[1], self.color[2], self.color[3], self.color[4])

        if self.doFill and self.polygons then
            -- Draw the filled rectangle using polygons
            for _, polygon in ipairs(self.polygons) do
                polygon.position = self.position
                polygon.rotation = self.rotation
                polygon.color = self.color
                polygon:Draw()
            end
        else
            -- If filling is disabled, draw lines between corners
            local rotatedCorners = {}

            -- Rotate and translate corners
            for _, corner in ipairs(self.corners) do
                local rotatedX = corner.x * math.cos(self.rotation) - corner.y * math.sin(self.rotation) + self.position.x
                local rotatedY = corner.x * math.sin(self.rotation) + corner.y * math.cos(self.rotation) + self.position.y
                table.insert(rotatedCorners, LifeBoatAPI.LBVec:new(rotatedX, rotatedY))
            end

            -- Draw the outline by connecting corners
            for i = 1, #rotatedCorners do
                local nextIndex = (i % #rotatedCorners) + 1
                screen.drawLine(rotatedCorners[i].x, rotatedCorners[i].y,
                                rotatedCorners[nextIndex].x, rotatedCorners[nextIndex].y)
            end
        end
    end;
    ---@endsection

}
---@endsection _ROTATEDRECTANGLE_


---@section CircleShape 1 _CIRCLESHAPE_
---@class CircleShape : BaseShape
---@field radius number
---@field doFill boolean
CircleShape = LifeBoatAPI.lb_copy(BaseShape, {
    ---@param self CircleShape
    ---@param _position LBVec
    ---@param _rotation number
    ---@param _radius number
    ---@param _doFill boolean
    ---@return CircleShape
    new = function(self, _position, _rotation, _radius, _doFill)
        local obj = BaseShape.new(self, _position, _rotation, 2*_radius, 2*_radius)
        obj.radius = _radius
        obj.doFill = _doFill
        return obj
    end;

    ---@section GetActualDimensions
    ---@param self CircleShape
    ---@return number, number
    GetActualDimensions = function(self)
        return self.width, self.height
    end;
    ---@endsection

    ---@section Draw
    ---@param self CircleShape
    Draw = function(self) 
        screen.setColor(self.color[1], self.color[2], self.color[3], self.color[4])
        
        circle = self.doFill and screen.drawCircleF or screen.drawCircleF

        circle(self.position.x, self.position.y, self.radius)
    end;
    ---@endsection
})
---@endsection _CIRCLESHAPE_