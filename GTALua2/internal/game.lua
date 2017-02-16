-- Game specific functions
game = {}

-- IsPaused
function game.IsPaused()
	return natives.UI.IS_PAUSE_MENU_ACTIVE()
end

-- Time - hours
function game.GetHours()
	return natives.TIME.GET_CLOCK_HOURS()
end

-- Time - minutes
function game.GetMinutes()
	return natives.TIME.GET_CLOCK_MINUTES()
end

-- Time - seconds
function game.GetSeconds()
	return natives.TIME.GET_CLOCK_SECONDS()
end

-- Set game TimerA
function game.SetTimerA(n)
	natives.SYSTEM.SETTIMERA(n)
end

-- Set game TimerB
function game.SetTimerB(n)
	natives.SYSTEM.SETTIMERB(n)
end

-- Get game TimerA
function game.GetTimerA()
	return natives.SYSTEM.TIMERA()
end

-- Get game TimerB
function game.GetTimerB()
	return natives.SYSTEM.TIMERB()
end

-- Get coordinate in front of cam
function game.GetCoordsInFrontOfCam(distance)
	distance = distance or 5000
	local GameplayCamCoord = natives.CAM.GET_GAMEPLAY_CAM_COORD()
	local GameplayCamRot = natives.CAM.GET_GAMEPLAY_CAM_ROT(2)

	local tanX = natives.SYSTEM.COS(GameplayCamRot.x) * distance
	local xPlane = natives.SYSTEM.SIN(GameplayCamRot.z * -1.0) * tanX + GameplayCamCoord.x
	local yPlane = natives.SYSTEM.COS(GameplayCamRot.z * -1.0) * tanX + GameplayCamCoord.y
	local zPlane = natives.SYSTEM.SIN(GameplayCamRot.x) * distance + GameplayCamCoord.z

	return {x=xPlane, y=yPlane, z=zPlane}
end

-- Get the aimed entity and aimed point via RayCast
function game.GetRaycastTarget(distance, flags, entity, intersect, p1, p2)
	intersect = intersect or 7
	local p1 = p1 or natives.CAM.GET_GAMEPLAY_CAM_COORD()
	local p2 = p2 or game.GetCoordsInFrontOfCam(distance)
	local ray = natives.WORLDPROBE._START_SHAPE_TEST_RAY(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, flags, entity, intersect)
	local hit = Cval:new()
	local endCoords = Cvec:new()
	local surfaceNormal = Cvec:new()
	local entityHit = Cval:new()
	local enum = natives.WORLDPROBE.GET_SHAPE_TEST_RESULT(ray, hit, endCoords, surfaceNormal, entityHit)
	local ent, pointHit
	if hit:getBool() then
		ent = Entity:new(entityHit:getInt())
		if ent:IsPed() then
			ent = Ped:new(entityHit:getInt())
		end
		if ent:IsVehicle() then
			ent = Vehicle:new(entityHit:getInt())
		end
		if ent:IsObject() then
			ent = Object:new(entityHit:getInt())
		end
		pointHit = endCoords:get()
	end
	return ent, pointHit
end

-- Convert World to Screen coordinates
function game.WorldToScreen(p)
	local screenX = Cval:new()
	local screenY = Cval:new()
	local result
	if natives.GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(p.x, p.y, p.z, screenX, screenY) then
		result = {x=screenX:getFloat(), y=screenY:getFloat()}
	else
		result = nil
	end
	return result
end

