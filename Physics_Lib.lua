-- THIS IS FOR PHYSICS FUNCTIONS AND RELATED STUFF
-- ALSO USEFUL FOR GAMES

---@section Acceleration
---@param force LBVec
---@param mass number
---@return LBVec
function Acceleration(force, mass)
    return force:lbvec_scale(1 / mass)
end
---@endsection

---@section GravitationalForce
---@param mass number
---@return LBVec
function GravitationalForce(mass)
    return LifeBoatAPI.LBVec:new(0, GameEngine.gravity * mass)
end
---@endsection

---@section DragForce
---@param velocity LBVec
---@param drag number
---@return LBVec
function DragForce(velocity, drag)
    local dragForceMagnitude = velocity:lbvec_length()^2 * drag
    return velocity:lbvec_normalize():lbvec_scale(-dragForceMagnitude)
end
---@endsection

---@section SimpleCollision
---@param objectA BaseObject
---@param objectB BaseObject
---@return boolean
function SimpleCollision(objectA, objectB)
    local widthA, heightA, widthB, heightB = objectA.width, objectA.height, objectB.width, objectB.height
    local positionA, positionB = objectA.position, objectB.position

    local areColliding =
    (
        positionA.x < positionB.x + widthB and
        positionA.x + widthA > positionB.x and
        positionA.y < positionB.y + heightB and
        positionA.y + heightA > positionB.y
    )

    return areColliding
end
---@endsection

---@section AdvancedCollision
---@param shapeA BaseShape
---@param shapeB BaseShape
---@return LBVec, number
function AdvancedCollision(shapeA, shapeB)
    local penDepth, normal = 0, LifeBoatAPI.LBVec:new()
    -- Type times



    return normal, penDepth
end
---@endsection

---@section CircleCircleCollision
---@param circleA CircleShape
---@param circleB CircleShape
---@return LBvec, number
function CircleCircleCollision(circleA, circleB)
    local maxDistance = circleA.radius + circleB.radius
    local actualDistance = LifeBoatAPI.LBVec.lbvec_distance(circleA.position, circleB.position)
    local angle = LifeBoatAPI.LBVec.lbvec_anglebetween(circleA.position, circleB.position)
    
    local deltaDistance = maxDistance-actualDistance
    return deltaDistance > 0 and LifeBoatAPI.LBVec:new(math.cos(angle), math.sin(angle)) or nil, deltaDistance > 0 and  deltaDistance or nil
end
---@endsection

---@section PolygonPolygonCollision
---@param polygonA BaseShape --These can also be a RotatedRectangle
---@param polygonB BaseShape
---@return LBVec, number
function PolygonPolygonCollision(polygonA, polygonB)
    -- The vertices of both types have a dedicated function
    -- I am starting to think I should be directly modifying the vertices tbh
    local verticesPolygonA, verticesPolygonB =  polygonA.type == "RotatedRectangle" and polygonA:GetRotatedCorners() or polygonA.type == "Polygon" and polygonA.GetRotatedVertices(),
                                                polygonB.type == "RotatedRectangle" and polygonB:GetRotatedCorners() or polygonB.type == "Polygon" and polygonB.GetRotatedVertices()

    -- The way RotatedRectangle is set up, it will always center on its position
    local centroidPolygonA, centroidPolygonB =  polygonA.type == "RotatedRectangle" and polygonA.position or polygonA.type == "Polygon" and polygonA.GetCentroid(),
                                                polygonB.type == "RotatedRectangle" and polygonB.position or polygonB.type == "Polygon" and polygonB.GetCentroid()
    
    -- This is temporarily going here, just to make something functional
    -- Ideally this goes in the related class

    -- Edges:
        local edgesA, edgesB = {}, {}

        for i = 1, #verticesPolygonA do
            local j = (i % #verticesPolygonA) + 1 -- Wrap around
            local edge = LifeBoatAPI.LBVec:new(verticesPolygonA[j].x - verticesPolygonA[i].x + polygonA.position.x, verticesPolygonA[j].y - verticesPolygonA[i].y + polygonA.position.y)
            table.insert(edgesA, edge)
        end
        for i = 1, #verticesPolygonB do
            local j = (i % #verticesPolygonB) + 1 -- Wrap around
            local edge = LifeBoatAPI.LBVec:new(verticesPolygonB[j].x - verticesPolygonB[i].x + polygonB.position.x, verticesPolygonB[j].y - verticesPolygonB[i].y + polygonB.position.y)
            table.insert(edgesB, edge)
        end

    -- Normals:

    -- Check outwards-ness of normals

    -- Projections

    -- Check overlap projection

    -- Final checks

    -- Dont forget returns
    return idk, idk
end
---@endsection