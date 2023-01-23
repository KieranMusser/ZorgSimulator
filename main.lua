--[[
  Controls:
   - right/left arrows +1 / -1 hour
   - ./, +0.1/-0.1 hours
   - z flip zorg spin direction
   - m flip moon orbit direction
   - 0 reset time
   - space pause / play
]]--

-- Purely for looks
local ZORG_RADIUS = 50
local MOON_RADIUS = 100
local HORIZON_LENGTH = 500

local ZORG_X = 0
local ZORG_Y = -100
local HORIZON_SIZE = 0.4


-- Changes functionality
local MOON_ORBIT = 6 -- hours
local ZORG_DAY = 72 -- hours

-- Speed of play ( when played with space )
local PLAY_DELAY = 0.1
local PLAY_INC = 0.1

local DEBUG = false

function love.draw()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  local cx = width / 2 + ZORG_X
  local cy = height / 2 + ZORG_Y
  
  local zorg_ang = (zorg_spin_m * (time / ZORG_DAY * math.pi * 2) - math.pi/2) % (2*math.pi)
  local moon_ang = (moon_spin_m * (time / MOON_ORBIT * math.pi * 2) - math.pi/2) % (2*math.pi)
  
  
  love.graphics.print(
    "Time (h) "..time,
    cx-font:getWidth("Time (h) "..time)/2,20
  )
  
  love.graphics.circle(
    "line", 
    cx,cy,ZORG_RADIUS
  )

  love.graphics.circle(
    "fill",
    cx+math.cos(zorg_ang)*ZORG_RADIUS,
    cy+math.sin(zorg_ang)*ZORG_RADIUS,
    5
  )
  love.graphics.circle(
    "fill",
    cx+math.cos(moon_ang)*MOON_RADIUS,
    cy+math.sin(moon_ang)*MOON_RADIUS,
    5
  )
  
  -- Compass Text
  love.graphics.print("E",cx-ZORG_RADIUS,cy,0,1,1,0,8)
  love.graphics.print("W",cx+ZORG_RADIUS,cy,0,1,1,12,8)
  love.graphics.print("S",cx,cy,0,1,1,6,8)
  
  -- Horizon Line
  local horizon_slope = 1/-math.tan(zorg_ang)
  if math.abs(horizon_slope) == 1/0 then
    horizon_slope = 1000
  end
  local x = math.sqrt(HORIZON_LENGTH^2 / (1+horizon_slope^2))
  local y = horizon_slope * x
  
  love.graphics.line(
    cx+math.cos(zorg_ang)*ZORG_RADIUS - x,
    cy+math.sin(zorg_ang)*ZORG_RADIUS - y,
    cx+math.cos(zorg_ang)*ZORG_RADIUS + x,
    cy+math.sin(zorg_ang)*ZORG_RADIUS + y
  )
  
  -- Spin / orbit indicators
  love.graphics.line(
    cx-9,cy-ZORG_RADIUS+15,
    cx+9,cy-ZORG_RADIUS+15
  )
  love.graphics.line(
    cx+zorg_spin_m*6,cy-ZORG_RADIUS+12,
    cx+zorg_spin_m*10,cy-ZORG_RADIUS+15,
    cx+zorg_spin_m*6,cy-ZORG_RADIUS+18
  )
  
  love.graphics.line(
    cx-9,cy-MOON_RADIUS-15,
    cx+9,cy-MOON_RADIUS-15
  )
  love.graphics.line(
    cx+moon_spin_m*6,cy-MOON_RADIUS-12,
    cx+moon_spin_m*10,cy-MOON_RADIUS-15,
    cx+moon_spin_m*6,cy-MOON_RADIUS-18
  )
  
  -- Ground view
  local r,g,b,a = love.graphics.getColor()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", 0, height*(1-HORIZON_SIZE)-20,width,height)
  love.graphics.setColor(255,255,255)
  love.graphics.line(
	0,height*(1-HORIZON_SIZE)-20,
    width,height*(1-HORIZON_SIZE)-20
  )
  love.graphics.setColor(r,g,b,a)
  text = "Horizon View"
  love.graphics.print(text,width/2-font:getWidth(text)/2,height*(1-HORIZON_SIZE))
 
  -- Angle of moon from horizon
  local ang = math.atan2(
    -math.sin(zorg_ang)*ZORG_RADIUS+math.sin(moon_ang)*MOON_RADIUS,
    -math.cos(zorg_ang)*ZORG_RADIUS+math.cos(moon_ang)*MOON_RADIUS
  ) 
  -- Scale angle so that [0,1] is the size of horizon
  local scaledang = (ang-(zorg_ang-math.pi/2))/math.pi
  local sx = 1-math.cos(scaledang * math.pi)
  local sy = -math.sin(scaledang * math.pi)


  -- Draw moon on horizon view
  love.graphics.circle(
      "fill",
      width/2 * sx + 0*width/2,--(width-0)*scaledang+0,
      height*(1-HORIZON_SIZE)+height*HORIZON_SIZE*sy-10+height*HORIZON_SIZE,
      10
  )
  if DEBUG then
    love.graphics.line(
      cx+math.cos(zorg_ang)*ZORG_RADIUS,
      cy+math.sin(zorg_ang)*ZORG_RADIUS,
      cx+math.cos(zorg_ang)*ZORG_RADIUS+math.cos(ang)*30,
      cy+math.sin(zorg_ang)*ZORG_RADIUS+math.sin(ang)*30
    )
    love.graphics.line(
      100,100,
      100+math.cos(ang)*30,
      100+math.sin(ang)*30
    )
    love.graphics.circle("fill",100,100,2)
    dx = math.sin(zorg_ang)*ZORG_RADIUS-math.sin(moon_ang)*MOON_RADIUS
    dy = math.cos(zorg_ang)*ZORG_RADIUS-math.cos(moon_ang)*MOON_RADIUS
    love.graphics.print((zorg_ang+math.pi/2).." to "..(zorg_ang-math.pi/2),5,5)
    love.graphics.print("Raw "..ang,5,20)
    love.graphics.print("Updated "..scaledang,5,35)
    love.graphics.print("DELTA x: "..dx.." y:"..dy,5,50)
    love.graphics.print("Test x "..math.cos(scaledang).." y "..math.sin(scaledang),5,65)
  end
end


function love.update(dt)
  if not paused then
    if tinc > PLAY_DELAY then
      time = (time + PLAY_INC)
      tinc = 0
    end
    tinc = tinc + dt
  end
  --time = math.floor((time - 72)*10)/10
end

function love.keyreleased(key, scancode)
  if key == 'space' then
    paused = not paused
  elseif key == 'right' then
    time = time + 1
  elseif key == 'left' then
    time = time - 1
  elseif key == '.' then
    time = time + 0.1
  elseif key == ',' then
    time = time - 0.1
  elseif key == 'z' then
    zorg_spin_m = -zorg_spin_m
  elseif key == 'm' then
    moon_spin_m = -moon_spin_m
  elseif key == '0' then
    time = 0
  end
end


function love.load()
  time = 0
  tinc = 0
  paused = true
  zorg_spin_m = 1
  moon_spin_m = 1
  font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  love.window.setTitle("Zorg Simulator")
  love.graphics.setBackgroundColor(0.1,0.2,0.3)
end
