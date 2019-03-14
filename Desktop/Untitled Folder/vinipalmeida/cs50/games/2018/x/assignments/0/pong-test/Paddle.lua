--[[
    Mogi das Cruzes 2019
    Pong Remake

    --Paddle Class--

    Author: Vinicius Prado Almeida

    Paddles players use to play the game, they only move vertically
]]

Paddle = Class{}

function Paddle:init(x ,y ,width ,height)
    self.x = x
    self.y = y 
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)

    if self.dy < 0 or self.y < 0 then
        self.y = math.max( 0 , self.y + self.dy * dt)
    else
        self.y = math.min( VIRTUAL_HEIGHT - self.height , self.y + self.dy * dt)
    end    

end

function Paddle:render()
    love.graphics.rectangle('fill', self.x , self.y, self.width, self.height)
end
