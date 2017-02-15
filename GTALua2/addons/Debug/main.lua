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

-- Variables for measuring framerate
local ToggleKey = KEY_F9
local ShowDebug = false

-- Functions must match module folder name
-- Init function is called once from the main Lua
function Debug:Init()
	print("Debug v1.0 - by Mockba the Borg")
end

-- Run function is called multiple times from the main Lua
function Debug:Run()
	if ShowDebug then
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

-- This line must match the module folder name
export = Debug
