local Xuyo = {}

local _width = 12
local _height = 12
local _vanish = 4
local _color = 5
local _field = {}

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function Xuyo.Check()
	local nX = 0
	local nY = 0
	local nReturn = false
	local stDummy

	for nX = 1,_width do
		for nY = 1,_height do
			if _field[nX][nY].nColor ~= 0 then
				_field[nX][nY].nVanish = 0

				stDummy = deepcopy(_field)

				_field[nX][nY].nVanish, stDummy = Xuyo.Count(stDummy, nX, nY, _field[nX][nY].nVanish);

				if _field[nX][nY].nVanish >= _vanish then
					nReturn = true
				end
			end
		end
	end

	return nReturn
end

function Xuyo.Count(pField, nX, nY, pCount)
	local nColor = pField[nX][nY].nColor

	pField[nX][nY] = {}
	pField[nX][nY].nVanish = 0
	pField[nX][nY].nColor = 0

	pCount = pCount + 1

	if nY - 1 >= 1 and nColor == pField[nX][nY - 1].nColor then
		pCount, pField = Xuyo.Count(pField, nX, nY - 1, pCount)
	end

	if nY + 1 <= _height and nColor == pField[nX][nY + 1].nColor then
		pCount, pField = Xuyo.Count(pField, nX, nY + 1, pCount)
	end

	if nX - 1 > 0 and nColor == pField[nX - 1][nY].nColor then
		pCount, pField = Xuyo.Count(pField, nX - 1, nY, pCount)
	end

	if nX + 1 <= _width and nColor == pField[nX + 1][nY].nColor then
		pCount, pField = Xuyo.Count(pField, nX + 1, nY, pCount);
	end
	
	return pCount, pField
end

function Xuyo.Slide()
	local nX = 0
	local nY = 0
	local nReturn = false

	for nY = _height,2,-1 do
		for nX = 1,_width do
			--print (nX,nY)
			if _field[nX][nY].nColor == 0 and _field[nX][nY - 1].nColor ~= 0 then
				_field[nX][nY] = deepcopy(_field[nX][nY - 1])

				_field[nX][nY - 1] = {}
				_field[nX][nY - 1].nVanish = 0
				_field[nX][nY - 1].nColor = 0
				_field[nX][nY - 1].onControl = 0

				nReturn = true
			end
		end
	end

	return nReturn
end

function Xuyo.Vanish()
	local nX = 0
	local nY = 0
	
	local en = 0

	for nX = 1,_width do
		for nY = 1,_height do
			if _field[nX][nY].nVanish >= _vanish then
				--print(_field[nX][nY].nVanish)
				_field[nX][nY] = {}
				_field[nX][nY].nVanish = 0
				_field[nX][nY].nColor = 0
				_field[nX][nY].onControl = 0
				
				en = en + 1
			end
		end
	end
	
	return en
end

function RenderChar(v, x, y, s)
	DrawSprite(x, y, math.mod(v,16) * 8, math.floor(v / 16) * 8, 8, 8, s, s)
end

function RenderString(sz, x, y, s)
	if s == nil then s = 16 end
	local i
	for i=1,string.len(sz) do
		RenderChar(string.byte(sz, i),x+(i-1)*s,y,s)
	end
end

function RenderBlock(v, x, y, b)
	DrawSprite(x, y, v * 8, 128 + b * 8, 8, 8, 32, 32)
	--DrawSprite(x, y, 128, 0, 32, 32, 32, 32)
end

local cnt0 = 0
local cnt1 = 0
local cnt2 = 0

local randN1 = 0
local randN2 = 0

function nextRandom()
	local pn1 = randN1
	local pn2 = randN2
	
	while pn1 == randN1 do
		randN1 = math.random(5)
	end
	
	while pn2 == randN2 do
		randN2 = math.random(5)
	end
end

function onInit()
	local i,j
	
	for i=1,_width do
		_field[i] = {}
		for j=1,_height do
			--print(i,j)
			_field[i][j] = {}
			_field[i][j].nVanish = 0
			_field[i][j].nColor = 0
			_field[i][j].onControl = 0
		end
	end
	
	for i=1,_height do
		for j=1,_width do
			--print(_field[i][j].nColor)
		end
	end
	
	nextRandom()
end

function makeBitNear(x, y, nc)
	local bit = 0

	if x ~= 1 then
		if _field[x-1][y].nColor == nc then bit = bit + 1 end
	end
	
	if x ~= _width then
		if _field[x+1][y].nColor == nc then bit = bit + 2 end
	end
	
	if y ~= 1 then
		if _field[x][y-1].nColor == nc then bit = bit + 4 end
	end
	
	if y ~= _height then
		if _field[x][y+1].nColor == nc then bit = bit + 8 end
	end
	
	return bit
end

function getSlaveBlock(x, y)
	local bit = 0

	if x ~= 1 then
		if _field[x-1][y].onControl == 2 then return 2 end
	end
	
	if x ~= _width then
		if _field[x+1][y].onControl == 2 then return 4 end
	end
	
	if y ~= 1 then
		if _field[x][y-1].onControl == 2 then return 3 end
	end
	
	if y ~= _height then
		if _field[x][y+1].onControl == 2 then return 1 end
	end
	
	return bit
end

function userMove(i, j, vy, vxR, vxL, dir)
	if dir == 1 then
		if vy > 0 then
			if j < _height-1 then
				if _field[i][j+2].nColor == 0 then
					_field[i][j+2] = deepcopy(_field[i][j+1])
					_field[i][j+1] = deepcopy(_field[i][j])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
				end
			end
		elseif vxR > 0 then
			if i < _width then
				if _field[i+1][j].nColor == 0 and _field[i+1][j+1].nColor == 0 then
					_field[i+1][j] = deepcopy(_field[i][j])
					_field[i+1][j+1] = deepcopy(_field[i][j+1])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
					
					_field[i][j+1].nVanish = 0
					_field[i][j+1].nColor = 0
					_field[i][j+1].onControl = 0
				end
			end
		elseif vxL > 0 then
			if i > 1 then
				if _field[i-1][j].nColor == 0 and _field[i-1][j+1].nColor == 0 then
					_field[i-1][j] = deepcopy(_field[i][j])
					_field[i-1][j+1] = deepcopy(_field[i][j+1])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
					
					_field[i][j+1].nVanish = 0
					_field[i][j+1].nColor = 0
					_field[i][j+1].onControl = 0
				end
			end
		end
	end
	
	if dir == 2 then
		if vy > 0 then
			if j < _height then
				if _field[i][j+1].nColor == 0 and _field[i-1][j+1].nColor == 0 then
					_field[i][j+1] = deepcopy(_field[i][j])
					_field[i-1][j+1] = deepcopy(_field[i-1][j])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
					_field[i-1][j].nVanish = 0
					_field[i-1][j].nColor = 0
					_field[i-1][j].onControl = 0
				end
			end
		elseif vxR > 0 then
			if i < _width then
				if _field[i+1][j].nColor == 0 then
					_field[i+1][j] = deepcopy(_field[i][j])
					_field[i][j] = deepcopy(_field[i-1][j])
					_field[i-1][j].nVanish = 0
					_field[i-1][j].nColor = 0
					_field[i-1][j].onControl = 0
				end
			end
		elseif vxL > 0 then
			if i > 2 then
				if _field[i-2][j].nColor == 0 then
					_field[i-2][j] = deepcopy(_field[i-1][j])
					_field[i-1][j] = deepcopy(_field[i][j])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
				end
			end
		end
	end
	
	if dir == 3 then
		if vy > 0 then
			if j < _height then
				if _field[i][j+1].nColor == 0 then
					_field[i][j+1] = deepcopy(_field[i][j])
					_field[i][j] = deepcopy(_field[i][j-1])
					_field[i][j-1].nVanish = 0
					_field[i][j-1].nColor = 0
					_field[i][j-1].onControl = 0
				end
			end
		elseif vxR > 0 then
			if i < _width then
				if _field[i+1][j].nColor == 0 and _field[i+1][j-1].nColor == 0 then
					_field[i+1][j] = deepcopy(_field[i][j])
					_field[i+1][j-1] = deepcopy(_field[i][j-1])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
					
					_field[i][j-1].nVanish = 0
					_field[i][j-1].nColor = 0
					_field[i][j-1].onControl = 0
				end
			end
		elseif vxL > 0 then
			if i > 1 then
				if _field[i-1][j].nColor == 0 and _field[i-1][j-1].nColor == 0 then
					_field[i-1][j] = deepcopy(_field[i][j])
					_field[i-1][j-1] = deepcopy(_field[i][j-1])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
					
					_field[i][j-1].nVanish = 0
					_field[i][j-1].nColor = 0
					_field[i][j-1].onControl = 0
				end
			end
		end
	end
	
	if dir == 4 then
		if vy > 0 then
			if j < _height then
				if _field[i][j+1].nColor == 0 and _field[i+1][j+1].nColor == 0 then
					_field[i][j+1] = deepcopy(_field[i][j])
					_field[i+1][j+1] = deepcopy(_field[i+1][j])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
					_field[i+1][j].nVanish = 0
					_field[i+1][j].nColor = 0
					_field[i+1][j].onControl = 0
				end
			end
		elseif vxR > 0 then
			if i < _width-1 then
				if _field[i+2][j].nColor == 0 then
					_field[i+2][j] = deepcopy(_field[i+1][j])
					_field[i+1][j] = deepcopy(_field[i][j])
					_field[i][j].nVanish = 0
					_field[i][j].nColor = 0
					_field[i][j].onControl = 0
				end
			end
		elseif vxL > 0 then
			if i > 1 then
				if _field[i-1][j].nColor == 0 then
					_field[i-1][j] = deepcopy(_field[i][j])
					_field[i][j] = deepcopy(_field[i+1][j])
					_field[i+1][j].nVanish = 0
					_field[i+1][j].nColor = 0
					_field[i+1][j].onControl = 0
				end
			end
		end
	end
end

local roted = false

function onFrame()
	DrawSprite(32, 32, 128, 32, _width, _height, _width*32, _height*32)
	
	local i,j
	for i=1,_width do
		for j=1,_height do
			if _field[i][j].nColor > 0 then
				RenderBlock(_field[i][j].nColor-1,i*32,j*32, makeBitNear(i,j,_field[i][j].nColor))
			end
		end
	end
	
	local moved = false
	
	local vy = GetJoyState(1)
	local vxR = GetJoyState(2)
	local vxL = GetJoyState(3)
	
	for i=1,_width do
		if math.mod(cnt0,3) ~= 0 then break end
		for j=1,_height do
			if not moved then
				if _field[i][j].onControl == 1 then
					moved = true
					
					local dir = getSlaveBlock(i, j)
					
					if GetJoyState(4) == 1 then
						if not roted then
							if dir == 1 then
								if i > 1 then
									if _field[i-1][j].nColor == 0 then
										_field[i-1][j] = deepcopy(_field[i][j+1])
										
										_field[i][j+1].nVanish = 0
										_field[i][j+1].nColor = 0
										_field[i][j+1].onControl = 0
									end
								end
							end
							
							if dir == 2 then
								if j > 1 then
									if _field[i][j-1].nColor == 0 then
										_field[i][j-1] = deepcopy(_field[i-1][j])
										
										_field[i-1][j].nVanish = 0
										_field[i-1][j].nColor = 0
										_field[i-1][j].onControl = 0
									end
								end
							end
							
							if dir == 3 then
								if i < _width then
									if _field[i+1][j].nColor == 0 then
										_field[i+1][j] = deepcopy(_field[i][j-1])
										
										_field[i][j-1].nVanish = 0
										_field[i][j-1].nColor = 0
										_field[i][j-1].onControl = 0
									end
								end
							end
							
							if dir == 4 then
								if j < _height then
									if _field[i][j+1].nColor == 0 then
										_field[i][j+1] = deepcopy(_field[i+1][j])
										
										_field[i+1][j].nVanish = 0
										_field[i+1][j].nColor = 0
										_field[i+1][j].onControl = 0
									end
								end
							end
						end
						roted = true
					else
						roted = false
					end
					
					dir = getSlaveBlock(i, j)
					
					userMove(i, j, vy, vxR, vxL, dir)
				end
			end
		end
	end
	
	RenderString("N E X T", 640-160, 64) 
	
	RenderBlock(randN1-1, 640-160+40, 64+32, 0) 
	RenderBlock(randN2-1, 640-160+40, 64+32+32, 0) 
	
	cnt0 = cnt0 + 1
	
	if cnt0 == 30 then
		cnt0 = 0
		
		if not Xuyo.Slide() then
			for i=1,_width do
				for j=1,_height do
					_field[i][j].onControl = 0
				end
			end
			
			_field[_width/2][1].onControl = 1
			_field[_width/2][2].onControl = 2
			
			_field[_width/2][1].nColor = randN1
			_field[_width/2][2].nColor = randN2
			
			nextRandom()
			
			while true do
				if not Xuyo.Check() then
					break
				end
				Xuyo.Vanish()
			end
		end
	end
end
