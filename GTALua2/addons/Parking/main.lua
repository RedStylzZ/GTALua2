--
-- Public Parking implementation by Mockba the Borg
--
Parking = {}
Parking.__index = Parking

-- ScriptInfo table must exist and define Name, Author and Version
Parking.ScriptInfo = {
	Name = "Parking",	-- Must match the module folder name
	Author = "Mockba the Borg",
	Version = "1.0"
}

-- Version Number
local _Version = "1.0"

-- Global variables
local _Debug = false
local _DrawAsMissionEntity = true

-- Garage global variables
local _NGarages = 12
local _DefaultGarage = 1
local _GarageSpots = {}
local _Spots = {}
local _FarAway = {x=500, y=7500, z=50, h=0}
local _GarageInUse
--local _TeleportKey = VK_OEM_1	-- :;
local _TeleportKey = -1			-- :;
local _RedrawKey = VK_OEM_2		-- ?/
local _GarageSize = 12
local _GarageZ = -99.5
local _GaragePos = {
	{x=396.42, y=-970.70, z=_GarageZ, h=270},
	{x=414.45, y=-970.70, z=_GarageZ, h=90},
	{x=396.42, y=-964.70, z=_GarageZ, h=270},
	{x=414.45, y=-964.70, z=_GarageZ, h=90},
	{x=396.42, y=-958.70, z=_GarageZ, h=270},
	{x=414.45, y=-958.70, z=_GarageZ, h=90},
	{x=396.42, y=-952.70, z=_GarageZ, h=270},
	{x=414.45, y=-952.70, z=_GarageZ, h=90},
	{x=396.42, y=-946.70, z=_GarageZ, h=270},
	{x=414.45, y=-946.70, z=_GarageZ, h=90},
	{x=396.42, y=-940.70, z=_GarageZ, h=270},
	{x=414.45, y=-940.70, z=_GarageZ, h=90}
}
local _GarageBlips = {}
local _GarageInSpawn = {x=405.45, y=-974.83, z=_GarageZ, h=0}
local	_GarageOutSpawn = {}
	_GarageOutSpawn[1] = {x=-759.68, y=-79.84, z=36.5, h=115.22}
	_GarageOutSpawn[2] = {x=-952.59, y=-181.46, z=36.5, h=200}
	_GarageOutSpawn[3] = {x=-357.67, y=-437.65, z=26.34, h=353.11}
	_GarageOutSpawn[4] = {x=-224.04, y=-271.48, z=48.42, h=71.35}
	_GarageOutSpawn[5] = {x=-306.58, y=-710.79, z=28.20, h=338.51}
	_GarageOutSpawn[6] = {x=135.51, y=-1050.29, z=28.66, h=159.31}
	_GarageOutSpawn[7] = {x=-1417.67, y=-478.95, z=33.14, h=120.86}
	_GarageOutSpawn[8] = {x=-270.79, y=285.52, z=89.92, h=178.44}
	_GarageOutSpawn[9] = {x=-765.82, y=236.13, z=75.10, h=189.27}
	_GarageOutSpawn[10] = {x=-1551.65, y=-553.38, z=27.03, h=36.05}
	_GarageOutSpawn[11] = {x=-955.82, y=-1287.30, z=4.55, h=316.3}
	_GarageOutSpawn[12] = {x=-819.19, y=-732.53, z=27.34, h=96.11}
local	_GarageInDoor = {}
	_GarageInDoor[1] = {x=-717.8, y=-58.6, z=37}
	_GarageInDoor[2] = {x=-888.4, y=-147.7, z=37}
	_GarageInDoor[3] = {x=-357.67, y=-437.65, z=26.34}
	_GarageInDoor[4] = {x=-224.04, y=-271.48, z=48.42}
	_GarageInDoor[5] = {x=-306.58, y=-710.79, z=28.20}
	_GarageInDoor[6] = {x=135.51, y=-1050.29, z=28.66}
	_GarageInDoor[7] = {x=-1417.67, y=-478.95, z=33.14}
	_GarageInDoor[8] = {x=-270.79, y=285.52, z=89.92}
	_GarageInDoor[9] = {x=-765.82, y=236.13, z=75.10}
	_GarageInDoor[10] = {x=-1554.91, y=-556.67, z=26.75}
	_GarageInDoor[11] = {x=-963.43, y=-1283.47, z=4.65}
	_GarageInDoor[12] = {x=-617.38, y=-738.06, z=268.62}
local _InDoorEnabled = true
local _GarageOutDoor = {x=405.45, y=-978.83, z=_GarageZ}
local _InsideGarage = false
local _DoorRadius = 3
local _WaitTime = 3000

-- Vehicle storage variables
local _VehicleTable
local _VehicleFileFolder = LuaFolder() .. "\\addons\\Parking\\"
local _VehicleFileName = "Garage"
local _VehicleFileExt = ".vdf"
local _VehicleBlip
local _VehicleOut

-- Garage vehicles values
local _MPBitset = 8

-- Garage camera and interior
local _GarageCam
local _GarageInterior = 0

-- Player global variables
local playerPlayerID
local playerID
local playerPos
local playerVehicle

-- Debug printing conditioned to _Debug = true
function Parking:DebugPrint(...)
	local res = ""
	if _Debug then
		for i,v in ipairs({...}) do
			res = res .. tostring(v) .. " "
		end
		print(res)
	end
end

-- Checks if a vehicle description file exists locally
function Parking:VehicleFileExists(spot)
	local filename = _VehicleFileFolder.._VehicleFileName.._GarageInUse.."Spot"..spot.._VehicleFileExt
	local f=io.open(filename, "r")
	if f~=nil then io.close(f) return true else return false end
end

-- Splits a string in parts base on a field separator
function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

-- Loads a vehicle description file and places the data on a garage spot
function Parking:LoadVehicleFile(spot)
	local filename = _VehicleFileFolder.._VehicleFileName.._GarageInUse.."Spot"..spot.._VehicleFileExt
	local f,err=io.open(filename, "r")
	if err then
		print("Error reading", filename, "...")
		return
	end
	local vehicle = {}
	while true do
		local line = f:read()
		if not line then
			break
		end
		local vars = line:split(":")
		if tonumber(vars[1]) then
			vars[1] = tonumber(vars[1])
		end
		if tonumber(vars[2]) then
			vars[2] = tonumber(vars[2])
		end
		vehicle[vars[1]]=vars[2]
	end
	if vehicle.name then
		vehicle.hash = natives.GAMEPLAY.GET_HASH_KEY(vehicle.name)
		_GarageSpots[_GarageInUse][spot]=vehicle
	else
		print("Invalid vehicle file.")
		_GarageSpots[_GarageInUse][spot]=nil
	end

	f:close()
end

-- Saves a garage spot on a local vehicle description file
function Parking:SaveVehicleFile(garage, spot)
	local vehicle = _GarageSpots[garage][spot]
	local filename = _VehicleFileFolder.._VehicleFileName..garage.."Spot"..spot.._VehicleFileExt
	local f,err=io.open(filename, "w")
	if err then
		print("Error writing", filename, "...")
		return
	end
	vehicle.name = VEHICLES[vehicle.hash].Name
	f:write("name:"..vehicle.name.."\n")
	f:write("pricolor:"..(vehicle.pricolor or -1).."\n")
	f:write("seccolor:"..(vehicle.seccolor or -1).."\n")
	f:write("prlcolor:"..(vehicle.prlcolor or -1).."\n")
	f:write("whlcolor:"..(vehicle.whlcolor or -1).."\n")
	f:write("actcolor:"..(vehicle.actcolor or -1).."\n")
	f:write("trmcolor:"..(vehicle.trmcolor or -1).."\n")
	f:write("Livery:"..(vehicle.livery or -1).."\n")
	f:write("wndtint:"..(vehicle.wndtint or -1).."\n")
	f:write("plttype:"..(vehicle.plttype or -1).."\n")
	if vehicle.plttext then
		f:write("plttext:"..vehicle.plttext.."\n")
	end
	f:write("whltype:"..(vehicle.whltype or -1).."\n")
	f:write("neonR:"..(vehicle.neonR or -1).."\n")
	f:write("neonG:"..(vehicle.neonG or -1).."\n")
	f:write("neonB:"..(vehicle.neonB or -1).."\n")
	for i=0,48 do
		f:write(i..":"..(vehicle[i] or -1).."\n")
	end
	f:close()
end

-- Removes a local vehicle description file
function Parking:RemoveVehicleFile(garage, spot)
	local filename = _VehicleFileFolder.._VehicleFileName..garage.."Spot"..spot.._VehicleFileExt
	os.remove(filename)
end

-- Loads an entire garage into memory spots
function Parking:LoadGarage()
	Parking:DebugPrint("Loading local garage", _GarageInUse, "...")
	for spot=1,_GarageSize do
		if Parking:VehicleFileExists(spot) then
			Parking:DebugPrint("    Spot",spot,"...")
			Parking:LoadVehicleFile(spot)
		end
	end
end

-- Saves an entire garage onto local vehicle description files
function Parking:SaveGarage(garage)
	garage = garage or _GarageInUse
	Parking:DebugPrint("Saving garage", garage, "locally ...")
	for spot=1,_GarageSize do
		local s = _GarageSpots[garage][spot]
		if s then
			Parking:DebugPrint("    Spot",spot,"...")
			Parking:SaveVehicleFile(garage, spot)
		else
			Parking:RemoveVehicleFile(garage, spot)
		end
	end
end

-- Teleports a player and vehicle to a destination position
function Parking:Teleport(entID, pos)
	pos = pos or LocalPlayer():GetPosition()
	pos.h = pos.h or LocalPlayer():GetHeading()
	natives.ENTITY.SET_ENTITY_COORDS(entID, pos.x, pos.y, pos.z, false, false, false, true)
	natives.ENTITY.SET_ENTITY_HEADING(entID, pos.h)
	if Parking:IsInVehicle() then
		natives.VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(playerVehicle)
	end
end

-- Makes a player and vehicle invincible
function Parking:MakeInvincible(entID)
	natives.ENTITY.FREEZE_ENTITY_POSITION(entID, true)
	natives.ENTITY.SET_ENTITY_COLLISION(entID, false, true)
	natives.PED.SET_PED_CAN_BE_TARGETTED(playerID, false)
	natives.PED.SET_PED_CAN_RAGDOLL(playerID, false)
	natives.PLAYER.SET_PLAYER_INVINCIBLE(playerPlayerID, true)
end

-- Makes a player and vehicle vincible
function Parking:MakeVincible(entID)
	natives.ENTITY.FREEZE_ENTITY_POSITION(entID, false)
	natives.ENTITY.SET_ENTITY_COLLISION(entID, true, true)
	natives.PED.SET_PED_CAN_BE_TARGETTED(playerID, true)
	natives.PED.SET_PED_CAN_RAGDOLL(playerID, true)
	natives.PLAYER.SET_PLAYER_INVINCIBLE(playerPlayerID, false)
end

-- Makes an entity invisible
function Parking:MakeInvisible(entID)
	natives.ENTITY.SET_ENTITY_VISIBLE(entID, false, false)
end

-- Makes an entity visible
function Parking:MakeVisible(entID)
	natives.ENTITY.SET_ENTITY_VISIBLE(entID, true, false)
end

-- Set a vehicle as not needed
function Parking:SetNotNeeded(vehID)
	Parking:DebugPrint("Setting as not needed ...")
	local c_vehicle_handle = Cvar:new()
	c_vehicle_handle:setInt(vehID)
	natives.ENTITY.SET_VEHICLE_AS_NO_LONGER_NEEDED(c_vehicle_handle)
end

-- Checks if a player is in vehicle and sets playerVehicle global
function Parking:IsInVehicle()
	local InVehicle = natives.PED.IS_PED_IN_ANY_VEHICLE(playerID, false)
	if InVehicle then
		playerVehicle = natives.PED.GET_VEHICLE_PED_IS_IN(playerID, false)
	end
	return InVehicle
end

-- Finds the first free spot in a garage
function Parking:FirstFreeSpot()
	for spot=1,_GarageSize do
		if not _GarageSpots[_GarageInUse][spot] then
			return spot
		end
	end
	return nil
end

-- Draws (spawns) the cars inside the garage
function Parking:DrawGarage(Skip)
	Parking:DebugPrint("Drawing garage", _GarageInUse, "...")
	for spot=1,_GarageSize do
		local vehicle = _GarageSpots[_GarageInUse][spot]
		_Spots[spot] = nil
		if vehicle then
			if spot ~= Skip then
				Parking:DebugPrint("    Spot",spot,"...")
				local pos = _GaragePos[spot]
				natives.STREAMING.REQUEST_MODEL(vehicle.hash)
				while not natives.STREAMING.HAS_MODEL_LOADED(vehicle.hash) do
					Wait(10)
				end
--
				local vehID = natives.VEHICLE.CREATE_VEHICLE(vehicle.hash, pos.x, pos.y, pos.z, pos.h, true, true)
				natives.VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehID)
				natives.VEHICLE.SET_VEHICLE_COLOURS(vehID, vehicle.pricolor or -1, vehicle.seccolor or -1)
				natives.VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehID, vehicle.prlcolor or -1, vehicle.whlcolor or -1)
				natives.VEHICLE._SET_VEHICLE_ACCENT_COLOR(vehID, vehicle.actcolor or -1)
				natives.VEHICLE._SET_VEHICLE_TRIM_COLOR(vehID, vehicle.trmcolor or -1)
				natives.VEHICLE.SET_VEHICLE_WINDOW_TINT(vehID, vehicle.wndtint or -1)
				natives.VEHICLE.SET_VEHICLE_LIVERY(vehID, vehicle.livery or -1)
				natives.VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehID, vehicle.plttype or -1)
				if vehicle.plttext then
					natives.VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehID, vehicle.plttext)
				end
				natives.VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehID, vehicle.whltype or -1)
				natives.VEHICLE.SET_VEHICLE_MOD_KIT(vehID, 0)
				for mod=0,48 do
					vehicle[mod] = vehicle[mod] or -1
					if mod==18 or mod==20 or mod==21 or mod==22 then
						natives.VEHICLE.TOGGLE_VEHICLE_MOD(vehID, mod, vehicle[mod]==0)
						if mod==21 then
							if vehicle[mod]==0 then
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(vehID, vehicle.neonR, vehicle.neonG, vehicle.neonB)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 0, true)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 1, true)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 2, true)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 3, true)
							else
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 0, false)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 1, false)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 2, false)
								natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 3, false)
							end
						end
					else
						natives.VEHICLE.SET_VEHICLE_MOD(vehID, mod, vehicle[mod], true)
					end
					end
				natives.VEHICLE.ADD_VEHICLE_UPSIDEDOWN_CHECK(vehID)
				local multiplier = 50
				natives.VEHICLE._SET_VEHICLE_ENGINE_POWER_MULTIPLIER(vehID, multiplier)
				natives.VEHICLE._SET_VEHICLE_ENGINE_TORQUE_MULTIPLIER(vehID, multiplier)
			
				natives.VEHICLE.SET_VEHICLE_FRICTION_OVERRIDE(vehID, 2)
--
				Parking:SetGarageInfo(vehID, _GarageInUse, spot)
				natives.DECORATOR.DECOR_SET_INT(vehID, "MPBitset", _MPBitset)
				if _DrawAsMissionEntity then
				else
					Parking:SetNotNeeded(vehID)
				end
				vehicle.ID = vehID
				_GarageSpots[_GarageInUse][spot] = vehicle
				_Spots[spot] = vehID
			end
		end
	end
	Parking:DebugPrint("Done.")
end

-- Deletes a vehicle (entity)
function Parking:Delete(entID)
	Parking:DeleteEntityBlip(entID)
	natives.ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entID, true, false)
	if natives.ENTITY.DOES_ENTITY_EXIST(entID) then
		local c_entity_handle = Cvar:new()
		c_entity_handle:setInt(entID)
		natives.ENTITY.DELETE_ENTITY(c_entity_handle)
	end
end

-- Deletes a blip
function Parking:DeleteBlip(blipID)
	if blipID>0 then
		local c_blip_handle = Cvar:new()
		c_blip_handle:setInt(blipID)
		natives.UI.REMOVE_BLIP(c_blip_handle)
	end	
end

-- Deletes a vehicle (entity) blip
function Parking:DeleteEntityBlip(entID)
	local blip = natives.UI.GET_BLIP_FROM_ENTITY(entID)
	Parking:DeleteBlip(blip)
end

-- Deletes a vehicle left outside the garage
function Parking:DeleteOut()
	if _VehicleOut then
		Parking:Delete(_VehicleOut)
		_VehicleOut = nil
	end
end

-- Cleans up all the garage spots
function Parking:ClearGarage()
	local last
	Parking:DebugPrint("Cleaning up garage ...")
	for spot = 1,_GarageSize do
		if _Spots[spot] then
			Parking:DebugPrint("    Spot",spot,"...")
			vehID = _Spots[spot]
			Parking:Delete(vehID)
			if natives.ENTITY.DOES_ENTITY_EXIST(vehID) then
				print("Sending",vehID,"far away ...")
				Teleport(vehID, _FarAway)
				game.WaitMS(50)
			end
		end
	end
	Parking:DebugPrint("Done.")
end

-- Converts a vehicle to a vehicle description array
function Parking:VehicleToArray(vehID)
	local vehicle = {}
	vehicle.ID = vehID								-- ID
	vehicle.hash = natives.ENTITY.GET_ENTITY_MODEL(vehID)				-- Hash
	local m_p = Cvar:new()
	local m_s = Cvar:new()
	natives.VEHICLE.GET_VEHICLE_COLOURS(vehID, m_p, m_s)				-- Colors
	vehicle.pricolor = m_p:getInt()
	vehicle.seccolor = m_s:getInt()
	local m_p = Cvar:new()
	local m_s = Cvar:new()
	natives.VEHICLE.GET_VEHICLE_EXTRA_COLOURS(vehID, m_p, m_s)			-- Extra Colors
	vehicle.prlcolor = m_p:getInt()
	vehicle.whlcolor = m_s:getInt()
	local m_c = Cvar:new()
	natives.VEHICLE._GET_VEHICLE_ACCENT_COLOR(vehID, m_c)
	vehicle.actcolor = m_c:getInt()
	local m_c = Cvar:new()
	natives.VEHICLE._GET_VEHICLE_TRIM_COLOR(vehID, m_c)
	vehicle.trmcolor = m_c:getInt()
	vehicle.wndtint = natives.VEHICLE.GET_VEHICLE_WINDOW_TINT(vehID)		-- Window Tint
	vehicle.livery = natives.VEHICLE.GET_VEHICLE_LIVERY(vehID)			-- Livery
	vehicle.plttype = natives.VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehID)	-- Plate Type
	vehicle.plttext = natives.VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(vehID)		-- Plate Text
	vehicle.whltype = natives.VEHICLE.GET_VEHICLE_WHEEL_TYPE(vehID)			-- Wheel Type
	natives.VEHICLE.SET_VEHICLE_MOD_KIT(vehID, 0)					-- Mods
	for mod=0,48 do
		if mod==18 or mod==20 or mod==21 or mod==22 then
			vehicle[mod]=-1
			if natives.VEHICLE.IS_TOGGLE_MOD_ON(vehID, mod) then
				vehicle[mod]=0
			end
		else
			vehicle[mod]=natives.VEHICLE.GET_VEHICLE_MOD(vehID, mod)
		end
	end
	local m_r = Cvar:new()
	local m_g = Cvar:new()
	local m_b = Cvar:new()
	natives.VEHICLE._GET_VEHICLE_NEON_LIGHTS_COLOUR(vehID, m_r, m_g, m_b)
	vehicle.neonR = m_r:getInt()
	vehicle.neonG = m_g:getInt()
	vehicle.neonB = m_b:getInt()
	return vehicle
end

-- Repairs and cleans a vehicle
function Parking:WashAndFix(vehID)
	natives.VEHICLE.SET_VEHICLE_FIXED(vehID)
	natives.VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehID, 0)
end

-- Transfers vehicles between garages
function Parking:TransferVehicleFrom(garage, spot)
	Parking:DebugPrint("Transfering vehicle from garage", garage, "slot", spot, "...")
	_GarageSpots[garage][spot] = nil
	Parking:SaveGarage(garage)
end

-- Sets garage information into vehicle
function Parking:SetGarageInfo(entID, garage, spot)
	natives.DECORATOR.DECOR_SET_INT(entID, "Previous_Owner", garage)
	natives.DECORATOR.DECOR_SET_INT(entID, "PV_Slot", spot)
end

-- Enters a garage, either by boot or on a vehicle
function Parking:EnterGarage()
--	ClearGarage()
	ui.MapMessage("Entering Garage", _GarageInUse, "...")

	local InVehicle = false
	local FreeSpot, entID, entPos, PreviousGarage, PreviousSpot

	if Parking:IsInVehicle() then
		Parking:DebugPrint("  In vehicle ...")
		InVehicle = true
		entID = playerVehicle
		Parking:DebugPrint("  Stopping ...")
		natives.VEHICLE._SET_VEHICLE_HALT(entID, 3, 2, false)

		if natives.DECORATOR.DECOR_EXIST_ON(entID, "Previous_Owner") then
			PreviousGarage = natives.DECORATOR.DECOR_GET_INT(entID, "Previous_Owner")
			if PreviousGarage == 0 then
				natives.DECORATOR.DECOR_REMOVE(entID, "Previous_Owner")
				natives.DECORATOR.DECOR_REMOVE(entID, "PV_Slot")
				PreviousGarage = nil
			end
		end

		if PreviousGarage ~= _GarageInUse then
			FreeSpot = Parking:FirstFreeSpot()
			if not FreeSpot then
				Parking:FadeScreenOut()
				Parking:MakeInvincible(entID)
				Parking:FadePlayerOut(entID)
				ui.MapMessage("No free garage spots.")
				entPos = _GarageOutSpawn[_GarageInUse]
				Parking:Teleport(entID, entPos)
				Parking:FadePlayerIn(entID)
				Parking:MakeVincible(entID)
				Parking:FadeScreenIn()
				_InDoorEnabled = false
				return
			else
				if natives.DECORATOR.DECOR_EXIST_ON(entID, "PV_Slot") then
					PreviousSpot = natives.DECORATOR.DECOR_GET_INT(entID, "PV_Slot")
					Parking:TransferVehicleFrom(PreviousGarage, PreviousSpot)
				else
					Parking:DeleteOut()
				end
			end
		else
			FreeSpot = natives.DECORATOR.DECOR_GET_INT(entID, "PV_Slot")
		end
		Parking:DebugPrint("    Positioning vehicle on garage", _GarageInUse, "spot", FreeSpot, "...")
		entPos = _GaragePos[FreeSpot]
	else
		Parking:DebugPrint("  On foot ...")
		entID = playerID
		entPos = _GarageInSpawn
		Parking:DeleteOut()
	end

	Parking:FadeScreenOut()
	Parking:MakeInvincible(entID)
	Parking:FadePlayerOut(entID)

	Parking:Teleport(entID, entPos)
	Parking:MakeVincible(entID)
	Parking:MakeVisible(entID)

	_InsideGarage = true

	Parking:DeleteEntityBlip(entID)
	Parking:DrawGarage(FreeSpot)	-- Skips FreeSpot

	if InVehicle then
		if natives.VEHICLE.IS_VEHICLE_SIREN_ON(entID) then
			natives.VEHICLE.SET_VEHICLE_SIREN(entID, false)
		end
		Parking:DebugPrint("    Cleaning up vehicle ...")
		Parking:WashAndFix(entID)
		Parking:DebugPrint("    Saving vehicle in garage", _GarageInUse, "spot", FreeSpot, "...")
		_GarageSpots[_GarageInUse][FreeSpot] = Parking:VehicleToArray(entID)
		Parking:DebugPrint("    Setting vehicle's PV_Slot to",FreeSpot,"...")
		Parking:SetGarageInfo(entID, _GarageInUse, FreeSpot)
		Parking:DebugPrint("    Saving vehicle locally ...")
		Parking:SaveVehicleFile(_GarageInUse, FreeSpot)
		natives.AI.TASK_LEAVE_ANY_VEHICLE(playerID, 0, 0)
		_Spots[FreeSpot] = entID

		Parking:SetNotNeeded(entID)
	end

	natives.CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(0)

	game.WaitMS(_WaitTime)
	Parking:FadeScreenIn()

	Parking:DebugPrint("Entered garage ".._GarageInUse)
end

-- Shows markers depicting the various garage points
function Parking:ShowDebugData()
	if _Debug then
		if _InDoorEnabled then
			for n=1,_NGarages do
				ui.Draw3DPoint(_GarageInDoor[n], .5)
			end
			for n=1,_NGarages do
				local distance = game.Distance(playerPos, _GarageInDoor[n])
				if distance < 255 then
					alpha = 255-distance
					local color = {r=255,g=255,b=255,a=alpha}
					ui.Draw3DLine(playerPos, _GarageInDoor[n], color)
					local newPoint = game.MovePoint(playerPos, _GarageInDoor[n], 2)
					local textPos = game.WorldToScreen(newPoint)
					if textPos then
						ui.DrawTextUI(n, textPos.x, textPos.y-.04, FontChaletLondon, .2, color)
					end
				end
			end
		end
		for n=1,_NGarages do
			ui.Draw3DPoint(_GarageOutSpawn[n], .5)
		end
		for n = 1,_GarageSize do
			local pos = _GaragePos[n]
			ui.Draw3DPoint(pos, .5)
		end
	end
end

-- Exits a garage, either by foot or on a vehicle
function Parking:ExitGarage()
	ui.MapMessage("Exiting Garage", _GarageInUse, "...")
	_InDoorEnabled = false

	local Spot, entID, entPos

	Parking:FadeScreenOut()

	if Parking:IsInVehicle() then
		Parking:DebugPrint("  In vehicle ...")
		entID = playerVehicle
		Parking:WashAndFix(entID)
		Spot = natives.DECORATOR.DECOR_GET_INT(entID, "PV_Slot")
		_VehicleBlip = natives.UI.ADD_BLIP_FOR_ENTITY(entID)
		natives.UI.SET_BLIP_SPRITE(_VehicleBlip, 225)
		natives.UI.SET_BLIP_SCALE(_VehicleBlip, .5)
		_VehicleOut = entID
		Parking:SetGarageInfo(entID, _GarageInUse, Spot)
		natives.ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entID, true, false)
		natives.AUDIO.SET_VEH_RADIO_STATION(entID, "OFF")
		_Spots[Spot] = nil
	else
		Parking:DebugPrint("  On foot ...")
		entID = playerID
	end

	entPos = _GarageOutSpawn[_GarageInUse]

	Parking:SaveGarage()

	Parking:MakeInvincible(entID)
	Parking:Teleport(entID, entPos)
	Parking:ClearGarage()
	_InsideGarage = false

	Parking:FadePlayerIn(entID)
	Parking:MakeVincible(entID)

	natives.CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(0)

	game.WaitMS(_WaitTime)
	Parking:FadeScreenIn()

	Parking:DebugPrint("Exited garage ".._GarageInUse)
end

-- Fades out the game screen
function Parking:FadeScreenOut(n)
	n = n or 1000
	natives.CAM.DO_SCREEN_FADE_OUT(n)
	while natives.CAM.IS_SCREEN_FADING_OUT() do
		Wait(10)
	end
end

-- Fades in the game screen
function Parking:FadeScreenIn(n)
	n = n or 1000
	natives.CAM.DO_SCREEN_FADE_IN(n)
	while natives.CAM.IS_SCREEN_FADING_IN() do
		Wait(10)
	end
end

-- Fades out the player and vehicle
function Parking:FadePlayerOut(entID)
	natives.NETWORK.NETWORK_FADE_OUT_ENTITY(entID, true, true)
	game.WaitMS(_WaitTime)
end

-- Fades in the player and vehicle
function Parking:FadePlayerIn(entID)
	natives.NETWORK.NETWORK_FADE_IN_ENTITY(entID, true)
	game.WaitMS(_WaitTime)
end

-- Re-Enables the garage entrances after exiting
function Parking:EnableEntrance()
	if not _InDoorEnabled then
		_InDoorEnabled = true
		for n=1,_NGarages do
			if game.Distance(LocalPlayer():GetPosition(), _GarageInDoor[n]) < _DoorRadius then
				_InDoorEnabled = false
			end
		end
	end
end

function Parking:Init()
	print("----------------------------------------------")
	print("Public Parking Addon initializing ...")
	print("Initializing garages ...")
	for n=1,_NGarages do
		_GarageSpots[n] = {}
	end
-- Loads initial garages from files
	print("  Loading local garages")
	for n=1,_NGarages do
		_GarageInUse = n
		print("    --  Garage",n)
		Parking:LoadGarage()
	end
	_GarageInUse = _DefaultGarage	-- Default in case of teleport key

	while LocalPlayer():GetName() == "**Invalid**" do
		Wait(10)
	end

	for i = 1,_NGarages do
		local pos = _GarageInDoor[i]
		_GarageBlips[i] = natives.UI.ADD_BLIP_FOR_COORD(pos.x, pos.y, pos.z)
		natives.UI.SET_BLIP_SPRITE(_GarageBlips[i], BlipSpriteGarage)
		natives.UI.SET_BLIP_SCALE(_GarageBlips[i], .7)
		natives.UI.SET_BLIP_COLOUR(_GarageBlips[i], 9)
	end
	print("Initialization complete.")
	print("----------------------------------------------")
end

-- Run function is called multiple times from the main Lua
function Parking:Run()
	playerPlayerID = natives.PLAYER.GET_PLAYER_INDEX()
	playerID = natives.PLAYER.GET_PLAYER_PED(playerPlayerID)
	playerPos = natives.ENTITY.GET_ENTITY_COORDS(playerID, false)

	Parking:ShowDebugData()

	-- Draw HUD and Map accordingly
	if _InsideGarage then
		natives.UI.SET_RADAR_AS_INTERIOR_THIS_FRAME(natives.GAMEPLAY.GET_HASH_KEY("v_winningroom"), 405.45, -955.75, 0, 10)
	end

	-- Are we outside the garage?
	if not _InsideGarage then
		if _InDoorEnabled then
			-- Are we at the Garage Entrance area?
			for n=1,_NGarages do
				if game.Distance(playerPos, _GarageInDoor[n]) < _DoorRadius then
					Parking:DebugPrint("----------------------------------")
					Parking:DebugPrint("Touched Garage",n,"enter trigger ...")
					_GarageInUse = n
					Parking:EnterGarage()
				end
			end
		end
	end

	-- Are we inside the garage?
	if _InsideGarage then
		-- Are we at the Garage Exit area?
		if game.Distance(playerPos, _GarageOutDoor) < _DoorRadius then
			Parking:DebugPrint("----------------------------------")
			Parking:DebugPrint("Touched Garage", _GarageInUse, "exit trigger ...")
			Parking:ExitGarage()
		end

	-- Are we leaving the garage in a car?
		if Parking:IsInVehicle() then
			if natives.ENTITY.GET_ENTITY_SPEED(playerVehicle) > 1 then
				Parking:DebugPrint("----------------------------------")
				Parking:DebugPrint("Moving vehicle trigger ...")
				Parking:ExitGarage()
			end
		end
	end

	-- Are we pressing the Garage key?
	if IsKeyJustDown(_TeleportKey, true) then
		Parking:DebugPrint("----------------------------------")
		Parking:DebugPrint("Touched garage teleport key ...")
		if _InsideGarage then
			Parking:DebugPrint("    Teleporting out ...")
			Parking:ExitGarage()
		else
			if Parking:IsInVehicle() then
				local model = natives.ENTITY.GET_ENTITY_MODEL(playerVehicle)
				if natives.VEHICLE.IS_THIS_MODEL_A_CAR(model) or natives.VEHICLE.IS_THIS_MODEL_A_BIKE(model) or natives.VEHICLE.IS_THIS_MODEL_A_BICYCLE(model) or natives.VEHICLE.IS_THIS_MODEL_A_QUADBIKE(model) then
					Parking:DebugPrint("    Teleporting in ...")
					Parking:EnterGarage()
				else
					Parking:DebugPrint("    Can't bring this vehicle into the garage.")
				end
			else
				Parking:DebugPrint("    Teleporting in ...")
				Parking:EnterGarage()
			end
		end
	end

	-- Re-Enable (or not) the entrance doors
	Parking:EnableEntrance()

	-- Are we pressing the Redraw key?
	if IsKeyJustDown(_RedrawKey, true) then
		if _InsideGarage then
			Parking:DebugPrint("----------------------------------")
			Parking:DebugPrint("Cleaning...")
			Parking:ClearGarage()
			Parking:DebugPrint("Loading...")
			Parking:LoadGarage()
			Parking:DebugPrint("Waiting...")
			game.WaitMS(500)
			Parking:DebugPrint("Redrawing...")
			Parking:DrawGarage()
		else
			Parking:DebugPrint("Redraw only works inside garage.")
		end
	end
end

-- Run when an addon if (properly) unloaded
function Parking:Unload()
	print("Removing garage blips ...")
	for i = 1,_NGarages do
		Parking:DeleteBlip(_GarageBlips[i])
	end
end

-- This line must match the module folder name
export = Parking
