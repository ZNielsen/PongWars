--  Goal.lua
--  © Zach Nielsen 2020
--  Goal object
--

local gfx <const> = playdate.graphics
local c <const> = constants


class('Goal').extends(gfx.sprite)

----------------------------------------------------------------------------------------------------
-- NAME:   init
-- NOTES:  Constructor from playdate
-- ARGS:   initial x,y position
-- RETURN: None
--
function Goal:init(initX, height)
    Goal.super.init(self)
    self:moveTo(initX, (playdate.display.getHeight() - height)/2)
    self:setVisible(false)
    self:setGroups({c.GROUP_goals})
    self:setCollidesWithGroups(c.GROUP_puck)
    self:setCollideRect(0, 0, 2, height)
    self:add()
end

----------------------------------------------------------------------------------------------------
-- NAME:   update
-- NOTES:  Override the graphics.sprite update() method
-- ARGS:   None
-- RETURN: None
--
function Goal:update()
    Goal.super.update(self)
    local collidingSprites = self:overlappingSprites()
    for idx=1,#collidingSprites do
        -- print("Goal collidingSprites[" ..idx.. "]")
        if collidingSprites[idx]:isa(Ball) then
            print("GOOOAAALLL!!!")
            if self.x < 100 then
                G_goalScored = c.TEAM_dark
            else
                G_goalScored = c.TEAM_light
            end
        end
    end
    return actualY, actualY, collisions, len
end
