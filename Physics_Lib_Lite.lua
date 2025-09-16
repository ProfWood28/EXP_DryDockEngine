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

---@section AABBCollision
---@param object1 BaseObject
---@param object2 BaseObject
---@return boolean
function AABBCollision(object1, object2)
    local AABB1, AABB2, isColliding = object1:GetAABB(), object2:GetAABB(), false

    isColliding = (
        AABB1.maxX >= AABB2.minX and
        AABB1.minX <= AABB2.maxX and
        AABB1.maxY >= AABB2.minY and
        AABB1.minY <= AABB2.maxY
    )

    return isColliding
end
---@endsection

---@section AdvancedCollision
---@param object1 BaseShape
---@param object2 BaseShape
---@return number, LBVec
function AdvancedCollision(object1, object2)
    local minPenDepth, collisionNormal = math.huge, nil

    if not AABBCollision(object1, object2) then return minPenDepth, collisionNormal end

    local object1Shapes, object2Shapes = object1:GetWorldVertices(), object2:GetWorldVertices()

    local depth, normal
    for _, shapeData1 in ipairs(object1Shapes) do
        for _, shapeData2 in ipairs(object2Shapes) do

            depth, normal = PolygonPolygon(shapeData1, shapeData2)

            if depth > 0 and depth < minPenDepth then
                minPenDepth = depth
                collisionNormal = normal
            end
        end
    end

    if minPenDepth == math.huge then
        return 0, nil
    else
        return minPenDepth, collisionNormal
    end
end
---@endsection

---@section PolygonPolygon
---@param p1 table
---@param p2 table
---@return number, LBVec
PolygonPolygon = function(p1, p2)
    local axes = {}

    function addPerpEdges(poly)
        for i = 1, #poly.vertices do
            local nextIdx = (i % #poly.vertices) + 1
            local edge = poly.vertices[nextIdx]:lbvec_sub(poly.vertices[i])
            local axis = LifeBoatAPI.LBVec:new(-edge.y, edge.x):lbvec_normalize()
            table.insert(axes, axis)
        end
    end

    addPerpEdges(p1)
    addPerpEdges(p2)

    local minOverlap, mtvAxis = math.huge, nil

    for _, axis in ipairs(axes) do
        local minA, maxA = projectPolygon(p1.vertices, axis)
        local minB, maxB = projectPolygon(p2.vertices, axis)

        local overlap = math.min(maxA, maxB) - math.max(minA, minB)

        if overlap <= 0 then
            return 0, nil
        end

        if overlap < minOverlap then
            minOverlap, mtvAxis = overlap, axis
        end
    end

    local centerDelta = LifeBoatAPI.LBVec:new(0,0)
    for _, v in ipairs(p1.vertices) do centerDelta = centerDelta:lbvec_add(v) end
    centerDelta = centerDelta:lbvec_scale(1 / #p1.vertices)
    local centerB = LifeBoatAPI.LBVec:new(0,0)
    for _, v in ipairs(p2.vertices) do centerB = centerB:lbvec_add(v) end
    centerB = centerB:lbvec_scale(1 / #p2.vertices)
    centerDelta = centerB:lbvec_sub(centerDelta)

    if centerDelta:lbvec_dot(mtvAxis) < 0 then
        mtvAxis = mtvAxis:lbvec_scale(-1)
    end

    return minOverlap, mtvAxis
end
---@endsection