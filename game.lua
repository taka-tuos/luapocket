local Xuyo = {}

local _width = 12
local _height = 12
local _vanish = 4
local _color = 5
local _field = {}

local _nullblock = {}
_nullblock.nColor = 0
_nullblock.nVanish = 0

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

function onInit()
	local i,j
	
	for i=1,_width do
		_field[i] = {}
		for j=1,_height do
			print(i,j)
			_field[i][j] = {}
			_field[i][j].nVanish = 0
			_field[i][j].nColor = math.floor(math.random(5))
		end
	end
	
	for i=1,_height do
		for j=1,_width do
			print(_field[i][j].nColor)
		end
	end
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
			print (nX,nY)
			if _field[nX][nY].nColor == 0 and _field[nX][nY - 1].nColor ~= 0 then
				_field[nX][nY] = _field[nX][nY - 1]

				_field[nX][nY - 1] = {}
				_field[nX][nY - 1].nVanish = 0
				_field[nX][nY - 1].nColor = 0

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
				print(_field[nX][nY].nVanish)
				_field[nX][nY] = {}
				_field[nX][nY].nVanish = 0
				_field[nX][nY].nColor = 0
				
				en = en + 1
			end
		end
	end
	
	return en
end

function RenderChar(v, x, y)
	DrawSprite(x, y, math.mod(v,16) * 8, math.floor(v / 16) * 8, 8, 8, 16, 16)
end

function RenderBlock(v, x, y)
	DrawSprite(x, y, math.mod(v,4) * 64, 128 + math.floor(v / 4) * 64, 64, 64, 16, 16)
end

local cnt0 = 0
local cnt1 = 0
local cnt2 = 0

function onFrame()
	local i,j
	for i=1,_width do
		for j=1,_height do
			if _field[i][j].nColor > 0 then
				RenderBlock(_field[i][j].nColor-1,i*16,j*16)
			end
		end
	end
	
	cnt0 = cnt0 + 1
	
	if cnt0 == 30 then
		cnt0 = 0
		
		if not Xuyo.Slide() then
			while true do
				if not Xuyo.Check() then
					break
				end
				Xuyo.Vanish()
			end
		end
	end
end
