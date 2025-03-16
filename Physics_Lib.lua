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