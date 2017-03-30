-- Game specific functions
game = {}

-- Create Vehicle 

function game.CreateVehicle(model_hash, vec, heading)
	if not streaming.HasModelLoaded(model_hash) then
		error("You need to load the model before creating a Vehicle! Call streaming.RequestModel prior to calling game.CreateVehicle!")
	end
	if heading == nil then
		heading = 0
	end
	local veh_handle = natives.VEHICLE.CREATE_VEHICLE(model_hash, vec.x, vec.y, vec.z, heading, true, true)
	return Vehicle:new(veh_handle)
end

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

-- Waits for n milliseconds

function game.WaitMS(n)
	n = n or 1000
	t = natives.GAMEPLAY.GET_GAME_TIMER() + n
	while natives.GAMEPLAY.GET_GAME_TIMER() < t do
		Wait(0)
	end
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
	local hit = Cvar:new()
	local endCoords = Cvec:new()
	local surfaceNormal = Cvec:new()
	local entityHit = Cvar:new()
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

-- Get the Ped or Vehicle driver as target (Uses Raycast)

function game.GetTargetPed(distance, flags, entity)
	local ent = select(1, game.GetRaycastTarget(distance, flags, entity))
	if ent then
		if ent:IsVehicle() then
			ent = ent:GetPedInSeat(VehicleSeatDriver)
		else
			if not ent:IsPed() then
				ent = nil
			end
		end
	end
	return ent
end

-- Request weapon asset (pass weapon hash)

function game.RequestWeaponAsset(weaponAsset)
	if not natives.WEAPON.HAS_WEAPON_ASSET_LOADED(weaponAsset) then
		natives.WEAPON.REQUEST_WEAPON_ASSET(weaponAsset, 1, 1)
		-- Wait
		while not natives.WEAPON.HAS_WEAPON_ASSET_LOADED(weaponAsset) do
			Wait(10)
		end
	end
end

-- Shoot a bullet between two coordinates

function game.ShootBulletBetweenCoords(org, tgt, weapon, damage, speed, owner)
	weapon = weapon or WeaponPistol
	damage = damage or 200
	speed = speed or 200
	owner = owner or -1
	game.RequestWeaponAsset(weapon)
	natives.GAMEPLAY.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(org.x, org.y, org.z, tgt.x, tgt.y, tgt.z, damage, true, weapon, owner, true, true, speed)
end

-- Convert World to Screen coordinates

function game.WorldToScreen(p)
	local screenX = Cvar:new()
	local screenY = Cvar:new()
	local result
	if natives.GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(p.x, p.y, p.z, screenX, screenY) then
		result = {x=screenX:getFloat(), y=screenY:getFloat()}
	else
		result = nil
	end
	return result
end

-- Computes the distance between two 3D coordinatess

function game.Distance(p1, p2)
	return natives.SYSTEM.VDIST(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z)
end

-- Get the new point n units from p1 going towards p2

function game.MovePoint(p1, p2, n)
	local distance = natives.SYSTEM.VDIST(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z)
	if distance < n*2 then
		distance = n*2
	end		
	local newX = p1.x+((n/distance)*(p2.x-p1.x))
	local newY = p1.y+((n/distance)*(p2.y-p1.y))
	local newZ = p1.z+((n/distance)*(p2.z-p1.z))
	return {x=newX, y=newY, z=newZ}
end
