-- Simple Auto Pilot for hovering and ground avoidance

-- These two lines must match the module folder name
AutoPilot = {}
AutoPilot.__index = AutoPilot

-- ScriptInfo table must exist and define Name, Author and Version
AutoPilot.ScriptInfo = {
	Name = "AutoPilot",	-- Must match the module name
	Author = "Mockba the Borg",
	Version = "1.0a"
}

-- Defines
local AP_Off = 0
local AP_Altitude = 1
local AP_Avoidance = 2
local AP_Hover = 3

-- Mode texts
local Modes = {
	[0] = "~r~AutoPilot Off",
	[1] = "~g~Altitude Hold",
	[2] = "~g~Ground Avoidance",
	[3] = "~b~Hover Mode"
}

local ToggleKey = KEY_F12
local AutoPilotMode = AP_Off
local MaxModes = 3

local _Altitude = 0
local _PositionX = 0
local _PositionY = 0
local _MinAltitude = 5

-- Functions must match module folder name
-- Init function is called once from the main Lua
function AutoPilot:Init()
	print("AutoPilot v1.0 - by Mockba the Borg")
end

-- Run function is called multiple times from the main Lua
function AutoPilot:Run()
	if AutoPilotMode ~= AP_Off then
		local plr = LocalPlayer()
		if plr:IsDead() then
			AutoPilotMode = AP_Off
			ui.message("~r~Autopilot Reset")
			return
		end
		local veh = plr:GetVehicle()
		if not veh then
			AutoPilotMode = AP_Off
			ui.message("~r~Autopilot Reset")
			return
		end		
		local playerPos = plr:GetPosition()
		local posX = tonumber(string.format("%.4f", playerPos.x))
		local posY = tonumber(string.format("%.4f", playerPos.y))
		local posZ = tonumber(string.format("%.4f", playerPos.z))
		
		local vec = natives.ENTITY.GET_ENTITY_FORWARD_VECTOR(plr.ID)
		local disp = natives.ENTITY.GET_ENTITY_SPEED(veh.ID)/2
		local org = { x=posX+(vec.x*disp), y=posY+(vec.y*disp), z=posZ+(vec.z*disp) }

--		ui.Draw3DPoint(org)
--		ui.Draw3DPoint({x=_PositionX, y=_PositionY, z=_Altitude})
		playerPos = org
		local posX = playerPos.x
		local posY = playerPos.y
		local posZ = playerPos.z

		local adjX=0
		local adjY=0
		local adjZ=0
		-- Keep sea level altitude
		if AutoPilotMode == AP_Altitude then
			if posZ < _Altitude then
				adjZ=(1-(posZ/_Altitude))*1
			end	
		end
		-- Keep altitude from ground level
		if AutoPilotMode == AP_Avoidance then
			local m_groundZ = Cvar:new()
			if natives.GAMEPLAY.GET_GROUND_Z_FOR_3D_COORD(posX, posY, posZ, m_groundZ, true) then
				groundZ = m_groundZ:getFloat()
				if groundZ < 0 then
					groundZ = 0
				end
				local ref = playerPos.z - groundZ
				if ref < _Altitude then
					adjZ=(1-(ref/_Altitude))*1
				end	
			else
				ui.MapMessage("Could not keep Ground Avoidance.")
				AutoPilotMode = AP_Altitude
			end
		end
		-- Hover mode (heli only)
		if AutoPilotMode == AP_Hover then
			local minForce = .01
			local maxForce = .08
			local divisor = 4
			local slack = 1
			if natives.SYSTEM.VDIST(posX, posY, posZ, _PositionX, _PositionY, _Altitude) > slack then
				adjX = (_PositionX-posX)/divisor
				adjY = (_PositionY-posY)/divisor
				adjZ = (_Altitude-posZ)/divisor
				if math.abs(adjX)>maxForce then
					adjX=adjX/math.abs(adjX)*maxForce
				end
				if math.abs(adjY)>maxForce then
					adjY=adjY/math.abs(adjY)*maxForce
				end
				if math.abs(adjZ)>maxForce then
					adjZ=adjZ/math.abs(adjZ)*maxForce
				end
			else
				adjX = (_PositionX-posX)/divisor
				adjY = (_PositionY-posY)/divisor
				adjZ = (_Altitude-posZ)/divisor
				if math.abs(adjX)>maxForce then
					adjX=adjX/math.abs(adjX)*minForce
				end
				if math.abs(adjY)>maxForce then
					adjY=adjY/math.abs(adjY)*minForce
				end
				if math.abs(adjZ)>maxForce then
					adjZ=adjZ/math.abs(adjZ)*minForce
				end
			end
		end
		-- Makes the position adjustments
		if adjX~=0 or adjY~=0 or adjZ~=0 then
			natives.ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(LocalPlayer():GetVehicle().ID, 1, adjX, adjY, adjZ, true, false, true, true)
		end				
	end
	if IsKeyJustDown(ToggleKey) then
		plr = LocalPlayer()
		local veh
		if plr:IsInVehicle() then
			veh = plr:GetVehicle()
			if veh:IsHeli() or veh:IsPlane() then
				if IsKeyDown(KEY_SHIFT) then
					AutoPilotMode = AP_Off
				else
					AutoPilotMode = AutoPilotMode + 1
					if veh:IsPlane() then
						if AutoPilotMode == MaxModes then
							AutoPilotMode = AP_Off
						end
					else
						if AutoPilotMode > MaxModes then
							AutoPilotMode = AP_Off
						end
					end
					local playerPos = LocalPlayer():GetPosition()
					local posX = tonumber(string.format("%.4f", playerPos.x))
					local posY = tonumber(string.format("%.4f", playerPos.y))
					local posZ = tonumber(string.format("%.4f", playerPos.z))
					-- Set Altitude mode
					if AutoPilotMode == AP_Altitude then
						_Altitude = posZ
						if _Altitude < _MinAltitude then
							_Altitude = _MinAltitude
						end
					end
					-- Set Ground Avoidance mode
					if AutoPilotMode == AP_Avoidance then
						local m_groundZ = Cvar:new()
						if natives.GAMEPLAY.GET_GROUND_Z_FOR_3D_COORD(posX, posY, posZ, m_groundZ, true) then
							groundZ = m_groundZ:getFloat()
							if groundZ < 0 then
								groundZ = 0
							end
							_Altitude = posZ - groundZ
							if _Altitude < _MinAltitude then
								_Altitude = _MinAltitude
							end
						else
							_AutoPilotMode = AP_Off
							ui.MapMessage("Could not enable Ground Avoidance.")
						end
					end
					-- Set Hover mode (Heli only)
					if AutoPilotMode == AP_Hover then
						_Altitude = posZ
						if _Altitude < _MinAltitude then
							_Altitude = _MinAltitude
						end
						_PositionX = posX
						_PositionY = posY
					end
				end
			else
				ui.MapMessage("~r~Invalid Vehicle.")
				AutoPilotMode = AP_Off
			end
		else
			ui.MapMessage("~r~Not in vehicle.")
			AutoPilotMode = AP_Off
		end
		ui.MapMessage(Modes[AutoPilotMode])
	end
end

-- Run when an addon if (properly) unloaded
function AutoPilot:Unload()

end

-- This line must match the module folder name
export = AutoPilot
