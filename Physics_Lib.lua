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

    local object1Shapes, object2Shapes = object1:GetWorldVertices(), object2:GetWorldVertices()

    for _, shapeData1 in ipairs(object1Shapes) do
        for _, shapeData2 in ipairs(object2Shapes) do
            local depth, normal
            if shapeData1.type == ShapeTypes.Polygon and shapeData2.type == ShapeTypes.Polygon then
                depth, normal = PolygonPolygon(shapeData1, shapeData2)
            elseif shapeData1.type == ShapeTypes.Polygon and shapeData2.type == ShapeTypes.Circle then
                depth, normal = PolygonCircle(shapeData1, shapeData2)
            elseif shapeData1.type == ShapeTypes.Circle and shapeData2.type == ShapeTypes.Polygon then
                depth, normal = PolygonCircle(shapeData2, shapeData1)
                if normal then normal = normal:lbvec_scale(-1) end
            elseif shapeData1.type == ShapeTypes.Circle and shapeData2.type == ShapeTypes.Circle then
                depth, normal = CircleCircle(shapeData1, shapeData2)
            end

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

---@section CircleCircle
---@param c1 table
---@param c2 table
---@return number, LBVec
CircleCircle = function(c1, c2)
    local delta = c2.center:lbvec_sub(c1.center)
    local distSq, r = delta:lbvec_magnitudeSq(),c1.radius + c2.radius

    if distSq >= r*r then
        return 0, nil -- no collision
    end

    local dist = math.sqrt(distSq)
    local penetration = r - dist
    local normal = (dist > 0) and delta:lbvec_normalize() or LifeBoatAPI.LBVec:new(1,0)

    return penetration, normal
end
---@endsection

---@section PolygonPolygon
---@param p1 table
---@param p2 table
---@return number, LBVec
PolygonPolygon = function(p1, p2)
    local axes = {}

    local function addPerpEdges(poly)
        for i = 1, #poly.vertices do
            local nextIdx = (i % #poly.vertices) + 1
            local edge = poly.vertices[nextIdx]:lbvec_sub(poly.vertices[i])
            local axis = LifeBoatAPI.LBVec:new(-edge.y, edge.x):lbvec_normalize()
            table.insert(axes, axis)
        end
    end

    addPerpEdges(p1)
    addPerpEdges(p2)

    local minOverlap = math.huge
    local mtvAxis = nil

    local function projectPolygon(vertices, axis)
        local min, max = math.huge, -math.huge
        for _, v in ipairs(vertices) do
            local p = v:lbvec_dot(axis)
            if p < min then min = p end
            if p > max then max = p end
        end
        return min, max
    end

    for _, axis in ipairs(axes) do
        local minA, maxA = projectPolygon(p1.vertices, axis)
        local minB, maxB = projectPolygon(p2.vertices, axis)

        local overlap = math.min(maxA, maxB) - math.max(minA, minB)

        if overlap <= 0 then
            return 0, nil
        end

        if overlap < minOverlap then
            minOverlap = overlap
            mtvAxis = axis
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

---@section PolygonCircle
---@param polygon table
---@param circle table
---@return number, LBVec
PolygonCircle = function(polygon, circle)
    local axes = {}

    -- Step 1: Polygon edge normals
    for i = 1, #polygon.vertices do
        local nextIdx = (i % #polygon.vertices) + 1
        local edge = polygon.vertices[nextIdx]:lbvec_sub(polygon.vertices[i])
        local axis = LifeBoatAPI.LBVec:new(-edge.y, edge.x):lbvec_normalize()
        table.insert(axes, axis)
    end

    -- Step 2: Axis from closest polygon vertex to circle center
    local closestVertex = polygon.vertices[1]
    local minDist = circle.position:lbvec_sub(closestVertex):lbvec_length()
    for i = 2, #polygon.vertices do
        local dist = circle.position:lbvec_sub(polygon.vertices[i]):lbvec_length()
        if dist < minDist then
            minDist = dist
            closestVertex = polygon.vertices[i]
        end
    end
    local axisToCircle = circle.position:lbvec_sub(closestVertex)
    if axisToCircle:lbvec_length() > 0 then
        table.insert(axes, axisToCircle:lbvec_normalize())
    end

    -- Step 3: Projection helper
    local function projectPolygon(vertices, axis)
        local min, max = math.huge, -math.huge
        for _, v in ipairs(vertices) do
            local p = v:lbvec_dot(axis)
            if p < min then min = p end
            if p > max then max = p end
        end
        return min, max
    end

    local function projectCircle(center, radius, axis)
        local p = center:lbvec_dot(axis)
        return p - radius, p + radius
    end

    -- Step 4: Check overlaps
    local minOverlap = math.huge
    local mtvAxis = nil
    for _, axis in ipairs(axes) do
        local minP, maxP = projectPolygon(polygon.vertices, axis)
        local minC, maxC = projectCircle(circle.position, circle.radius, axis)

        local overlap = math.min(maxP, maxC) - math.max(minP, minC)
        if overlap <= 0 then
            -- Separating axis found → no collision
            return 0, nil
        end

        if overlap < minOverlap then
            minOverlap = overlap
            mtvAxis = axis
        end
    end

    -- Step 5: Orient axis from polygon → circle
    local centerDelta = circle.position:lbvec_sub(polygon.vertices[1])
    if centerDelta:lbvec_dot(mtvAxis) < 0 then
        mtvAxis = mtvAxis:lbvec_scale(-1)
    end

    return minOverlap, mtvAxis
end
---@endsection


