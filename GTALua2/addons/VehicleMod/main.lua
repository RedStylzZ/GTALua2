-- Vehicle modification (and spawning) addon

-- These two lines must match the module folder name
VehicleMod = {}
VehicleMod.__index = VehicleMod

-- ScriptInfo table must exist and define Name, Author and Version
VehicleMod.ScriptInfo = {
	Name = "VehicleMod",	-- Must match the module folder name
	Author = "Mockba the Borg",
	Version = "1.0a"
}

-- Global variable to signal Debug that we're enabled
_VehicleMode = false

-- Variables for Vehicle Modification
local ToggleKey = KEY_F11
local _FontSize = .4
local _KeyAddVehicle = KEY_ADD
local _KeyUpgradeVehicle = KEY_NUMPAD5
local _KeyEnterValue = KEY_RETURN
local _KeyVehicleInfo = KEY_NUMPAD3
local _KeyVehicleMods = KEY_NUMPAD1
local _KeyModTypeDown = KEY_NUMPAD2
local _KeyModTypeUp = KEY_NUMPAD8
local _KeyModWheelRight = KEY_NUMPAD9
local _KeyModWheelLeft = KEY_NUMPAD7
local _KeyModExtraRight = KEY_NUMPAD9
local _KeyModExtraLeft = KEY_NUMPAD7
local _KeyModValueRight = KEY_NUMPAD6
local _KeyModValueLeft = KEY_NUMPAD4
local _KeyTakeCar = KEY_DECIMAL

-- Variables for the Vehicle modification module
local _ModX = .01
local _ModY = .12
-- All boolean mods must be defined here
-- Enums for custom mods
local _Mod_PRI_COLOR = -10
local _Mod_SEC_COLOR = -9
local _Mod_PRL_COLOR = -8
local _Mod_WHL_COLOR = -7
local _Mod_ACT_COLOR = -6
local _Mod_TRM_COLOR = -5
local _Mod_Livery    = -4
local _Mod_WND_TINT  = -3
local _Mod_PLT_TYPE  = -2
local _Mod_VEH_EXTRA = -1
-- Mod name table
local _Mod = {}
_Mod[_Mod_PRI_COLOR] = "Primary color"
_Mod[_Mod_SEC_COLOR] = "Secondary color"
_Mod[_Mod_PRL_COLOR] = "Pearlescent color"
_Mod[_Mod_WHL_COLOR] = "Wheel color"
_Mod[_Mod_ACT_COLOR] = "Accent color"
_Mod[_Mod_TRM_COLOR] = "Trim color"
_Mod[_Mod_Livery] = "Livery"
_Mod[_Mod_WND_TINT] = "Window tint"
_Mod[_Mod_PLT_TYPE] = "Plate type"
_Mod[_Mod_VEH_EXTRA] = "Vehicle Extra"
_Mod[11] = "Engine"
_Mod[12] = "Brakes"
_Mod[13] = "Transmission"
_Mod[14] = "Horn"
_Mod[15] = "Suspension"
_Mod[16] = "Armor"
_Mod[23] = "Front Wheels"
_Mod[24] = "Back Wheels"
-- Min and max values for mods
local _ModLimits = {}
_ModLimits[_Mod_PRI_COLOR] = {vtype="value", vmin=0, vmax=159}
_ModLimits[_Mod_SEC_COLOR] = {vtype="value", vmin=0, vmax=159}
_ModLimits[_Mod_PRL_COLOR] = {vtype="value", vmin=0, vmax=159}
_ModLimits[_Mod_WHL_COLOR] = {vtype="value", vmin=0, vmax=159}
_ModLimits[_Mod_ACT_COLOR] = {vtype="value", vmin=0, vmax=159}
_ModLimits[_Mod_TRM_COLOR] = {vtype="value", vmin=0, vmax=159}
_ModLimits[_Mod_WND_TINT] = {vtype="value", vmin=-1, vmax=6}
_ModLimits[_Mod_PLT_TYPE] = {vtype="value", vmin=0, vmax=5}
_ModLimits[_Mod_VEH_EXTRA] = {vtype="boolean", vmin=0, vmax=1}
-- All boolean mods must be defined here
_Mod[18] = "Turbo"
_Mod[20] = "Tire smoke"
_Mod[21] = "Neons"		-- 21 is Unknown ... will use for Neons
_Mod[22] = "Xenon"
_ModLimits[18] = {vtype="boolean", vmin=0, vmax=1}
_ModLimits[20] = {vtype="boolean", vmin=0, vmax=1}
_ModLimits[21] = {vtype="boolean", vmin=0, vmax=1}
_ModLimits[22] = {vtype="boolean", vmin=0, vmax=1}
local _ModType = {}
_ModType[_Mod_WND_TINT] = {}
_ModType[_Mod_WND_TINT][0] = "None"
_ModType[_Mod_WND_TINT][1] = "Pure Black"
_ModType[_Mod_WND_TINT][2] = "Dark Smoke"
_ModType[_Mod_WND_TINT][3] = "Light Smoke"
_ModType[_Mod_WND_TINT][4] = "Stock"
_ModType[_Mod_WND_TINT][5] = "Limo"
_ModType[_Mod_WND_TINT][6] = "Green"
_ModType[_Mod_PLT_TYPE] = {}
_ModType[_Mod_PLT_TYPE][0] = "Blue On White"
_ModType[_Mod_PLT_TYPE][1] = "Yellow On Black"
_ModType[_Mod_PLT_TYPE][2] = "Yellow On Blue"
_ModType[_Mod_PLT_TYPE][3] = "Blue On White 2"
_ModType[_Mod_PLT_TYPE][4] = "Blue On White 3"
_ModType[_Mod_PLT_TYPE][5] = "North Yankton"
_ModType[11] = {}
_ModType[11][0] = "EMS Upgrade, Level 1"
_ModType[11][1] = "EMS Upgrade, Level 2"
_ModType[11][2] = "EMS Upgrade, Level 3"
_ModType[11][3] = "EMS Upgrade, Level 4"
_ModType[12] = {}
_ModType[12][0] = "Street"
_ModType[12][1] = "Sport"
_ModType[12][2] = "Race"
_ModType[13] = {}
_ModType[13][0] = "Street"
_ModType[13][1] = "Sport"
_ModType[13][2] = "Race"
_ModType[14] = {}
_ModType[14][0] = "Truck Horn"
_ModType[14][1] = "Cop Horn"
_ModType[14][2] = "Clown Horn"
_ModType[14][8] = "Sad Trombone"
_ModType[14][3] = "Musical Horn 1"
_ModType[14][4] = "Musical Horn 2"
_ModType[14][5] = "Musical Horn 3"
_ModType[14][6] = "Musical Horn 4"
_ModType[14][7] = "Musical Horn 5"
_ModType[14][9] = "Classical Horn 1"
_ModType[14][10] = "Classical Horn 2"
_ModType[14][11] = "Classical Horn 3"
_ModType[14][12] = "Classical Horn 4"
_ModType[14][13] = "Classical Horn 5"
_ModType[14][14] = "Classical Horn 6"
_ModType[14][15] = "Classical Horn 7"
_ModType[14][33] = "Classical Horn 8"
_ModType[14][32] = "Classical Horn Loop 1"
_ModType[14][34] = "Classical Horn Loop 2"
_ModType[14][16] = "Scale - Do"
_ModType[14][17] = "Scale - Re"
_ModType[14][18] = "Scale - Mi"
_ModType[14][19] = "Scale - Fa"
_ModType[14][20] = "Scale - Sol"
_ModType[14][21] = "Scale - La"
_ModType[14][22] = "Scale - Ti"
_ModType[14][23] = "Scale - Do (High)"
_ModType[14][24] = "Jazz Horn 1"
_ModType[14][25] = "Jazz Horn 2"
_ModType[14][26] = "Jazz Horn 3"
_ModType[14][27] = "Jazz Horn Loop"
_ModType[14][28] = "Star Spangled Banner 1"
_ModType[14][29] = "Star Spangled Banner 2"
_ModType[14][30] = "Star Spangled Banner 3"
_ModType[14][31] = "Star Spangled Banner 4"
_ModType[14][38] = "Halloween Loop 1"
_ModType[14][40] = "Halloween Loop 2"
_ModType[14][42] = "San Andreas"
_ModType[14][44] = "Liberty City"
_ModType[14][35] = "Classical Horn Loop 1 (Non Loop)"
_ModType[14][37] = "Classical Horn Loop 2 (Non Loop)"
_ModType[14][36] = "Classical Horn 8 (Start)"
_ModType[14][39] = "Halloween Loop 1 (Non Loop)"
_ModType[14][41] = "Halloween Loop 2 (Non Loop)"
_ModType[14][43] = "San Andreas (Non Loop)"
_ModType[14][45] = "Liberty City (Non Loop)"
_ModType[14][46] = "Xmas 1"
_ModType[14][47] = "Xmas 2"
_ModType[15] = {}
_ModType[15][0] = "Lowered"
_ModType[15][1] = "Street"
_ModType[15][2] = "Sport"
_ModType[15][3] = "Competition"
_ModType[16] = {}
_ModType[16][-1] = "None"
_ModType[16][0] = "Armor Upgrade 20%"
_ModType[16][1] = "Armor Upgrade 40%"
_ModType[16][2] = "Armor Upgrade 60%"
_ModType[16][3] = "Armor Upgrade 80%"
_ModType[16][4] = "Armor Upgrade 100%"

local _VehicleModKit = nil
local _MinVehicleModID = _Mod_PRI_COLOR
local _MaxVehicleModID = 48
local _VehicleModID = nil
local _MinVehicleModValue = 0
local _MaxVehicleModValue = 0
local _VehicleModValue = nil
local _VehicleWType = nil
local _VehicleExtra = 1
local _MinVehicleExtras = 1
local _MaxVehicleExtras = 12

-- Default full upgrade values
local _FullUpgrade = 0
local _UpgradeHorn = 10
local _UpgradePlateText = "THE BORG"
local _UpgradePlateType = 1
local _UpgradeWindowTint = 1
local _UpgradeWheelType = 7
local _UpgradeCarWheelNumber = 6
local _UpgradeBikeWheelNumber = 5
local _UpgradePriColor = 12
local _UpgradeSecColor = 12
local _UpgradePrlColor = 38
local _UpgradeWhlColor = 12
local _UpgradeTrmColor = 38
local _UpgradeAccColor = 38
local _MPBitset = 8

-- Wheel types
local _ModW = {}
_ModW[0] = "Sport"
_ModW[1] = "Muscle"
_ModW[2] = "Lowrider"
_ModW[3] = "SUV"
_ModW[4] = "Offroad"
_ModW[5] = "Tuner"
_ModW[6] = "Motorcycle"
_ModW[7] = "High end"
local _MaxWType = 9
-- Color names
local _ModColorNames = {
	"Black",
	"Graphite",
	"Black Steel",
	"Dark Steel",
	"Silver",
	"Bluish Silver",
	"Rolled Steel",
	"Shadow Silver",
	"Stone Silver",
	"Midnight Silver",
	"Cast Iron Silver",
	"Anthracite Black",
	"Matte Black",
	"Matte Gray",
	"Matte Light Gray",
	"Util Black",
	"Util Black Poly",
	"Util Dark Silver",
	"Util Silver",
	"Util Gun Metal",
	"Util Shadow Silver",
	"Worn Black",
	"Worn Graphite",
	"Worn Silver Gray",
	"Worn Silver",
	"Worn Blue Silver",
	"Worn Shadow Silver",
	"Red",
	"Torino Red",
	"Formula Red",
	"Blaze Red",
	"Grace Red",
	"Garnet Red",
	"Sunset Red",
	"Cabernet Red",
	"Candy Red",
	"Sunrise Orange",
	"Gold",
	"Orange",
	"Matte Red",
	"Matte Dark Red",
	"Matte Orange",
	"Matte Yellow",
	"Util Red",
	"Util Bright Red",
	"Util Garnet Red",
	"Worn Red",
	"Worn Golden Red",
	"Worn Dark Red",
	"Dark Green",
	"Racing Green",
	"Sea Green",
	"Olive Green",
	"Bright Green",
	"Gasoline Green",
	"Matte Lime Green",
	"Util Dark Green",
	"Util Green",
	"Worn Dark Green",
	"Worn Green",
	"Worn Sea Wash",
	"Galaxy Blue",
	"Dark Blue",
	"Saxon Blue",
	"Blue",
	"Mariner Blue",
	"Harbor Blue",
	"Diamond Blue",
	"Surf Blue",
	"Nautical Blue",
	"Ultra Blue",
	"Schafter Purple",
	"Spinnaker Blue",
	"Racing Blue",
	"Light Blue",
	"Util Dark Blue",
	"Util Midnight Blue",
	"Util Blue",
	"Util Sea Foam Blue",
	"Util Lightning Blue",
	"Util Maui Blue Poly",
	"Util Bright Blue",
	"Matte Dark Blue",
	"Matte Blue",
	"Matte Midnight Blue",
	"Worn Dark Blue",
	"Worn Blue",
	"Worn Light Blue",
	"Yellow",
	"Race Yellow",
	"Bronze",
	"Dew Yellow",
	"Lime Green",
	"Champagne",
	"Feltzer Brown",
	"Creek Brown",
	"Chocolate Brown",
	"Maple Brown",
	"Saddle Brown",
	"Straw Brown",
	"Moss Brown",
	"Bison Brown",
	"Woodbeech Brown",
	"Beechwood Brown",
	"Sienna Brown",
	"Sandy Brown",
	"Bleached Brown",
	"Cream",
	"Util Brown",
	"Util Medium Brown",
	"Util Light Brown",
	"Ice White",
	"Frost White",
	"Worn Honey Beige",
	"Worn Brown",
	"Worn Dark Brown",
	"Worn Straw Beige",
	"Brushed Steel",
	"Brushed Black Steel",
	"Brushed Aluminium",
	"Chrome",
	"Worn White",
	"Util White",
	"Worn Orange",
	"Worn Light Orange",
	"Securicor Green",
	"Worn Taxi Yellow",
	"Police Car Blue",
	"Matte Green",
	"Matte Brown",
	"Matte Light Orange",
	"Matte Ice White",
	"Worn White",
	"Worn Army Green",
	"Pure White",
	"Hot Pink",
	"Salmon Pink",
	"Pfister Pink",
	"Bright Orange",
	"Bright Green",
	"Bright Blue",
	"Midnight Blue",
	"Midnight Purple",
	"Wine Red",
	"Hunter Green",
	"Bright Purple",
	"Midnight Purple",
	"Carbon Black",
	"Matte Schafter Purple",
	"Matte Midnight Purple",
	"Lava Red",
	"Matte Forest Green",
	"Matte Olive Drab",
	"Matte Dark Earth",
	"Matte Desert Tan",
	"Matte Foliage Green",
	"Wheel Aloy",
	"Epsilon Blue",
	"Pure Gold",
	"Brushed Gold"
}
-- Color types
local _ModColorTypes = {
	"Metallic",
	"Classic",
	"Pearlescent",
	"Matte",
	"Metals",
	"Chrome"
}

-- Functions must match module folder name

-- Init function is called once from the main Lua
function VehicleMod:Init()
	-- Initialization code goes here
	print("VehicleMod v1.0a - by Mockba the Borg")
end

function VehicleMod:ApplyNeons(vehID, color)
	if not color then
		-- Neons will follow the vehicle's color by default
		color = {}
		local r = Cvar:new()
		local g = Cvar:new()
		local b = Cvar:new()
		natives.VEHICLE.GET_VEHICLE_COLOR(vehID, r, g, b)
		color.r = r:getInt()
		color.g = g:getInt()
		color.b = b:getInt()
		-- Maximize color intensity
		local ratio = 255/math.max(color.r, color.g, color.b)
		color.r=color.r*ratio
		color.g=color.g*ratio
		color.b=color.b*ratio
	end
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(vehID, color.r, color.g, color.b)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 0, true)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 1, true)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 2, true)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 3, true)
end

function VehicleMod:RemoveNeons(vehID, color)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 0, false)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 1, false)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 2, false)
	natives.VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehID, 3, false)
end

-- Run function is called multiple times from the main Lua
function VehicleMod:Run()
	if _VehicleMode then
		VehicleMod:Process()
	end
	if IsKeyJustDown(ToggleKey) then
		_VehicleMode = not _VehicleMode
		_VehicleModKit = nil
		_VehicleModID = _MinVehicleModID
		_VehicleModValue = nil
		_VehicleWType = nil
		if _VehicleMode then
			ui.MapMessage("~g~Vehicle mode enabled.")
		else
			ui.MapMessage("~r~Vehicle mode disabled.")
		end
	end
end

function VehicleMod:Process()
	if LocalPlayer():IsInVehicle() then
		if natives.ENTITY.GET_ENTITY_SPEED(LocalPlayer():GetVehicle().ID) > 10 then
			_VehicleMode = false
		end
-- Mod kit and vehicle
		local hasmod = false

		local veh = LocalPlayer():GetVehicle()
		if not _VehicleModKit then
			natives.VEHICLE.SET_VEHICLE_MOD_KIT(veh.ID, 0)
			_VehicleModKit = 0
		end
		ui.DrawTextBlock("Modding : ", _ModX, _ModY, FontChaletComprimeCologne, _FontSize, COLOR_GREEN, NOBLINK)
		ui.DrawTextBlock(veh:GetMaker().." "..veh:GetFullName()..", "..veh:GetClassName(), _ModX+.047, _ModY, nil, nil, COLOR_WHITE)
-- Current wheel type
		if _VehicleModID == VehicleModFrontWheels or _VehicleModID == VehicleModBackWheels then
			if not _VehicleWType then
				_VehicleWType = natives.VEHICLE.GET_VEHICLE_WHEEL_TYPE(veh.ID)
			end
		end
-- Mod name
		local modSlotName = nil
		if _VehicleModID < 0 then
			modSlotName = _Mod[_VehicleModID]
		else
			modSlotName = natives.VEHICLE.GET_MOD_SLOT_NAME(veh.ID, _VehicleModID)
			modSlotName = modSlotName or _Mod[_VehicleModID] or "n/a"
		end
		if natives.UI._GET_LABEL_TEXT(modSlotName) ~= "NULL" then
			modSlotName = natives.UI._GET_LABEL_TEXT(modSlotName)
		end
		local str = "Mod #".._VehicleModID.." : "..modSlotName
		if _VehicleModID == VehicleModFrontWheels or _VehicleModID == VehicleModBackWheels then
			str = str.." ("..(_ModW[_VehicleWType] or _VehicleWType)..")"
		end
		if _VehicleModID == _Mod_VEH_EXTRA then
			str = str.." (".._VehicleExtra
			if veh:HasExtra(_VehicleExtra) then
				str = str.."*"
			end
			str = str..")"
		end
		
-- Mod limits
		if _ModLimits[_VehicleModID] then
			_MinVehicleModValue = _ModLimits[_VehicleModID].vmin
			_MaxVehicleModValue = _ModLimits[_VehicleModID].vmax
		else
			if _VehicleModID == _Mod_Livery then
				_MinVehicleModValue = 0
				_MaxVehicleModValue = natives.VEHICLE.GET_VEHICLE_LIVERY_COUNT(veh.ID) - 1
			else
				_MinVehicleModValue = -1
				_MaxVehicleModValue = (natives.VEHICLE.GET_NUM_VEHICLE_MODS(veh.ID, _VehicleModID) or 0)-1

			end
		end
		local nvar = _MaxVehicleModValue - _MinVehicleModValue + 1
		str = str.." : "..nvar.." type"
		if nvar ~= 1 then
			str = str.."s"
		end
		ui.DrawTextBlock(str)
-- Get current mod value
		if not _VehicleModValue then
			if not _ModLimits[_VehicleModID] then
				if _VehicleModID == _Mod_Livery then
					_VehicleModValue = natives.VEHICLE.GET_VEHICLE_LIVERY(veh.ID)
				else
					_VehicleModValue = natives.VEHICLE.GET_VEHICLE_MOD(veh.ID, _VehicleModID)
				end
			else
				if _ModLimits[_VehicleModID].vtype == "boolean" then
					_VehicleModValue = 0
					if _VehicleModID == _Mod_VEH_EXTRA then
						if veh:IsExtraOn(_VehicleExtra) then
							_VehicleModValue = 1
						end
					else
						if natives.VEHICLE.IS_TOGGLE_MOD_ON(veh.ID, _VehicleModID) then
							_VehicleModValue = 1
						end
					end
					if not  _ModType[_VehicleModID] then
						_ModType[_VehicleModID] = {}
						_ModType[_VehicleModID][0] = "Not installed"
						_ModType[_VehicleModID][1] = "Installed"
					end
				else
					if     _VehicleModID == _Mod_PRI_COLOR then
						_VehicleModValue = select(1, veh:GetColours())
					elseif _VehicleModID == _Mod_SEC_COLOR then
						_VehicleModValue = select(2, veh:GetColours())
					elseif _VehicleModID == _Mod_PRL_COLOR then
						_VehicleModValue = select(1, veh:GetExtraColours())
					elseif _VehicleModID == _Mod_WHL_COLOR then
						_VehicleModValue = select(2, veh:GetExtraColours())
					elseif _VehicleModID == _Mod_ACT_COLOR then
						_VehicleModValue = veh:GetAccentColor()
					elseif _VehicleModID == _Mod_TRM_COLOR then
						_VehicleModValue = veh:GetTrimColor()
					elseif _VehicleModID == _Mod_WND_TINT then
						_VehicleModValue = veh:GetWindowTint()
					elseif _VehicleModID == _Mod_PLT_TYPE then
						_VehicleModValue = veh:GetPlateType()
					end
				end
			end
		end
-- Set mod type name
		local modTypeName
		if _VehicleModID ==	_Mod_PRI_COLOR or
		   _VehicleModID ==	_Mod_SEC_COLOR or
		   _VehicleModID ==	_Mod_PRL_COLOR or
		   _VehicleModID ==	_Mod_WHL_COLOR or
		   _VehicleModID ==	_Mod_ACT_COLOR or
		   _VehicleModID ==	_Mod_TRM_COLOR then
			modTypeName = _ModColorNames[_VehicleModValue+1] or "**Undef**"
		else
			modTypeName = (_ModType[_VehicleModID] and _ModType[_VehicleModID][_VehicleModValue])
			if not modTypeName then
				local defaultName = "Stock"
				if _VehicleModValue ~= -1 then
					defaultName = "n/a"
					modTypeName = natives.VEHICLE.GET_MOD_TEXT_LABEL(veh.ID, _VehicleModID, _VehicleModValue)
				end
				modTypeName = modTypeName or defaultName
				if natives.UI._GET_LABEL_TEXT(modTypeName) ~= "NULL" then
					modTypeName = natives.UI._GET_LABEL_TEXT(modTypeName)
				end
			end
		end
		modTypeName = " ("..modTypeName..")"
		str = "Current: ".._VehicleModValue..modTypeName
		ui.DrawTextBlock(str)
-- Enter specific value
		if IsKeyJustDown(_KeyEnterValue, true) then
			if	_VehicleModID==_Mod_PRI_COLOR or
				_VehicleModID==_Mod_SEC_COLOR or
				_VehicleModID==_Mod_PRL_COLOR or
				_VehicleModID==_Mod_WHL_COLOR or
				_VehicleModID==_Mod_ACT_COLOR or
				_VehicleModID==_Mod_TRM_COLOR then
				local text = ui.OnscreenKeyboard("Enter ".._Mod[_VehicleModID], 3)
				if text then
					_VehicleModValue = tonumber(text)
					hasmod = true
				end
			end
			if _VehicleModID==_Mod_PLT_TYPE then
				local text = ui.OnscreenKeyboard("Enter vehicle plate", 8)
				if text then
					veh:SetPlateText(text)
				end
			end
		end
-- Fully upgrade vehicle
		if IsKeyJustDown(_KeyUpgradeVehicle, true) then
			_FullUpgrade = 1
		end
		if IsKeyJustDown(KEY_CLEAR) then
			_FullUpgrade = 2
		end
		if _FullUpgrade > 0 then
			for i=0,48,1 do
				if _ModLimits[i] then
					if _ModLimits[i].vtype == "boolean" then
						natives.VEHICLE.TOGGLE_VEHICLE_MOD(veh.ID, i, true)
					end
				else
					local _MaxVehicleModValue = natives.VEHICLE.GET_NUM_VEHICLE_MODS(veh.ID, i) or 0
					natives.VEHICLE.SET_VEHICLE_MOD(veh.ID, i, _MaxVehicleModValue-1, true)
				end
			end
			VehicleMod:ApplyNeons(veh.ID)
			if _FullUpgrade > 1 then
				if veh:IsCar() or veh:IsBike() then
					natives.VEHICLE.SET_VEHICLE_MOD(veh.ID, 14, _UpgradeHorn, true)
					veh:SetPlateText(_UpgradePlateText)
					veh:SetPlateType(_UpgradePlateType)
				end
				veh:SetColours(_UpgradePriColor, _UpgradeSecColor)
				veh:SetExtraColours(_UpgradePrlColor, _UpgradeWhlColor)
				veh:SetAccentColor(_UpdateAccColor)
				veh:SetTrimColor(_UpdateTrmColor)
			end
			if veh:IsCar() then
				veh:SetWindowTint(_UpgradeWindowTint)
				natives.VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh.ID, _UpgradeWheelType)
				natives.VEHICLE.SET_VEHICLE_MOD(veh.ID, 23, _UpgradeCarWheelNumber, true)
			end
			if veh:IsBike() then
				natives.VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh.ID, 6)
				natives.VEHICLE.SET_VEHICLE_MOD(veh.ID, 23, _UpgradeBikeWheelNumber, false)
				natives.VEHICLE.SET_VEHICLE_MOD(veh.ID, 24, _UpgradeBikeWheelNumber, false)
			end
			natives.VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh.ID)
			natives.VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh.ID, 0)
			natives.VEHICLE.SET_VEHICLE_STRONG(veh.ID, true)
			natives.VEHICLE._0xAB04325045427AAE(veh.ID, false)
			natives.VEHICLE._0x428BACCDF5E26EAD(veh.ID, false)
			for i = 1,12 do
				if natives.VEHICLE.DOES_EXTRA_EXIST(veh.ID, i) then
					natives.VEHICLE.SET_VEHICLE_EXTRA(veh.ID, i, false)
					print("Extra",i,"set.")
				end
			end
			natives.VEHICLE.SET_VEHICLE_HAS_STRONG_AXLES(veh.ID, true)
			natives.VEHICLE.SET_VEHICLE_REDUCE_GRIP(veh.ID, false)
			natives.VEHICLE.SET_CAN_RESPRAY_VEHICLE(veh.ID, true)
			natives.VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh.ID, false)
			natives.VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(veh.ID, false)
			natives.VEHICLE.SET_VEHICLE_ENGINE_CAN_DEGRADE(veh.ID, false)
			natives.VEHICLE.SET_VEHICLE_IS_STOLEN(veh.ID, false)
			natives.VEHICLE.ADD_VEHICLE_UPSIDEDOWN_CHECK(veh.ID)

			local multiplier = 50
			print("Setting engine multiplier to", multiplier)
			natives.VEHICLE._SET_VEHICLE_ENGINE_POWER_MULTIPLIER(veh.ID, multiplier)
			natives.VEHICLE._SET_VEHICLE_ENGINE_TORQUE_MULTIPLIER(veh.ID, multiplier)
			
			natives.VEHICLE.SET_VEHICLE_FRICTION_OVERRIDE(veh.ID, 2)

			ui.MapMessage("~b~Vehicle fully upgraded.")
			_FullUpgrade = 0
			return
		end
-- Lists some of information about the vehicle
		if IsKeyJustDown(_KeyVehicleInfo, true) then
			local pri, sec = veh:GetColours()
			local prl, whl = veh:GetExtraColours()
			print("Color Info ----------------")
			print("Primary color:", pri, _ModColorNames[pri+1])
			print("Secondary color:", sec, _ModColorNames[sec+1])
			print("Pearlescent color:", prl, _ModColorNames[prl+1])
			print("Wheel color:", whl, _ModColorNames[whl+1])
			print("Number of veh colors:", natives.VEHICLE.GET_NUMBER_OF_VEHICLE_COLOURS(veh.ID))
			print("Veh colour combination:", natives.VEHICLE.GET_VEHICLE_COLOUR_COMBINATION(veh.ID))
			local r = Cvar:new()
			local g = Cvar:new()
			local b = Cvar:new()
			natives.VEHICLE.GET_VEHICLE_COLOR(veh.ID, r, g, b)
			print("Veh color:",r:getInt(),g:getInt(),b:getInt())
			print("_0xE6B0E8CFC3633BF0", natives.VEHICLE._0xE6B0E8CFC3633BF0(veh.ID))
			print("_0xEEBFC7A7EFDC35B4", natives.VEHICLE._0xEEBFC7A7EFDC35B4(veh.ID))
			print("_0x53AF99BAA671CA47", natives.VEHICLE._0x53AF99BAA671CA47(veh.ID))
			print("_0x6636C535F6CC2725", natives.VEHICLE._0x6636C535F6CC2725(veh.ID))
			print("_GET_VEHICLE_BODY_HEALTH", natives.VEHICLE.GET_VEHICLE_BODY_HEALTH(veh.ID))
			print("_GET_VEHICLE_BODY_HEALTH_2", natives.VEHICLE._GET_VEHICLE_BODY_HEALTH_2(veh.ID))
			print("_0x42A4BEB35D372407", natives.VEHICLE._0x42A4BEB35D372407(veh.ID))
			print("_0x2C8CBFE1EA5FC631", natives.VEHICLE._0x2C8CBFE1EA5FC631(veh.ID))
			print("_0x36492C2F0D134C56", natives.VEHICLE._0x36492C2F0D134C56(veh.ID))
			print("_0xBFBA3BA79CFF7EBF", natives.VEHICLE._0xBFBA3BA79CFF7EBF(veh:GetModel()))
			print("_0x53409B5163D5B846", natives.VEHICLE._0x53409B5163D5B846(veh:GetModel()))
			print("_0xC6AD107DDC9054CC", natives.VEHICLE._0xC6AD107DDC9054CC(veh:GetModel()))
			print("_0x5AA3F878A178C4FC", natives.VEHICLE._0x5AA3F878A178C4FC(veh:GetModel()))
--			local soundID = natives.AUDIO.GET_SOUND_ID()
--			local netID = natives.AUDIO.GET_NETWORK_ID_FROM_SOUND_ID(soundID)
--			local pos = LocalPlayer():GetPosition()
--			natives.NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID, true)
--			natives.AUDIO.PLAY_SOUND_FROM_ENTITY(soundID, "Crate_Beeps", veh.ID, "MP_CRATE_DROP_SOUNDS", false, 0)
--			natives.AUDIO.PLAY_SOUND_FROM_COORD(soundID, "Crate_Beeps", pos.x,pos.y,pos.z, "MP_CRATE_DROP_SOUNDS", false, 0, false)
--			natives.AUDIO.PLAY_SOUND(soundID, "Crate_Beeps", "MP_CRATE_DROP_SOUNDS", true, 127, true)
--			natives.AUDIO.RELEASE_SOUND_ID(soundID)
		end
-- Lists all available mods for a vehicle
		if IsKeyJustDown(_KeyVehicleMods, true) then
			for i=0,48,1 do
				local v = natives.VEHICLE.GET_NUM_VEHICLE_MODS(veh.ID, i) or 0
				if v > 0 then
					local modname = natives.VEHICLE.GET_MOD_SLOT_NAME(veh.ID, i) or _Mod[i]
					print("Mod:",i,":",modname,":",v,"variations")
					for t = -1,v-1,1 do
						local label = "Stock"
						if t ~= -1 then
							label = natives.VEHICLE.GET_MOD_TEXT_LABEL(veh.ID, i, t)
							label = label or (_ModType[i] and _ModType[i][t]) or "n/a"
							if natives.UI._GET_LABEL_TEXT(label) ~= "NULL" then
								label = natives.UI._GET_LABEL_TEXT(label)
							end
						end
						print("\tVal:",t,":",label)
					end
				end
			end
			return
		end
-- Select Mod type
		if IsKeyJustDown(_KeyModTypeDown, true) then
			_VehicleModID = _VehicleModID+1
			if _VehicleModID > _MaxVehicleModID then
				_VehicleModID = _MinVehicleModID
			end
			_VehicleModValue = nil
			return
		end
		if IsKeyJustDown(_KeyModTypeUp, true) then
			_VehicleModID = _VehicleModID-1
			if _VehicleModID < _MinVehicleModID then
				_VehicleModID = _MaxVehicleModID
			end
			_VehicleModValue = nil
			return
		end
-- Select wheel type
		if _VehicleModID == VehicleModFrontWheels or _VehicleModID == VehicleModBackWheels then
			if IsKeyJustDown(_KeyModWheelRight, true) then
				_VehicleWType = _VehicleWType+1
				if _VehicleWType > _MaxWType then
					_VehicleWType = 0
				end
				natives.VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh.ID, _VehicleWType)
			end
			if IsKeyJustDown(_KeyModWheelLeft, true) then
				_VehicleWType = _VehicleWType-1
				if _VehicleWType < 0 then
					_VehicleWType = _MaxWType
				end
				natives.VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh.ID, _VehicleWType)
			end
		end
-- Select Extra type
		if _VehicleModID == _Mod_VEH_EXTRA then
			if IsKeyJustDown(_KeyModExtraRight, true) then
				_VehicleExtra = _VehicleExtra+1
				if _VehicleExtra > _MaxVehicleExtras then
					_VehicleExtra = _MinVehicleExtras
				end
			end
			if IsKeyJustDown(_KeyModExtraLeft, true) then
				_VehicleExtra = _VehicleExtra-1
				if _VehicleExtra < _MinVehicleExtras then
					_VehicleExtra = _MaxVehicleExtras
				end
			end
			_VehicleModValue = 0
			if veh:IsExtraOn(_VehicleExtra) then
				_VehicleModValue = 1
			end
		end
-- Select Mod value
		if IsKeyJustDown(_KeyModValueRight, true) then
			_VehicleModValue = _VehicleModValue+1
			if _VehicleModValue > _MaxVehicleModValue then
				_VehicleModValue = _MinVehicleModValue
			end
			hasmod = true
		end
		if IsKeyJustDown(_KeyModValueLeft, true) then
			_VehicleModValue = _VehicleModValue-1
			if _VehicleModValue < _MinVehicleModValue then
				_VehicleModValue = _MaxVehicleModValue
			end
			hasmod = true
		end
-- Apply modifications
		if hasmod then
			if not _ModLimits[_VehicleModID] then
				if _VehicleModID == _Mod_Livery then
					natives.VEHICLE.SET_VEHICLE_LIVERY(veh.ID, _VehicleModValue)
				else
					natives.VEHICLE.SET_VEHICLE_MOD(veh.ID, _VehicleModID, _VehicleModValue, true)
				end
			else
				if _ModLimits[_VehicleModID].vtype == "boolean" then
					if _VehicleModID == _Mod_VEH_EXTRA then
						if _VehicleModValue==1 then
							veh:SetExtra(_VehicleExtra)
						else
							veh:ClearExtra(_VehicleExtra)
						end
					else
						natives.VEHICLE.TOGGLE_VEHICLE_MOD(veh.ID, _VehicleModID, _VehicleModValue==1)
						if _VehicleModID == 21 then
							if _VehicleModValue==1 then
								VehicleMod:ApplyNeons(veh.ID)
							else
								VehicleMod:RemoveNeons(veh.ID)
							end
						end
					end
				else
					if     _VehicleModID == _Mod_PRI_COLOR then
						local c = select(2, veh:GetColours())
						veh:SetColours(_VehicleModValue, c)
					elseif _VehicleModID == _Mod_SEC_COLOR then
						local c = select(1, veh:GetColours())
						veh:SetColours(c, _VehicleModValue)
					elseif _VehicleModID == _Mod_PRL_COLOR then
						local c = select(2, veh:GetExtraColours())
						veh:SetExtraColours(_VehicleModValue, c)
					elseif _VehicleModID == _Mod_WHL_COLOR then
						local c = select(1, veh:GetExtraColours())
						veh:SetExtraColours(c, _VehicleModValue)
					elseif _VehicleModID == _Mod_ACT_COLOR then
						veh:SetAccentColor(_VehicleModValue)
					elseif _VehicleModID == _Mod_TRM_COLOR then
						veh:SetTrimColor(_VehicleModValue)
					elseif _VehicleModID == _Mod_WND_TINT then
						veh:SetWindowTint(_VehicleModValue)
					elseif _VehicleModID == _Mod_PLT_TYPE then
						veh:SetPlateType(_VehicleModValue)
					end
				end
			end
			_VehicleModValue = nil
		end
	else
-- Clean up if not in a vehicle
		ui.DrawTextBlock("Not in a Vehicle", _ModX, _ModY, FontChaletComprimeCologne, _FontSize, COLOR_GREEN, BLINK)
		_VehicleModKit = nil
		_VehicleModID = _MinVehicleModID
		_VehicleModValue = nil
		_VehicleWType = nil
-- Add (Spawn) new vehicle by name
		if IsKeyJustDown(_KeyAddVehicle, true) then
			local name = ui.OnscreenKeyboard("Enter Vehicle name", 20)
			if name then
				local position = LocalPlayer():GetPosition()
				local heading = LocalPlayer():GetHeading()
				local hash = natives.GAMEPLAY.GET_HASH_KEY(name)
				if natives.VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(hash) ~= "CARNOTFOUND" then
					streaming.RequestModel(hash)
					local ent = game.CreateVehicle(hash, position, heading)
					natives.DECORATOR.DECOR_SET_INT(ent.ID, "MPBitset", _MPBitset)
					LocalPlayer():SetIntoVehicle(ent.ID, VehicleSeatDriver)
					ent:SetRadioStationName("OFF")
					ent:SetNotNeeded()
					ui.MapMessage("~b~"..string.upper(name).." spawned.")
				else
					print("Vehicle does not exist.")
				end
			end
		end
	end
end

-- Run when an addon if (properly) unloaded
function VehicleMod:Unload()

end

-- This line must match the module folder name
export = VehicleMod
