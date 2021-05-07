-- Renders player's score on screen
function displayScore()
  love.graphics.setFont(largeFont)
  love.graphics.print(tostring(player1.__score), GAME_WIDTH / 2 - 52, GAME_HEIGHT / 2 - 40)
  love.graphics.print(tostring(player2.__score), GAME_WIDTH / 2 + 34, GAME_HEIGHT / 2 - 40)
end

-- Renders winner
function displayWinner()
  local winner = player1.__score > player2.__score and 1 or 2
  love.graphics.setFont(largeFont)
  love.graphics.printf('The winner is Player ' .. winner .. '!', 0, GAME_HEIGHT / 2 - 10, GAME_WIDTH, 'center')
end

-- Renders FPS across all states on screen
function displayFPS()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), GAME_WIDTH - 50, 10)
end