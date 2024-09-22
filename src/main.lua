--  main.lua
--  © Zach Nielsen 2024
--

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "constants"

import "IceObject"
import "Ball"
import "Goal"

local pd <const> = playdate
local gfx <const> = pd.graphics
local c <const> = constants

G_goalScored = c.TEAM_none

local spritesToReset = {}

function GameInit()
    -- Font
    local font = gfx.font.new("font/A.B. Cop (auto-sized).fnt")
    gfx.setFont(font)

    -- Set Background
    local rink = gfx.image.new("images/rink")
    assert(rink)
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
            rink:draw( 0, 0 )
            gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
        end
    )

    -- Set border for collision purposes. Might need to make these wall objects so we can sort collisions
    local wallThickness = 200
    local right = gfx.sprite.new()
    local left  = gfx.sprite.new()
    local top   = gfx.sprite.new()
    local bot   = gfx.sprite.new()
    right:setCollideRect(pd.display.getWidth(), 0, wallThickness, pd.display.getHeight())
    left :setCollideRect(-wallThickness, 0, wallThickness, pd.display.getHeight())
    top  :setCollideRect(0, -wallThickness, pd.display.getWidth(), wallThickness)
    bot  :setCollideRect(0, pd.display.getHeight(), pd.display.getWidth(), wallThickness)
    local walls = {top, bot, left, right}
    for idx=1,#walls do
        local wall = walls[idx]
        wall:setGroups(c.GROUP_walls)
        wall:setCollidesWithGroupsMask(0xFFFFFF)
        wall:add()
    end

    -- Set up Goal
    -- local goalHeight <const> = (pd.display.getHeight())
    -- Goal(pd.display.getWidth() - 1, goalHeight)
    -- Goal(-1,                        goalHeight)

    G_gameStatus = GameStatus()

    InitSprites()
end

function InitSprites()
    -- Set up sprites
    -- TODO: random initial position and angle
    spritesToReset[1] = Ball(100, (pd.display.getHeight()/2))
    spritesToReset[2] = Ball(300, (pd.display.getHeight()/2))

    -- Set up grid
    local rows = 12
    local cols = 20
    for r = 1, rows do
        G_grid[r] = {}
        for c = 1, cols do
            local color = (r <= (rows/2)) and c.TEAM_light or c.TEAM_dark
            G_grid[r][c] = Tile(c*cols, r*rows, color)
        end
    end
end

function ResetSprites()
    for _,sprite in ipairs(spritesToReset) do
        gfx.sprite.removeSprite(sprite)
    end
    gfx.sprite.removeSprite(G_ballObject)
    -- spritesToReset = table.create(4, 0)
    spritesToReset = {}

    InitSprites()
end

function pd.update()
    local status = G_gameStatus:getStatus()
    if status == c.STATUS_countdown then
        G_gameStatus:handleCountdown()
    elseif status == c.STATUS_win then
        print("You Won")
    elseif status == c.STATUS_loss then
        print("You Lost")
    elseif status == c.STATUS_playing then
        -- Update all sprite objects
        gfx.sprite.update()

        if G_goalScored ~= c.TEAM_none then
            G_gameStatus:goalScored(G_goalScored)

            ResetSprites()
            G_goalScored = c.TEAM_none
        end
    else
        print("Error: Bad Status")
    end
    G_gameStatus:drawScoreboard()

    -- Kick the timers
    pd.timer.updateTimers()
end

GameInit()
