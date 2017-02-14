-- GTALua2 main file
-- Based on GTALua from https://github.com/Freeeaky/GTALua - by Jan S. Freeeaky
-- Online related portions based on https://github.com/MockbaTheBorg/GTALua - by Mockba the Borg
-- Based on infamouscheats.cc open source base code - http://infamouscheats.cc/

-- Load game data globals
require (LuaFolder () .. "/globals/colors")
require (LuaFolder () .. "/globals/enums")
require (LuaFolder () .. "/globals/keycodes")

-- Load internal modules
require (LuaFolder () .. "/internal/callnative")
require (LuaFolder () .. "/internal/console")
require (LuaFolder () .. "/internal/functions")
require (LuaFolder () .. "/internal/game")
require (LuaFolder () .. "/internal/loadnatives")
require (LuaFolder () .. "/internal/ui")

-- Main code starts here

ClrScr ()
FGColor(console_Aqua)
print ("GTALua2 v" .. GameVersion () .. " loaded.")
print ("Online module for v" .. OnlineVersion () .. " loaded.")
FGColor(console_White)

-- Load external addons
print("Loading all addons ...")
addons = {}
addonCount = 0

local f = io.popen("dir /b /a:d "..LuaFolder().."\\addons")
for addon in f:lines() do
	local array = explode(".", addon)
	name = array[1]
	print("  Loading "..name.." ...")
	require(LuaFolder().."/addons/"..name.."/main")
	addons[name] = export
	addons[name].Enabled = true
	addonCount = addonCount + 1
end

print("Loaded "..addonCount.." addons ...")

if addonCount > 0 then
	for k, v in pairs(addons) do
		success, err = xpcall (v.Init, debug.traceback)
		if success == false then
			print ("Error: " .. err .. " - Addon disabled.")
			addons[k].Enabled = false
		end
	end
end
	
function Run ()
	if addonCount > 0 then
		for k, v in pairs(addons) do
			if addons[k].Enabled then
				success, err = xpcall (v.Run, debug.traceback)
				if success == false then
					print ("Error: " .. err .. " - Addon disabled.")
					addons[k].Enabled = false
				end
			end
		end
	end	
end
