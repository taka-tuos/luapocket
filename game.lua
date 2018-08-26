local x,y,vx,vy = 0,0,1,1
function onFrame()
	gfxDrawRect(x, y, 16, 16, 16, 16)
	x = x + vx
	y = y + vy
	if x <= 0 or x >= 240 - 16 - 1 then vx = -vx end
	if y <= 0 or y >= 160 - 16 - 1 then vy = -vy end
end
