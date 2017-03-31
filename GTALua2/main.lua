-- GTALua2 main file
-- Based on GTALua from https://github.com/Freeeaky/GTALua - by Jan S. Freeeaky
-- Online related portions based on https://github.com/MockbaTheBorg/GTALua - by Mockba the Borg
-- Based on infamouscheats.cc open source base code - http://infamouscheats.cc/

-- Load game data globals
require (LuaFolder () .. "/globals/colors")
require (LuaFolder () .. "/globals/enums")
require (LuaFolder () .. "/globals/keycodes")
require (LuaFolder () .. "/globals/vehicles")
require (LuaFolder () .. "/globals/weapons")

-- Load internal modules
require (LuaFolder () .. "/internal/functions") -- extra functions must be first
require (LuaFolder () .. "/internal/callnative")
require (LuaFolder () .. "/internal/console")
require (LuaFolder () .. "/internal/game")
require (LuaFolder () .. "/internal/loadnatives")
require (LuaFolder () .. "/internal/streaming")
require (LuaFolder () .. "/internal/ui")

-- Load game object classes
require (LuaFolder () .. "/classes/entity")
require (LuaFolder () .. "/classes/object")
require (LuaFolder () .. "/classes/ped")
require (LuaFolder () .. "/classes/player")
require (LuaFolder () .. "/classes/vehicle")
require (LuaFolder () .. "/classes/blip")

-- Main code starts here
ClrScr()
FGColor(console_Aqua)
print ("=--------------------------------------------=")
print (" GTALua2 v" .. GameVersion () .. " loaded.")
print (" Online module for v" .. OnlineVersion () .. " loaded.")
print ("=--------------------------------------------=")
FGColor(console_White)

-- Set MPVehsOnSP Global to 1 (for v1.0.877.1)
--local MPVehPtr = Cptr:new(GlobalPointer(2576573))

-- Set MPVehsOnSP Global to 1 (for v1.0.944.2)
--local MPVehPtr = Cptr:new(GlobalPointer(2593910))

-- Set MPVehsOnSP Global to 1 (for v1.0.1011.1)
local MPVehPtr = Cptr:new(GlobalPointer(2593970))

MPVehPtr:setInt(0, 1)

-- Load external addons
print("\nLoading all addons ...")
print("----------------------------------------------")
addons = {}
addonCount = 0

function LoadMod(name)
		require(LuaFolder().."/addons/"..name.."/main")
		addons[name] = export
		addonCount = addonCount + 1
end
local f = io.popen("dir /b /a:d "..LuaFolder().."\\addons")
for addon in f:lines() do
	local array = explode(".", addon)
	name = array[1]
	if file_exists(LuaFolder().."/addons/"..name.."/main.lua") then
		success, err = xpcall (LoadMod, debug.traceback, name)
		if success then
			print("  Loaded: "..name..".")
		else
			print ("Error: " .. err .. " - Addon not loaded.")
		end
	else
		print("  Not loaded: "..name..".")
	end
end
print("\nInitializing all addons ...")
print("----------------------------------------------")
for k, v in pairs(addons) do
	success, err = xpcall (v.Init, debug.traceback)
	if success == false then
		print ("Error: " .. err .. " - Addon \"" .. k .. "\" removed.")
		addons[k] = nil
	end
end

-- This function is called every time a Vehicle is spawned

function OnVehSpawn(VehId)
end

-- This function is called every time a Ped is spawned

function OnPedSpawn(PedID)
end

function Run ()
	-- Disable cheat code key so it can be used as console key
	natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlEnterCheatCode, true)
	if IsKeyJustDown(VK_OEM_3) then -- cheat code key was pressed
		console.Process(ui.OnscreenKeyboard("Console Command", 200))
	end
	-- Execute existing addons
	for k, v in pairs(addons) do
		success, err = xpcall (v.Run, debug.traceback)
		if success == false then
			xpcall (v.Unload, debug.traceback)
			print ("Error: " .. err .. " - Addon \"" .. k .. "\" removed.")
			addons[k] = nil
		end
	end
end
