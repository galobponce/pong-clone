-- https://github.com/Ulydev/push
-- Retro aesthetic
local push = require 'src/push'

-- https://github.com/vrld/hump/blob/master/class.lua
-- OOP in a easier way
Class = require 'src/class'

require 'src/helpers'
require 'src/classes/Ball'
require 'src/classes/Paddle'

GAME_WIDTH, GAME_HEIGHT = 432, 243

local WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
local WINDOW_WIDTH, WINDOW_HEIGHT = WINDOW_WIDTH *.8, WINDOW_HEIGHT *.8

-- Ran only once to initialize the game
function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- Retro-looking font
  smallFont = love.graphics.newFont('src/fonts/retro-font.ttf', 8)
  largeFont = love.graphics.newFont('src/fonts/retro-font.ttf', 32)

  -- Random numbers.
  math.randomseed(os.time())

  sounds = {
    ['background'] = love.audio.newSource('src/sounds/background-music.wav', 'stream'),
    ['serve'] = love.audio.newSource('src/sounds/serve.wav', 'static'),
    ['paddle-hit'] = love.audio.newSource('src/sounds/paddle_hit.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('src/sounds/wall_hit.wav', 'static'),
    ['score'] = love.audio.newSource('src/sounds/score.wav', 'static')
  }
  -- Background music
  sounds['background']:setLooping(true)
  sounds['background']:setVolume(0.8)
  sounds['background']:play()

  --[[
    Object's intance
  ]]

  player1 = Paddle(10, 30, 5, 20, 200)
  player2 = Paddle(GAME_WIDTH - 10, GAME_HEIGHT - 50, 5, 20, 200)
  ball = Ball(GAME_WIDTH / 2 - 2, GAME_HEIGHT / 2 - 2, 4, 4)

  --[[
    Sets game's state; can be any of the following:
    1. 'menu' : (beggining of the game, before serve)
    2. 'serve' : (waiting to play key pressed to serve the ball)
    3. 'play' : (the is in play)
    4. 'win' : (the game is over, with a winner, ready for restart)
  ]]
  gameState = 'menu'

  -- Defines if player is playing against the machine
  againtsMachine = false

  -- Configure push lib
  push:setupScreen(GAME_WIDTH, GAME_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    rezisable = false,
    vsync = true
  })
end


-- Keyboard handling.
function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()

  -- Toggle between states
  elseif key == 'enter' or key == 'return' then
    if gameState == 'menu' then
      -- Player to serve is random
      playerToServe = math.random(2) == 1 and 1 or 2
      player1:resetScore()
      player2:resetScore()
      gameState = 'serve'
    elseif gameState == 'serve' then
      -- Serves the ball and plays sound
      ball:serve()
      sounds['serve']:play()
      gameState = 'play'
    elseif gameState == 'win' then
      -- Same as menu to serve
      playerToServe = math.random(2) == 1 and 1 or 2
      player1:resetScore()
      player2:resetScore()
      gameState = 'serve'
    end
  elseif key == 'lshift' or key == 'rshift' then
		if gameState == 'menu' then
		-- Player to serve is user
		againtsMachine = true
		playerToServe = 1
		player1:resetScore()
		player2:resetScore()
		gameState = 'serve'
		end
  end
end


-- Runs every frame with 'dt' (1/6 of second) passed in
function love.update(dt)
  if gameState == 'play' then
    -- Player 1 movement
    if love.keyboard.isDown('w') then
      player1.velocity = -player1.speed
    elseif love.keyboard.isDown('s') then
      player1.velocity = player1.speed
    else
      player1.velocity = 0
    end

    -- Player 2 movement
    if love.keyboard.isDown('up') and not againtsMachine then
      player2.velocity = -player2.speed
    elseif love.keyboard.isDown('down') and not againtsMachine then
      player2.velocity = player2.speed
    else
      player2.velocity = 0
    end

		-- Machine movement
		if againtsMachine then
			player2.y = ball.y
		end

    --[[
      Collision with top & bottom screen
    ]]
    -- Top of the screen
    if ball.y <= 0 then
      ball.y = 0
      ball.velocityInY = -ball.velocityInY
      sounds['wall-hit']:play()
    end

    -- Bottom of the screen
    if ball.y >= GAME_HEIGHT - 4 then
      ball.y = GAME_HEIGHT - 4
      ball.velocityInY = -ball.velocityInY
      sounds['wall-hit']:play()
    end

    --[[
      Collision with left & right screen
    ]]
    -- Left side
    if ball.x < 0 then
      sounds['score']:play()
      player1:resetPosition(10, 30)
      player2:resetPosition(GAME_WIDTH - 10, GAME_HEIGHT - 50)
      player2.__score = player2.__score + 1

      -- Checks winner condition
      if player2.__score == 5 then
        gameState = 'win'
        ball:resetPosition()
      else
        playerToServe = 1
        gameState = 'serve'
        ball:resetPosition()
      end
    end

    -- Right side
    if ball.x > GAME_WIDTH then
      sounds['score']:play()
      player1:resetPosition(10, 30)
      player2:resetPosition(GAME_WIDTH - 10, GAME_HEIGHT - 50)
      player1.__score = player1.__score + 1

      -- Checks winner condition
      if player1.__score == 5 then
        gameState = 'win'
        ball:resetPosition()
      else
        playerToServe = 2
        gameState = 'serve'
        ball:resetPosition()
      end
    end

    --[[
      Collision with paddles
    ]]
    -- Player 1
    if ball:isColliding(player1) then
      -- Places the ball to not overlap the paddle
      ball.x = player1.x + player1.width + 3
      -- Bounces the ball to the other side with more speed (max speed)
      if (not (ball.velocityInX < -280)) then
        ball.velocityInX = -ball.velocityInX * 1.12
      else
        ball.velocityInX = -ball.velocityInX
      end
      sounds['paddle-hit']:play()
    end

    -- Player 2
    if ball:isColliding(player2) then
      ball.x = player2.x - player2.width - 3
      if (not (ball.velocityInX > 280)) then
        ball.velocityInX = -ball.velocityInX * 1.12
      else
        ball.velocityInX = -ball.velocityInX
      end
      sounds['paddle-hit']:play()
    end

    -- Update paddle's position
    player1:update(dt)
    player2:update(dt)

    -- Update ball's Movement
    ball:update(dt)
  end
end


-- Renders anything on screen, called after update.
function love.draw(input)
  push:start()
  -- Background color
  love.graphics.clear(30/255, 35/255, 45/255, 255/255)

  if gameState == 'menu' then
    -- UI messages
    love.graphics.setFont(smallFont)
    love.graphics.printf('Player 1: W-S', 10, 10, GAME_WIDTH, 'left')
    love.graphics.printf('Player 2: UP-DOWN', 10, 30, GAME_WIDTH, 'left')
    love.graphics.printf('Press Enter to play', 10, 50, GAME_WIDTH, 'left')
    love.graphics.printf('Press Shift to play against machine', 10, 70, GAME_WIDTH, 'left')
    love.graphics.printf('Press Esc to quit', 10, 90, GAME_WIDTH, 'left')
    love.graphics.setFont(largeFont)
    love.graphics.printf('Pong!', 0, GAME_HEIGHT / 2 - 25, GAME_WIDTH, 'center')

  elseif gameState == 'serve' then
    -- UI messages
    love.graphics.setFont(smallFont)
    love.graphics.printf('Player ' .. tostring(playerToServe) .. "'s to serve!", 0, 10, GAME_WIDTH, 'center')
    love.graphics.printf('Press Enter to serve', 0, 30, GAME_WIDTH, 'center')
    displayScore()
    -- Objs
    player1:render()
    player2:render()
    ball:render()

  elseif gameState == 'play' then
      player1:render()
      player2:render()
      ball:render()
      displayScore()

  elseif gameState == 'win' then
      -- UI messages
      love.graphics.setFont(smallFont)
      love.graphics.printf('Press Enter to restart', 10, 10, GAME_WIDTH, 'left')
      love.graphics.printf('Press Esc to quit', 10, 30, GAME_WIDTH, 'left')
      displayScore()
      displayWinner()
  end

  -- Display FPS in all states
  displayFPS()

  push:finish()
end