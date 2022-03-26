Ball = Class {}

--[[
  Ball properties
]]

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.velocityInX = 0
    self.velocityInY = 0
end

--[[
  Ball methods
]]

-- Serves the ball with a new velocity and way
function Ball:serve()
    -- minimun velocity and a random plus
    self.velocityInX = 110 + math.random(30)
    -- checks who's serving, and sets velovity to the other side.
    if playerToServe == 2 then
        self.velocityInX = -self.velocityInX
    end

    self.velocityInY = 80 + math.random(10)
    -- randomizes the Y side.
    if math.random(2) == 1 then
        self.velocityInY = -self.velocityInY
    end
end

-- Checks if colliding with argument (paddle expected)
function Ball:isColliding(paddle)
    -- AABB collision detection
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width or self.y > paddle.y + paddle.height or
        paddle.y > self.y + self.height then
        return false
    else
        return true
    end
end

-- Resets its position
function Ball:resetPosition()
    self.x = GAME_WIDTH / 2 - 2
    self.y = GAME_HEIGHT / 2 - 2
end

-- Sets new position based on its velocity and argument (dt expected)
function Ball:update(dt)
    self.x = self.x + self.velocityInX * dt
    self.y = self.y + self.velocityInY * dt
end

-- Renders on screen
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
