--[[
    Mogi das Cruzes 2019
    Pong Remake

    --Main Program--

    Author: Vinicius Prado Almeida

    Remake of Pong originally for Atari 1972

    The game will be played by two players, each one controls a paddle and can use them to interect with the ball. If the ball goes beyond one player's paddle, the other one scores. When one of them scores 10 points they win and the game restarts
]]

-- push allows us to create a virtual resolution for our game --
push = require 'push'

-- class allows us to work object oriented
Class = require 'class'

-- our classes
require 'Ball'
require 'Paddle'

VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

WINDOW_WIDTH = 1152
WINDOW_HEIGHT = 648

PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20
PADDLE_SPEED = 200 -- * dt

BALL_WIDTH = 4
BALL_HEIGHT = 4

function love.load()

    math.randomseed(os.time())

    titleFont = love.graphics.newFont('font.ttf', 40)
    mediumFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 30)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')
    } 

    love.window.setTitle("Pong Remake")

    love.graphics.setDefaultFilter('nearest' , 'nearest')

    push:setupScreen(VIRTUAL_WIDTH , VIRTUAL_HEIGHT , WINDOW_WIDTH , WINDOW_HEIGHT , {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1 = Paddle(10 , VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2 , PADDLE_WIDTH , PADDLE_HEIGHT)
    player2 = Paddle(VIRTUAL_WIDTH - 10 - PADDLE_WIDTH , VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2 , PADDLE_WIDTH , PADDLE_HEIGHT)

    ball = Ball(VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - BALL_HEIGHT / 2 , BALL_WIDTH , BALL_HEIGHT)

    -- Loads on start gamestate
    gameState = 'start'

    p1Score = 0
    p2Score = 0
    servingPlayer = 1
    choice = 1
end

function love.update(dt)
    if gameState == 'serve' then
        ball:reset()
        ball.dy = math.random(-50,50) * 1.5
        if servingPlayer == 1 then
                ball.dx = math.random(150 , 200)
        else
                ball.dx = -math.random(150 , 200)
        end
    elseif gameState == 'play' then
    
                ball:update(dt)

                if ball:collides(player1) then
                    ball.dx = -ball.dx * 1.03
                    ball.x = player1.x + PADDLE_WIDTH

                    if ball.dy < 0 then
                        ball.dy = -math.random(50 , 150)
                    else
                        ball.dy = math. random(50 , 150)
                    end

                    sounds['paddle_hit']:play()
                end

                if ball:collides(player2) then
                    ball.dx = -ball.dx * 1.03
                    ball.x = player2.x - BALL_WIDTH

                   
                    if ball.dy < 0 then
                        ball.dy = -math.random(50 , 150)
                    else
                        ball.dy = math. random(50 , 150)
                    end

                    sounds['paddle_hit']:play()
                end

                if ball.y <= 0 or ball.y + ball.height >= VIRTUAL_HEIGHT then
                    ball.dy = -ball.dy
                    sounds['wall_hit']:play()
                end

                -- reset the ball and score -- 
                if ball.x >= VIRTUAL_WIDTH then
                    p1Score = p1Score + 1
                    if p1Score == 10 then
                        sounds['victory']:play()
                        winningPlayer = 1
                        gameState = 'gameOver'
                    else
                        sounds['score']:play()
                        gameState = 'serve'
                        servingPlayer = 1
                    end                  
                elseif ball.x + BALL_WIDTH <= 0 then
                    p2Score = p2Score + 1
                    if p2Score == 10 then
                        sounds['victory']:play()
                        winningPlayer = 2
                        gameState = 'gameOver'
                    else
                        sounds['score']:play()
                        gameState = 'serve'
                        servingPlayer = 2
                    end   
                end
    end
    -- Player 1 controls
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    if choice == 1 then -- PVP
        -- Player 2 controls
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    elseif choice == 2 then -- PvAI
        player2.y = ball.y - player2.height / 2
    end
    player1:update(dt)
    player2:update(dt)

end

function love.keypressed(key)
    -- Esc = exit
    if key == 'escape' then
        love.event.quit()
    -- change states -- 
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'gameOver' then
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            p1Score = 0
            p2Score = 0

            servingPlayer = winningPlayer

        end
    end
    
    if gameState == 'start' then 
        if key == 'left' then 
            choice = 1
            sounds['paddle_hit']:play()
        elseif key == 'right' then
            choice = 2
            sounds['paddle_hit']:play()
        end
    end
end

function love.draw()
    push:start()

    if gameState == 'start' then
        love.graphics.setFont(titleFont)
        love.graphics.printf("Pong",  0 , 20 , VIRTUAL_WIDTH , 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf("Press [Enter] to play", 0 , 60 , VIRTUAL_WIDTH , 'center')

        love.graphics.printf("Choose mode", 0 , VIRTUAL_HEIGHT - 40 , VIRTUAL_WIDTH , 'center')
        if choice == 1 then love.graphics.setColor(0 , 1 , 1 , 1) end
        love.graphics.print("P vs P", VIRTUAL_WIDTH / 2 - 50 , VIRTUAL_HEIGHT - 20)
        love.graphics.setColor(1 , 1 , 1 , 1)
        if choice == 2 then love.graphics.setColor(0 , 1 , 1 , 1) end
        love.graphics.print("P vs AI", VIRTUAL_WIDTH / 2 + 20 , VIRTUAL_HEIGHT - 20)
        love.graphics.setColor(1 , 1 , 1 , 1)

    elseif gameState == 'serve' then
        love.graphics.setFont(mediumFont)

        if servingPlayer == 1 then
            love.graphics.setColor(0, 0, 255, 255)
        else 
            love.graphics.setColor(255, 0, 0, 255)   
        end

        love.graphics.printf("Player " .. tostring(servingPlayer) .. ", press [Enter] to serve", 0 , 40 , VIRTUAL_WIDTH , 'center') 
        love.graphics.setColor(255, 255, 255, 255)

        displayScore()
    elseif gameState == 'play'then
        displayScore() 
    elseif gameState == 'gameOver' then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Player " .. tostring(winningPlayer).. " Won!", 0 , 60 , VIRTUAL_WIDTH, 'center' )
        love.graphics.setFont(mediumFont)
        love.graphics.printf("Press [Enter] to play again or [Esc] to exit", 0 , 90 , VIRTUAL_WIDTH , 'center') 
    end



    ball:render()

    love.graphics.setColor(0, 0, 255, 255)
    player1:render()
    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setColor(255, 0, 0, 255)
    player2:render()
    love.graphics.setColor(255 , 255, 255, 255)

    displayFPS()

    push:finish()
end

function displayScore()
    love.graphics.setFont(largeFont)

    --player 1's score - blue
    love.graphics.setColor(0, 0, 255, 255)
    love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 50,
    VIRTUAL_HEIGHT / 3)
    -- player 2's score - red
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 30,
    VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(255 , 255, 255, 255)
end

function displayFPS()
    love.graphics.setFont(mediumFont)
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.print(tostring('FPS : ' .. love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end

function love.resize(w,h)
    push:resize(w,h)
end