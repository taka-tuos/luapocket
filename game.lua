local x,y,vx,vy = 320/2-16,240-32,0,0

local xoff = 0

local bpos = {}

local bt = 0

local epos = {}
local et = 0

local fpos = {}

local btd = 6
local btk = 0

function onFrame()
	DrawSprite(x, y, 96 + xoff * 32, 0, 32, 32)
	
	vy = GetJoyState(1) - GetJoyState(0)
	vx = GetJoyState(2) - GetJoyState(3)
	
	if GetJoyState(3) == 1 then
		if xoff > -2 then xoff = xoff - 1 end
	elseif GetJoyState(2) == 1 then
		if xoff < 2 then xoff = xoff + 1 end
	else
		if xoff < 0 then xoff = xoff + 1 end
		if xoff > 0 then xoff = xoff - 1 end
	end
	
	if GetJoyState(4) == 1 and bt == 0 then
		local posA = {}
		local posB = {}
		posA.x = x - 6 + 12
		posA.y = y 
		posB.x = x + 6 + 12
		posB.y = y
		
		table.insert(bpos, posA)
		table.insert(bpos, posB)
		
		bt = 3
	end
	
	local btk_1 = 16
	local btk_2 = 240
	local btk_3 = 6
	
	if btk ~= 0 then
		btk_1 = 32
		btk_2 = 256
		btk_3 = 7
	end
	
	if et == 0 then
		local pos = {}
		pos.x = math.random(320-32) + 7
		pos.y = -16
		
		table.insert(epos, pos)
		
		et = 1
	end
	
	for idx, pos in ipairs(bpos) do
		pos.y = pos.y - 8
		local bl = false
		
		for idx_e, pos_e in ipairs(epos) do
			if pos_e.x >= pos.x - 16 and pos_e.x <= pos.x + 8 and
			   pos_e.y >= pos.y - 16 and pos_e.y <= pos.y + 16
			then
				table.remove(epos, idx_e)
				table.remove(bpos, idx)
				bl = true
				local pos_f = {}
				pos_f.x = pos_e.x - (btk_1 / 2) + 4
				pos_f.y = pos_e.y - (btk_1 / 2) + 8
				pos_f.t = 0
				table.insert(fpos, pos_f)
			end
			if bl then break end
		end
		
		if not bl then
			if pos.y < -16 then 
				table.remove(bpos, idx)
			else
				DrawSprite(pos.x, pos.y, 88, 32, 8, 16)
				bpos[idx] = pos
			end
		end
	end
	
	for idx, pos in ipairs(epos) do
		pos.y = pos.y + 1
		if pos.y > 240 then 
			table.remove(epos, idx)
		else
			DrawSprite(pos.x, pos.y, 144, 208, 16, 16)
			epos[idx] = pos
		end
	end
	
	for idx, pos in ipairs(fpos) do
		if pos.t == btk_3*btd then
			table.remove(fpos, idx)
		else
			DrawSprite(pos.x, pos.y, math.floor(pos.t/btd) * btk_1, btk_2, btk_1, btk_1)
			pos.t = pos.t + 1
			fpos[idx] = pos
		end
	end
	
	--DrawSprite(0, 0, 144, 208, 16, 16)
	
	
	x = x + vx * 2
	y = y + vy * 2
	
	if x < 0 then x = 0 end
	if x > 320-32 then x = 320-32 end
	if y < 0 then y = 0 end
	if y > 240-32 then y = 240-32 end 
	
	if bt > 0 then bt = bt - 1 end
	if et > 0 then et = et - 1 end
end
