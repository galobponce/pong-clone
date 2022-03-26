Paddle = Class {}

--[[
  Paddle properties
]]

function Paddle:init(x, y, width, height, speed)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Actual velocity (down / up with its speed)
    self.velocity = 0
    -- Speed of velocity
    self.speed = speed

    self.__score = 0
end

--[[
  Paddle methods
]]

-- Sets a new position based on its position
function Paddle:update(dt)
    -- Checks if paddle tries to go off the screen

    -- If paddle going up 
    if self.velocity < 0 then
        -- New position equals to the max between top of screen and new position.
        self.y = math.max(0, self.y + self.velocity * dt)

        -- If paddle going down
    else
        -- The same with bottom of the screen
        self.y = math.min(GAME_HEIGHT - self.height, self.y + self.velocity * dt)
    end
end

function Paddle:resetPosition(x, y)
    self.x = x
    self.y = y
end

function Paddle:resetScore()
    self.__score = 0
end

-- Renders on screen
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
