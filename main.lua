local player = {
	x = 0,
	y = 0,
	vx = 0,
	vy = 0,
	ct = 0,
	c = {r = 0, g = 0, b = 0},
	vmax = 128,
}

local banner = {
	text = {},
	bg = {
		r = 0.26,
		g = 0.26,
		b = 0.26,
	},
	t = 0,
	t_out = 0,
	a = 0,
	v = false,
}

local game_time
local folks
local mate
local C

function drawBackground()
	for y = 0, 9 do
		for x = 0, 9 do
			local n = x + y
			local rb = n % 2 == 0 and 0.2 or 0
			local dx = player.x % 150
			local dy = player.y % 150
			love.graphics.setColor(rb * C, 0.5 * C, rb * C, 1 * C)
			love.graphics.rectangle('fill', x * 75 - dx, y * 75 - dy, 75, 75)
		end
	end
end

function colour(ct, x)
	if ct < x then
		return math.max(ct - (x - 1), 0)
	else
		return math.max((x + 1) - ct, 0)
	end
end

function makeBanner(text, t)
	banner.text = text
	banner.t = -1
	banner.t_out = t
	banner.a = 0
	banner.v = true
end

function updatePlayer(dt)
	player.ct = (player.ct + dt) % 4
	player.c.r = colour(player.ct, 1)
	player.c.g = colour(player.ct, 2)
	player.c.b = colour(player.ct, 3)
end

function updateMate(dt)
	player.c.r = colour(player.ct, 1)
	player.c.g = colour(player.ct, 2)
	player.c.b = colour(player.ct, 3)
	local dx = mate.x - player.x
	local dy = mate.y - player.y
	local dd = math.sqrt(dx * dx + dy * dy)
	local fx = dy / dd * player.vmax
	local fy = -dx / dd * player.vmax
	mate.vx = fx * 0.25
	mate.vy = fy * 0.25
end

function updateBanner(dt)
	if not banner.v then
		return
	end
	banner.t = banner.t + 1 * dt
	if banner.t < 0 then
		banner.a = banner.a + 1 * dt
	elseif banner.t > banner.t_out then
		banner.a = banner.a - 1 * dt
	end
	if banner.t > banner.t_out + 1 then
		banner.v = false
	end
end

function distance(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return math.sqrt(dx * dx + dy * dy)
end

function checkHit(p, f)
	if distance(p, f) < 20 and not f.likes(p) then
		local dx = p.x - f.x
		local dy = p.y - f.y
		local dd = math.sqrt(dx * dx + dy * dy)
		local fx = dx / dd * 20
		local fy = dy / dd * 20
		player.x = player.x + fx
		player.y = player.y + fy
	end
end

function drawMate()
	love.graphics.setColor(player.c.r * C, player.c.g * C, player.c.b * C, 1 * C)
	love.graphics.circle('fill', mate.x - player.x, mate.y - player.y, 9)
end

function drawPlayer()
	love.graphics.setColor(player.c.r * C, player.c.g * C, player.c.b * C, 1 * C)
	love.graphics.circle('fill', 0, 0, 9)
end

function drawFolks()
	for i, folk in ipairs(folks.all) do
		love.graphics.setColor(folk.c.r * C, folk.c.g * C, folk.c.b * C, 1 * C)
		love.graphics.circle('fill', folk.x - player.x, folk.y - player.y, 9)
	end
end

function drawBanner()
	if banner.v then
		local b = banner
		love.graphics.setColor(b.bg.r * C, b.bg.g * C, b.bg.b * C, b.a * 0.75 * C)
		love.graphics.rectangle('fill', 0, 400, 600, 200)
		love.graphics.setColor(C, C, C, C * b.a)
		love.graphics.printf(banner.text, 0, 450, 600, 'center')
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == 'left' then
		player.vx = -player.vmax
	elseif key == 'right' then
		player.vx = player.vmax
	elseif key == 'up' then
		player.vy = -player.vmax
	elseif key == 'down' then
		player.vy = player.vmax
	end
end

function love.keyreleased(key, scancode, isrepeat)
	if key == 'left' and player.vx < 0 then
		player.vx = 0
	elseif key == 'right' and player.vx > 0 then
		player.vx = 0
	elseif key == 'up' and player.vy < 0 then
		player.vy = 0
	elseif key == 'down' and player.vy > 0 then
		player.vy = 0
	end
end

function move(o, dt)
	o.x = o.x + o.vx * dt
	o.y = o.y + o.vy * dt
end

function spawnRedFolk(x, y, vx, vy)
	local f = {
		x = x,
		y = y,
		vx = vx,
		vy = vy,
		c = {r = 1, g = 0, b = 0},
		likes = function(o)
			return o.c.r > 0.5 and o.c.g < 0.5 and o.c.b < 0.5
		end,
	}
	table.insert(folks.all, f)
end

function spawnGreenFolk(x, y, vx, vy)
	local f = {
		x = x,
		y = y,
		vx = vx,
		vy = vy,
		c = {r = 0, g = 1, b = 0},
		likes = function(o)
			return o.c.r < 0.5 and (o.c.g > 0.5 or o.c.b > 0.5)
		end,
	}
	table.insert(folks.all, f)
end

function spawnBlueFolk(x, y, vx, vy)
	local f = {
		x = x,
		y = y,
		vx = vx,
		vy = vy,
		c = {r = 0, g = 0, b = 1},
		likes = function(o)
			return o.c.r < 0.5 and (o.c.g > 0.5 or o.c.b > 0.5)
		end,
	}
	table.insert(folks.all, f)
end

function spawnFolk()
	local p = player
	local color = love.math.random(1, 3)
	local r = love.math.random(200, 1500)
	local phi = love.math.random() * math.pi * 2
	local x = r * math.sin(phi)
	local y = r * math.cos(phi)
	local vx = love.math.random(-32, 32)
	local vy = love.math.random(-32, 32)
	if color == 1 then
		spawnRedFolk(x, y, vx, vy)
	elseif color == 2 then
		spawnGreenFolk(x, y, vx, vy)
	elseif color == 3 then
		spawnBlueFolk(x, y, vx, vy)
	end
end

function spawnFolks(n)
	for i = 1, n do
		spawnFolk()
	end
end

function spawnMate()
	local r = love.math.random(1500, 1600)
	local phi = love.math.random(0, 2 * math.pi)
	mate = {
		x = r * math.sin(phi),
		y = r * math.cos(phi),
		vx = 0,
		vy = 0,
	}
end

function love.load()
	local major = love.getVersion()
	C = major < 1 and 255 or 1
	game_time = 0
	folks = {}
	folks.all = {}
	spawnFolks(1500)
	spawnMate()
end

function love.update(dt)
	game_time = game_time + dt
	updatePlayer(dt * 0.3)
	updateMate(dt)
	move(player, dt)
	for i, folk in ipairs(folks.all) do
		move(folk, dt)
		checkHit(player, folk)
	end
	move(mate, dt)
	updateBanner(dt)
end

function love.draw()
	drawBackground()
	love.graphics.translate(300, 300)
	drawFolks()
	drawMate()
	drawPlayer()
	love.graphics.translate(-300, -300)
	drawBanner()
end
