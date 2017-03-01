-- Cheating mod ... not cool man, not cool!!!

-- These two lines must match the module folder name
CheatMod = {}
CheatMod.__index = CheatMod

-- ScriptInfo table must exist and define Name, Author and Version
CheatMod.ScriptInfo = {
	Name = "CheatMod",	-- Must match the module folder name
	Author = "Mockba the Borg",
	Version = "1.0"
}

-- Global variable to signal Debug that we're enabled
_CheatMode = false

-- Variables for Cheating
local ToggleKey = KEY_F10

local _KeyDeleteGun = KEY_SUBTRACT
local _KeyTakeCar = KEY_DECIMAL

-- Variables for ray casting
local _IntersectFlags = -1	-- Flags for casting rays
local _IntersectValue = 7
local _RayDistance = 5000

-- Select weapons to top-up
local _Weapons = {
-- Pistol
	[0x1b06d571] = {0xed265a1c},
-- Combat Pistol
	[0x5ef9fec4] = {0xd67b4f2d},
-- AP Pistol
	[0x22d8fe39] = {0x249a17d5},
-- Micro SMG
	[0x13532244] = {0x10e6ba2b, 0x9d2fbf29},
-- Assault Shotgun
	[0xe284c527] = {0x86bd7f72, 0x0c164f53},
-- Heavy Shotgun
	[0x3aabbbaa] = {0x971cf6fd, 0x0c164f53, 0x88c7da53},
-- Carbine Rifle
	[0x83bf0278] = {0x91109691, 0x0c164f53, 0xba62e935},
-- Advanced Rifle
	[0xaf113f99] = {0x8ec1c979, 0xaa2c45b4},
-- Advanced Carbine
	[0xc0a3098d] = {0x7c8bd10e, 0xa0d89c42, 0x0c164f53, 0x6b59aeaa},
-- Sniper Rifle
	[0x05fc3c11] = {0xa73d4664, 0xbc54da77},
-- Heavy Sniper
	[0x0c472fe2] = {0xd2443ddc, 0xbc54da77},
-- Machine Gun
	[0x7fd62962] = {0xd6c59cd6, 0x0c164f53, 0xa0d89c42},
-- Parachute
	[0xFBAB5776] = {},
-- Grenade
	[0x93E220BD] = {},
-- Homing Launcher
	[0x63AB0442] = {},
-- Minigun
	[0x42BF8A85] = {},
-- Proximity Mine
	[0xAB564B93] = {},
-- RPG
	[0xB1CA77B1] = {},
-- Sticky Bomb
	[0x2C3731D9] = {}
}

-- Functions must match module folder name

-- Init function is called once from the main Lua
function CheatMod:Init()
	print("CheatMod v1.0 - by Mockba the Borg")
end

-- Run function is called multiple times from the main Lua
function CheatMod:Run()
	-- Runtime code goes here
	if _CheatMode then
		natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlDropAmmo, true) -- Prevents dropping ammo
		CheatMod:Process()
	end
	if IsKeyJustDown(ToggleKey) then
		_CheatMode = not _CheatMode
		if _CheatMode then
			ui.MapMessage("~g~Cheat mode enabled.")
		else
			ui.MapMessage("~r~Cheat mode disabled.")
		end
	end
end

function CheatMod:Process()

	ui.ShowHudComponent(HudComponentReticle)	

-- Owner of bullet (if Aiming = player)
	local bulletOwner, bulletPower, bulletWeapon
	if natives.CONTROLS.IS_CONTROL_PRESSED(0, ControlAim) then
		bulletOwner = LocalPlayer().ID
		bulletPower = 50
		bulletWeapon = natives.WEAPON.GET_SELECTED_PED_WEAPON(LocalPlayer().ID)
		if bulletWeapon == WEAPON_UNARMED then
			bulletWeapon = WEAPON_PISTOL50
		end
	else
		bulletOwner = -1
		bulletPower = 50
		bulletWeapon = WEAPON_SMG
	end

-- Take car
	if IsKeyJustDown(_KeyTakeCar, true) then
		local ent = select(1, game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue))
		if ent then
			print("Taking car...")
			if ent:IsVehicle() then
				if natives.NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent.ID) then
					print("Has control...")
				else
					print("Waiting for control...")
					local count = 500
					while not natives.NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent.ID) and count>0 do
						natives.NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent.ID)
						Wait(10)
						count=count-1
					end
				end
				local PlayerID = LocalPlayer().PlayerID
				local PlayerName = natives.PLAYER.GET_PLAYER_NAME(PlayerID)
--
				ent:SetNotNeeded()
				if not ent:IsCar() and not ent:IsBike() then
					if not natives.VEHICLE.IS_VEHICLE_SEAT_FREE(ent.ID, -1) then
						local ped = ent:GetPedInSeat(-1)
						print("Removing driver...",ped.ID)
						ped:SetMissionEntity()
						ped:Delete()
					end
				end
				natives.ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent.ID, false, true)
				natives.VEHICLE.SET_VEHICLE_ENGINE_ON(ent.ID, true, true, true)
				natives.VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(ent.ID, false)
				natives.VEHICLE.SET_VEHICLE_DOORS_LOCKED(ent.ID, 0)
				natives.VEHICLE.SET_VEHICLE_IS_STOLEN(ent.ID, false)
				natives.ENTITY.SET_ENTITY_INVINCIBLE(ent.ID, false)
				natives.ENTITY.SET_ENTITY_PROOFS(ent.ID, false, false, false, false, false, false, false, false)
				if natives.VEHICLE.GET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(ent.ID, PlayerID) then
					natives.VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(ent.ID, PlayerID, false)
				end
				natives.VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(ent.ID, true)
				natives.VEHICLE.SET_VEHICLE_NEEDS_TO_BE_HOTWIRED(ent.ID, false)
				natives.VEHICLE.SET_VEHICLE_HANDBRAKE(ent.ID, false)
				natives.VEHICLE.SET_VEHICLE_IS_WANTED(ent.ID, false)
				natives.VEHICLE.SET_PLAYERS_LAST_VEHICLE(ent.ID)
				natives.VEHICLE.SET_VEHICLE_CAN_BE_USED_BY_FLEEING_PEDS(ent.ID, false)
				natives.VEHICLE.SET_VEHICLE_UNDRIVEABLE(ent.ID, false)
				natives.VEHICLE._0xE851E480B814D4BA(ent.ID, true)
				natives.VEHICLE._0x3441CAD2F2231923(ent.ID, false)
				natives.VEHICLE._0xDBC631F109350B8C(ent.ID, false)
				natives.VEHICLE._0x2311DD7159F00582(ent.ID, false)
--	
				natives.DECORATOR.DECOR_REMOVE(ent.ID, "Player_Vehicle")
				natives.DECORATOR.DECOR_REMOVE(ent.ID, "MPBitset")
				natives.DECORATOR.DECOR_REMOVE(ent.ID, "Veh_Modded_By_Player")

				natives.DECORATOR.DECOR_SET_INT(ent.ID, "Player_Vehicle", natives.NETWORK._NETWORK_HASH_FROM_PLAYER_HANDLE(PlayerID))
				natives.DECORATOR.DECOR_SET_INT(ent.ID, "MPBitset", _MPBitset)
				if not natives.DECORATOR.DECOR_EXIST_ON(ent.ID, "PV_Slot") then
					natives.DECORATOR.DECOR_SET_INT(ent.ID, "PV_Slot", 0)
				end
				if not natives.DECORATOR.DECOR_EXIST_ON(ent.ID, "Previous_Owner") then
					natives.DECORATOR.DECOR_SET_INT(ent.ID, "Previous_Owner", 0)
				end
				natives.DECORATOR.DECOR_SET_INT(ent.ID, "Veh_Modded_By_Player", natives.GAMEPLAY.GET_HASH_KEY(PlayerName))

				if ent:IsCar() or ent:IsBike() or ent:IsQuadbike() then
					natives.VEHICLE.SET_VEHICLE_ALARM(ent.ID, false)
					natives.AI.TASK_ENTER_VEHICLE(LocalPlayer().ID, ent.ID, 10000, VehicleSeatDriver, 1.0, 9, 0)
					local count=500
					while not LocalPlayer():IsInVehicle() and count>0 do
						Wait(10)
						count=count-1
					end
				end
				LocalPlayer():SetIntoVehicle(ent.ID, -1)
				ent:SetNotNeeded()
				ent:SetMissionEntity()
				ui.MapMessage("~r~Vehicle has been stolen.")
			else
				print("Not a vehicle.")
			end
			print("done.")
		end
	end

-- Fix/Clean/Flip Up vehicle
	if natives.CONTROLS.IS_CONTROL_JUST_PRESSED(0, ControlSelectWeaponAutoRifle) then -- Default: *8
		local veh
		if LocalPlayer():IsInVehicle() then
			veh = LocalPlayer():GetVehicle()
		else
			veh = select(1, game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue))
			if not veh:IsVehicle() then
				veh = nil
			end
		end
		if veh then
			veh:SetDirtLevel(0)
			veh:Fix()
			if veh:IsBike() or veh:IsCar() then
				veh:SetOnGround()
			end
			natives.FIRE.STOP_ENTITY_FIRE(veh.ID)
			natives.VEHICLE.SET_VEHICLE_IS_CONSIDERED_BY_PLAYER(veh.ID, true)
		end
		return
	end

-- Steal other vehicle's colors
	if natives.CONTROLS.IS_CONTROL_JUST_PRESSED(0, ControlSelectWeaponSniper) then -- Default: (9
		local veh
		if LocalPlayer():IsInVehicle() then
			veh = select(1, game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue))
			if veh then
				if veh:IsVehicle() then
					local pricolor, seccolor = veh:GetColours()
					local prlcolor, whlcolor = veh:GetExtraColours()
					local platetype = veh:GetPlateType()
					local windowtint = natives.VEHICLE.GET_VEHICLE_WINDOW_TINT(veh.ID)
					veh = LocalPlayer():GetVehicle()
					veh:SetColours(pricolor, seccolor)
					veh:SetExtraColours(prlcolor, whlcolor)
					veh:SetPlateType(platetype)
					natives.VEHICLE.SET_VEHICLE_WINDOW_TINT(veh.ID, windowtint)
				end
			end
		else
			print("Not in a vehicle.")
		end
	end

-- Delete gun
	if IsKeyJustDown(_KeyDeleteGun, true) then
		local ent = select(1, game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue))
		if ent then
			if ent:IsObject() or ent:IsVehicle() or ent:IsPed() then
				print("Deleting...", ent.ID)
				if natives.NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent.ID) then
					print("Has control...")
				else
					print("Waiting for control...")
					local count = 500
					while not natives.NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent.ID) and count>0 do
						natives.NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent.ID)
						Wait(10)
						count=count-1
					end
				end
				local blip = ent:GetBlip()
				if blip then
					print("Deleting Blip...")
					blip:Delete()
				end
				if ent:Exists() then
					print("Trying as Mission Entity...")
					ent:SetMissionEntity()
					ent:Delete()
				end
				if ent:Exists() then
					print("Trying as Not Mission Entity...")
					ent:SetMissionEntity(false)
					ent:Delete()
				end
				if ent:Exists() then
					print("Trying as Not Needed...")
					ent:SetNotNeeded()
					ent:Delete()
				end
				if ent:Exists() then
					print("Trying to clean up area...")
					local pos = ent:GetPosition()
					natives.GAMEPLAY.CLEAR_AREA(pos.x, pos.y, pos.z, 1, false, false, false, false)
				end
				if ent:Exists() then
					print("Can't delete, sending away...")
					ent:SetPosition(500, 7500, 5000)
					game.WaitMS(10)
					ent:SetPosition(500, 7500, 5000)
					game.WaitMS(10)
					ent:SetPosition(500, 7500, 5000)
				end
			else
				print("Invalid Entity, can't delete.")
			end
		end
		print("done.")
	end

-- Top me Up (give less suspicious weapons/ammo) (Shift to remove all)
	natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlLookBehind, true)
	if natives.CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(0, ControlLookBehind) then
		local plr = LocalPlayer()
		plr:RemoveAllWeapons()
		local ammo = Cvar:new()
		if not IsKeyDown(KEY_SHIFT) then
			for k, _Components in pairs(_Weapons) do
				natives.WEAPON.GET_MAX_AMMO(plr.ID, k, ammo)
				plr:GiveWeapon(k, ammo:getInt())
				for k2, comp in pairs(_Components) do
					plr:GiveWeaponComponent(k, comp)
				end
			end
		end
	end

-- Heart attack gun
	natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlVehicleDuck, true)
	if natives.CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(0, ControlVehicleDuck) then
		local ped = game.GetTargetPed(_RayDistance, _IntersectFlags, LocalPlayer().ID)
		if ped then
			ped:SetNotNeeded()
			natives.PED.APPLY_DAMAGE_TO_PED(ped.ID, 1000, false)
		end
	end

-- Drone strike gun
	natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlThrowGrenade, true)
	if natives.CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(0, ControlThrowGrenade) then
		local tgt = select(2, game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue))
		if tgt then
			local org = {}
			org.x = tgt.x+.02
			org.y = tgt.y
			org.z = tgt.z+50
			game.ShootBulletBetweenCoords(org, tgt, WEAPON_AIRSTRIKE_ROCKET, 100, 500, bulletOwner)
		end
	end

-- AC-130 strike gun
	natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlNextCamera, true)
	if natives.CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(0, ControlNextCamera) then
		local tgt = select(2, game.GetRaycastTarget(_RayDistance, _IntersectFlags, LocalPlayer().ID, _IntersectValue))
		if tgt then
			local org = {}
			org.x = tgt.x+.02
			org.y = tgt.y
			org.z = tgt.z+50
			game.ShootBulletBetweenCoords(org, tgt, VEHICLE_WEAPON_PLAYER_BULLET, 100, 500, bulletOwner)
			game.ShootBulletBetweenCoords(org, tgt, VEHICLE_WEAPON_PLAYER_LAZER, 100, 500, bulletOwner)
		end
	end
end

-- Run when an addon if (properly) unloaded
function CheatMod:Unload()

end

-- This line must match the module folder name
export = CheatMod
