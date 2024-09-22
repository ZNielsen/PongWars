--  constants.lua
--  © Zach Nielsen 2022
--

constants = {}

--
-- Enums
--

-- Radial Directions
constants.DIR_down_right = (7*math.pi)/4
constants.DIR_down       = (6*math.pi)/4
constants.DIR_down_left  = (5*math.pi)/4
constants.DIR_left       = (4*math.pi)/4
constants.DIR_up_left    = (3*math.pi)/4
constants.DIR_up         = (2*math.pi)/4
constants.DIR_up_right   = (1*math.pi)/4
constants.DIR_right      = (0*math.pi)/4
constants.DIR_none       = 10

-- Input Directions
constants.INPUT_none  = 0
constants.INPUT_up    = 1
constants.INPUT_right = 2
constants.INPUT_down  = 4
constants.INPUT_left  = 8

-- Sprite Groups
constants.GROUP_walls      = 1
constants.GROUP_light_ball = 2
constants.GROUP_dark_ball  = 3
constants.GROUP_light_tile = 4
constants.GROUP_dark_tile  = 5
constants.GROUP_goals      = 6

constants.GROUPS_all        = 0xFFFFFFFF

-- Image bit mask
constants.IMG_MASK_dir_bit  = 0
constants.IMG_MASK_puck_bit = 1
constants.IMG_MASK_clear_dir_bit = 2
constants.IMG_MASK_clear_puck_bit = 1

constants.IMG_left       = 0
constants.IMG_left_puck  = (1 << constants.IMG_MASK_puck_bit)
constants.IMG_right      = (1 << constants.IMG_MASK_dir_bit)
constants.IMG_right_puck = (1 << constants.IMG_MASK_dir_bit) | (1 << constants.IMG_MASK_puck_bit)

-- Tags for sprite groups
constants.TAG_goalie_box = 1

-- Team Enums
constants.TEAM_none   = 0
constants.TEAM_dark   = 1
constants.TEAM_light  = 2

-- Game state
constants.STATUS_playing   = 0
constants.STATUS_win       = 1
constants.STATUS_loss      = 2
constants.STATUS_countdown = 3

return constants
