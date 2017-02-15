-- GTALua2 main file
-- Based on GTALua from https://github.com/Freeeaky/GTALua - by Jan S. Freeeaky
-- Online related portions based on https://github.com/MockbaTheBorg/GTALua - by Mockba the Borg
-- Based on infamouscheats.cc open source base code - http://infamouscheats.cc/

-- Load game data globals
require (LuaFolder () .. "/globals/colors")
require (LuaFolder () .. "/globals/enums")
require (LuaFolder () .. "/globals/keycodes")

-- Load internal modules
require (LuaFolder () .. "/internal/functions") -- extra functions must be first
require (LuaFolder () .. "/internal/callnative")
require (LuaFolder () .. "/internal/console")
require (LuaFolder () .. "/internal/game")
require (LuaFolder () .. "/internal/loadnatives")
require (LuaFolder () .. "/internal/ui")

-- Load game object classes
require (LuaFolder () .. "/classes/entity")
require (LuaFolder () .. "/classes/ped")
require (LuaFolder () .. "/classes/player")

-- Main code starts here

ClrScr ()
FGColor(console_Aqua)
print ("GTALua2 v" .. GameVersion () .. " loaded.")
print ("Online module for v" .. OnlineVersion () .. " loaded.")
FGColor(console_White)

-- Load external addons
print("Loading all addons ...")
print("-----------------------------")
addons = {}
addonCount = 0

local f = io.popen("dir /b /a:d "..LuaFolder().."\\addons")
for addon in f:lines() do
	local array = explode(".", addon)
	name = array[1]
	if file_exists(LuaFolder().."/addons/"..name.."/main.lua") then
		require(LuaFolder().."/addons/"..name.."/main")
		addons[name] = export
		addonCount = addonCount + 1
		print("  Loaded: "..name..".")
	else
		print("  Not loaded: "..name..".")
	end
end

for k, v in pairs(addons) do
	success, err = xpcall (v.Init, debug.traceback)
	if success == false then
		print ("Error: " .. err .. " - Addon removed.")
		addons[k] = nil
	end
end

local Command = nil
function Run ()
	-- Disable cheat code key to be used as console key
	natives.CONTROLS.DISABLE_CONTROL_ACTION(0, ControlEnterCheatCode, true)
	if IsKeyJustDown(VK_OEM_3) then -- cheat code key was pressed
		console.Process(ui.OnscreenKeyboard("Console Command", 50))
	end

	-- Execute existing addons
	for k, v in pairs(addons) do
		success, err = xpcall (v.Run, debug.traceback)
		if success == false then
			print ("Error: " .. err .. " - Addon removed.")
			addons[k] = nil
		end
	end
end
