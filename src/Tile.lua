--  Tile.lua
--  © Zach Nielsen 2024
--  Tile Object. Inherits from IceObject
--

local gfx <const> = playdate.graphics
local c <const> = constants


class('Tile').extends(IceObject)

----------------------------------------------------------------------------------------------------
-- NAME:   init
-- NOTES:  Constructor from playdate
-- ARGS:   initial x,y position
-- RETURN: None
--
local tileImage = gfx.image.new("images/tile")
assert(tileImage)
function Tile:init(initX, initY, color)
    Tile.super.init(self, initX, initY)
    local group = c.GROUP_dark
    local color = gfx.kColorBlack
    local collides = c.GROUP_light_ball
    if color == c.TEAM_light then
        group = c.GROUP_light
        color = gfx.kColorWhite
        collides = c.GROUP_dark_ball
    end
    self:setGroups(group)
    self:setCollidesWithGroupsMask(collides)
    self.maxSpeed = 0
    self:setCollideRect(0, 0, self:getSize())
    self:add()

    -- Set the color and draw
    gfx.setColor(color)
    gfx.fillRect(initX, intiY, self:getSize())
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
    reflectionFn = Tile.ReflectAboutY
}
directionTable.y = {
    normal = nil,
    trigFn = math.sin,
    reflectionFn = Tile.ReflectAboutX
}
function Tile:update()
    local actualX, actualY, collisions, len = Tile.super.update(self)
    for idx = 1,len,1 do
        -- print("Tile collision[" .. idx .. "]")
        -- Update tile velocity if it hit a wall, otherwise the IceObject will handle it
        local other = collisions[idx]['other']
        if other:isa(Ball) then
            -- Flip this tile color
            -- TODO - use the `touch` point for better rebounding? (i.e. not just orthogonal directions)
            self:Flip()
        end
    end
end

function Tile:Flip()
    local this_group = self:getGroupMask()

    local group = c.GROUP_dark
    local color = gfx.kColorBlack
    local collides = c.GROUP_light_ball
    if this_group = c.GROUP_dark then
        group = c.GROUP_light
        color = gfx.kColorWhite
        collides = c.GROUP_dark_ball
    end
    self:setGroups(group)
    self:setCollidesWithGroupsMask(collides)
    -- Set the color and draw
    gfx.setColor(color)
    gfx.fillRect(initX, intiY, self:getSize())
end

