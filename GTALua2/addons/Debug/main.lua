-- Basic mod to show game's debugging information

-- These two lines must match the module folder name
Debug = {}
Debug.__index = Debug

-- ScriptInfo table must exist and define Name, Author and Version
Debug.ScriptInfo = {
	Name = "Debug",	-- Must match the module name
	Author = "Mockba the Borg",
	Version = "1.0"
}

-- Variables for Debug control
local ToggleKey = KEY_F9
local ShowDebug = false

-- Variables for ray casting
local _IntersectFlags = -1	-- Flags for casting rays
local _IntersectValue = 7
local _RayDistance = 5000
local _FontSize = .4
local _DebugFontSize = .2

-- Functions must match module folder name
-- Init function is called once from the main Lua
function Debug:Init()
	print("Debug v1.0 - by Mockba the Borg")
end

-- Extra functions
function Debug:DecorInt(veh, decor, decorType)
	if natives.DECORATOR.DECOR_EXIST_ON(veh.ID, decor) then
		return natives.DECORATOR.DECOR_GET_INT(veh.ID, decor)
	else
		return "no exist"
	end
end

-- Run function is called multiple times from the main Lua
function Debug:Run()
	if ShowDebug then
		natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlDropWeapon, true) -- Prevents dropping weapon
		-- Shows Debug Info
		local Myself = LocalPlayer()
		local MyPos = Myself:GetPosition()
		local MyHdg = Myself:GetHeading()
		local debugtext = "Debugging"
		if natives.NETWORK.NETWORK_IS_SESSION_STARTED() then
			debugtext = debugtext.." Online"
		end
		if natives.NETWORK.NETWORK_IS_HOST() then
			debugtext = debugtext.." (Host)"
		end
		if _Invisible then
			debugtext = debugtext.." (Invis.)"
		end
		ui.DrawTextBlock(debugtext, .01, .01, FontChaletComprimeCologne, _FontSize, COLOR_RED, BLINK)
		ui.DrawTextBlock("Decor ID: "..natives.NETWORK._0xBC1D768F2F5D6C05(Myself.PlayerID),nil,nil,nil,nil,COLOR_WHITE,NOBLINK)
		ui.DrawTextBlock(string.format("x:%4.2f y:%4.2f z:%4.2f h:%3.2f",MyPos.x,MyPos.y,MyPos.z,MyHdg))
		if _CheatMode then
			ui.DrawTextBlock("Cheat mode")
		end
		if _VehicleMode then
			ui.DrawTextBlock("Vehicle mode")
		end

		local entityHit,pointHit = game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue)
		if not pointHit then
			pointHit = game.GetCoordsInFrontOfCam(_RayDistance)
		end
		if pointHit then
			ui.Draw3DLine(MyPos, pointHit, COLOR_PURPLE)
			if not _CheatMode then
				ui.Draw3DPoint(pointHit, .05, COLOR_RED)
			end
		end

		if entityHit then
			local entPos = entityHit:GetPosition()
			if entPos.x ~= 0 then
				local textPos = game.WorldToScreen(pointHit)
				if textPos then
					local text = entityHit._type..": "..entityHit.ID
					if entityHit:IsVehicle() then
						text = text.." ("..natives.NETWORK.VEH_TO_NET(entityHit.ID)..")"
					end
					text = text.."  "..entityHit:GetHealth().."/"..entityHit:GetMaxHealth()
					if entityHit:IsDead() then
						text = text.." (Dead)"
					end
					ui.DrawTextBlock(text, textPos.x, textPos.y-.20, FontChaletLondon, _DebugFontSize, COLOR_WHITE, NOBLINK)
					if entityHit:IsPed() or entityHit:IsObject() then
						ui.DrawTextBlock("Model: 0x"..string.format("%04x", entityHit:GetModel()))
					end
					if entityHit:IsVehicle() then
						local modelName = entityHit:GetModelName()
						if not natives.VEHICLE.IS_VEHICLE_DRIVEABLE(entityHit.ID, true) then
							modelName = modelName.." (Undriveable)"
						end
						if natives.VEHICLE.IS_VEHICLE_STOLEN(entityHit.ID) then
							modelName = modelName.." (Stolen)"
						end
						ui.DrawTextBlock(modelName)
						local nPass = entityHit:GetNumberOfPassengers()
						if entityHit:GetPedInSeat(VehicleSeatDriver) then
							nPass = nPass+1
						end
						ui.DrawTextBlock(nPass > 0 and "Driver + "..(nPass-1) or "Empty")
						ui.DrawTextBlock("Player_Vehicle: "..Debug:DecorInt(entityHit,"Player_Vehicle", 3))
						ui.DrawTextBlock("PV_Slot: "..Debug:DecorInt(entityHit,"PV_Slot", 3))
						ui.DrawTextBlock("Previous_Owner: "..Debug:DecorInt(entityHit,"Previous_Owner", 3))
						ui.DrawTextBlock("MPBitset: "..Debug:DecorInt(entityHit,"MPBitset", 3))
						ui.DrawTextBlock("Modded_By: "..Debug:DecorInt(entityHit,"Veh_Modded_By_Player", 3))
--						ui.DrawTextBlock("NotAllowSavedVeh: "..Debug:DecorInt(entityHit,"Not_Allow_As_Saved_Veh", 3))
--						ui.DrawTextBlock("MissionType: "..Debug:DecorInt(entityHit,"MissionType", 3))
--						ui.DrawTextBlock("RespawnVeh: "..Debug:DecorInt(entityHit,"RespawnVeh", 3))
--						ui.DrawTextBlock("DeLuxeVeh: "..Debug:DecorInt(entityHit,"LUXE_VEH_INSTANCE_ID", 3))
						ui.DrawTextBlock("Stolen: "..(natives.VEHICLE.IS_VEHICLE_STOLEN(entityHit.ID) and "Yes" or "No"))
					end
					if entityHit:IsMissionEntity() then
						ui.DrawTextBlock("Mission Entity")
					end
					local pos = entityHit:GetPosition()
					local hdg = entityHit:GetHeading()
					if entityHit:IsPed() then
						local pedType = natives.PED.GET_PED_TYPE(entityHit.ID)
						ui.DrawTextBlock("Type: "..pedType)
						local bonePos = entityHit:GetBonePosition(entityHit:GetBoneIndex("BONETAG_HEAD"))
						local size = .12
						local zoffset = .07
						ui.Draw3DBox({ x=bonePos.x-size, y=bonePos.y-size, z=bonePos.z-size+zoffset },
									{ x=bonePos.x+size, y=bonePos.y+size, z=bonePos.z+size+zoffset }, COLOR_YELLOW_50, false, hdg)
					end
					ui.DrawTextBlock(string.format("x:%4.2f y:%4.2f z:%4.2f h:%4.2f",pos.x,pos.y,pos.z,hdg))
				end
			end
		end
		-- Shows Debug Handlers
		ui.Draw3DPoint(MyPos, 1)
	end
	if IsKeyJustDown(ToggleKey) then
		ShowDebug = not ShowDebug
		if ShowDebug then
			ui.MapMessage("Debug info enabled.")
		else
			ui.MapMessage("Debug info disabled.")
		end
	end
end

-- Run when an addon if (properly) unloaded
function Debug:Unload()

end

-- This line must match the module folder name
export = Debug
