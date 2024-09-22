--  IceObject.lua
--  © Zach Nielsen 2020
--  IceObject Class. Base class for objects moving over ice
--

local pd = nil
local gfx = nil
if playdate ~= nil then
    pd = playdate
    gfx = pd.graphics
else
    -- if playdate is nil, then we are unit testing. Mock out the calls.
    gfx = { sprite = { x = 0, y = 0 } }
    function gfx.sprite:init(...) end
    function gfx.sprite:moveTo(x,y)
        self.x = x
        self.y = y
     end
    function gfx.sprite:setImage(...) end
end

class('IceObject').extends(gfx.sprite)

local DEFAULT_ACCEL = 1
local DEFAULT_FRICTION = 0.1
local DEFAULT_MAX_SPEED = 10

----------------------------------------------------------------------------------------------------
-- NAME:   init
-- NOTES:  Constructor from playdate
-- ARGS:   initial x,y position + sprite image
-- RETURN: None
--
function IceObject:init(initX, initY, image)
    IceObject.super.init(self)
    self:moveTo(initX, initY)
    self:setImage(image)
    self.vVec = {}
    self.vVec.theta = 0
    self.vVec.mag = 0
    self.friction = DEFAULT_FRICTION
    self.accel = DEFAULT_ACCEL
    self.maxSpeed = DEFAULT_MAX_SPEED
    return self
end

----------------------------------------------------------------------------------------------------
-- NAME:   update
-- NOTES:  Override the graphics.sprite update() method
-- ARGS:   None
-- RETURN: None
--
function IceObject:update()
    IceObject.super.update(self)
    if G_gameStatus:getStatus() == constants.STATUS_playing then
        self:UpdatePosition()
        return self:moveWithCollisions(self.x, self.y)
    else
        return 0,0,0,0
    end
end

----------------------------------------------------------------------------------------------------
-- NAME:    applyAcceleration
-- NOTES:   Apply object's full acceleration in a direction
-- ARGS:    thetaR - The target angle in radians
-- RETURN:  None, modifies internal vVec
--
function IceObject:ApplyAcceleration(thetaR)
    self:AccelerateTowards(thetaR, self.accel)
end

----------------------------------------------------------------------------------------------------
-- NAME:    accelerateTowards
-- NOTES:   Accelerate in a given direction at given strength
-- ARGS:
--      thetaR - The target angle in radians
--      mag - How hard to accelerate
-- RETURN:  None, modifies internal vVec
--
function IceObject:AccelerateTowards(thetaR, mag)
    -- Break current speed down to components
    local selfXComp, selfYComp = self:GetVelocityComponents()
    -- Break input down to components
    -- On Playdate, Y increases when moving down, so flip the y comp
    local dirXComp = mag * math.cos(thetaR)
    local dirYComp = mag * -math.sin(thetaR)
    -- Get new components
    local newXComp = selfXComp + dirXComp
    local newYComp = selfYComp + dirYComp
    -- Build up new vector
    self.vVec.mag = math.min(self.maxSpeed, math.sqrt((newXComp^2)+(newYComp^2)))
    self.vVec.theta = math.atan(newYComp, newXComp)
end

----------------------------------------------------------------------------------------------------
-- NAME:    reflectAbout[X/Y]
-- NOTES:   Reflects the velocity vector over the specified axis
-- ARGS:    thetaR - The target angle in radians
-- RETURN:  The resultant vector's angle in radians
--
function IceObject.ReflectAboutX(thetaR)
    local XComp = math.cos(thetaR)
    local YComp = math.sin(thetaR)
    return math.atan(-YComp, XComp)
end
function IceObject.ReflectAboutY(thetaR)
    local XComp = math.cos(thetaR)
    local YComp = math.sin(thetaR)
    return math.atan(YComp, -XComp)
end

----------------------------------------------------------------------------------------------------
-- NAME:   applyFriction
-- NOTES:  Slows the object down by its friction coefficient
-- ARGS:   None
-- RETURN: None, modifies self velocity magnitude
--
function IceObject:ApplyFriction()
    if self.vVec.mag > 0 then
        self.vVec.mag = math.max(self.vVec.mag - self.friction, 0)
    end
end

----------------------------------------------------------------------------------------------------
-- NAME:   UpdatePosition
-- NOTES:
--      Applies the current velocity vector to the position for this tick
--      The velocity needs to be updated before this is run (except friction)
-- ARGS:   None
-- RETURN: None, modifies self x and y position
--
function IceObject:UpdatePosition()
    self:ApplyFriction()
    -- Break current speed down to components
    local selfXComp, selfYComp = self:GetVelocityComponents()
    self.x = self.x + selfXComp
    self.y = self.y + selfYComp
end

----------------------------------------------------------------------------------------------------
-- NAME:   GetVelocityComponents
-- NOTES:  Calculates the X and Y components of this object's velocity
-- ARGS:   None
-- RETURN: X and Y velocity components
--
function IceObject:GetVelocityComponents()
    local selfXComp = self.vVec.mag * math.cos(self.vVec.theta)
    local selfYComp = self.vVec.mag * math.sin(self.vVec.theta)
    return selfXComp, selfYComp
end

----------------------------------------------------------------------------------------------------
-- NAME:   GetAngleComponents
-- NOTES:  Calculates the X and Y components of a given angle
-- ARGS:   An angle in radians
-- RETURN: X and Y components of the angle (unit, not scaled)
--
function IceObject.GetAngleComponents(theta)
    local xcomp = math.cos(theta)
    local ycomp = math.sin(theta)
    return xcomp, ycomp
end

function IceObject:ReinInSelfTheta()
    -- Need to normalize to [0, 2π)
    while self.vVec.theta < 0 do
        self.vVec.theta += 2*math.pi
    end
    while self.vVec.theta >= 2*math.pi do
        self.vVec.theta -= 2*math.pi
    end
end
function IceObject.ReinInTheta(theta)
    -- Need to normalize to [0, 2π)
    while theta < 0 do
        theta += 2*math.pi
    end
    while theta >= 2*math.pi do
        theta -= 2*math.pi
    end
    return theta
end

return IceObject
