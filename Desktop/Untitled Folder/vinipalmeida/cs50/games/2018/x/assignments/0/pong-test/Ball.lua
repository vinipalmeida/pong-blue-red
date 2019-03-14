--[[
    Mogi das Cruzes 2019
    Pong Remake

    --Ball Class--

    Author: Vinicius Prado Almeida

    Ball for playing games and scoring points, if it collides with a paddle it's x movement gets inverted
]]

Ball = Class{}

function Ball:init(x ,y ,width ,height)
    self.x = x
    self.y = y 
    self.width = width
    self.height = height
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x , self.y, self.width, self.height)
end

function Ball:collides(paddle)
    -- check right and left
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then 
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then 
        return false
    end

    -- if those two aren't true they are colliding
    return true
end

function Ball:reset() 
    self.x = VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT / 2 - BALL_HEIGHT / 2
end