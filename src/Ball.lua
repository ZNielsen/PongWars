--  Ball.lua
--  © Zach Nielsen 2024
--  Ball Object. Inherits from IceObject
--

local gfx <const> = playdate.graphics
local c <const> = constants


class('Ball').extends(IceObject)

----------------------------------------------------------------------------------------------------
-- NAME:   init
-- NOTES:  Constructor from playdate
-- ARGS:   initial x,y position
-- RETURN: None
--
local ballImage = gfx.image.new("images/ball")
assert(ballImage)
function Ball:init(initX, initY)
    Ball.super.init(self, initX, initY, ballImage)
    self:setGroups(c.GROUP_ball)
    self:setCollidesWithGroupsMask(c.GROUPS_all_but_goalie_box)
    self.maxSpeed = math.huge
    self:setCollideRect(0, 0, self:getSize())
    self:add()
end

----------------------------------------------------------------------------------------------------
-- NAME:   update
-- NOTES:  Override the graphics.sprite update() method
-- ARGS:   None
-- RETURN: None
--
-- Table so we can generalize the collision response for either axis
local directionTable = {}
directionTable.x = {
    normal = nil,
    trigFn = math.cos,
    reflectionFn = Ball.ReflectAboutY
}
directionTable.y = {
    normal = nil,
    trigFn = math.sin,
    reflectionFn = Ball.ReflectAboutX
}
function Ball:update()
    local actualX, actualY, collisions, len = Ball.super.update(self)
    for idx = 1,len,1 do
        -- print("Ball collision[" .. idx .. "]")
        -- Update ball velocity if it hit a wall, otherwise the IceObject will handle it
        local other = collisions[idx]['other']
        if other:isa(Goalie) or (not other:isa(IceObject)) then
            -- If collision is in the same direction as travel, boost speed a bit
            -- If collision is opposite motion, flip movement direction and reduce speed
            -- TODO - use the `touch` point for better rebounding? (i.e. not just orthogonal directions)
            -- TODO - add mass to objects, take momentum into account?
            local normal = collisions[idx]['normal']
            if normal.dx ~= 0 then
                table = directionTable.x
                table.normal = normal.dx
            elseif normal.dy ~= 0 then
                table = directionTable.y
                table.normal = normal.dy
            else
                print("ERROR! Collision with no Normal??")
            end

            if (table.normal > 0 and table.trigFn(self.vVec.theta) > 0) or
               (table.normal < 0 and table.trigFn(self.vVec.theta) < 0) then
                self.vVec.mag += 0.5
            else -- Changing directions
                if collisions[idx]['other']:isa(Goalie) then
                    -- Goalies slap the ball back
                    print("ball hit goalie")
                    self.vVec.mag += other.shotStrength
                else
                    self.vVec.mag -= 0.2
                end
                self.vVec.theta = table.reflectionFn(self.vVec.theta)
            end
        end
    end
end

function Ball.Dislodge()
    -- Place ball in front of sprite
    local ballOffset = 30
    local ballX = G_ballObject.x
    local ballY = G_ballObject.y + (G_ballObject.height/2)
    local ballTheta = G_ballObject.vVec.theta
    local xcomp, ycomp = G_ballObject.GetAngleComponents(ballTheta)
    local clippingProtection = 3 -- Hard coded to ball width/2. TODO - get this pragmatically
    if G_ballObject:IsFacingLeft() then
        ballX += ((-G_ballObject.width/2) + (ballOffset * xcomp) - clippingProtection)
    else
        ballX += ((G_ballObject.width/2) + (ballOffset * xcomp) + clippingProtection)
    end
    ballY += (ballOffset * ycomp)
    local mag = G_ballObject.vVec.mag + G_ballObject.shotStrength
    -- Remove ball from player
    G_ballObject:RemoveBall()

    -- Create new ball
    G_ballObject = Ball(ballX, ballY)
    -- Set velocity vector and give it an extra kick
    G_ballObject.vVec.mag = mag
    G_ballObject.vVec.theta = ballTheta
end
