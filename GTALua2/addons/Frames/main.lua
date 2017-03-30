-- Basic mod to show framerate on the top right
-- These two lines must match the module folder name
Frames = {}
Frames.__index = Frames
-- ScriptInfo table must exist and define Name, Author and Version
Frames.ScriptInfo = {
	Name = "Frames",	-- Must match the module name
	Author = "Mockba the Borg",
	Version = "1.0a"
}
-- Variables for measuring framerate
local _FrameCount = 0
local _FrameSum = 0
local _FrameTime = 0
local ToggleKey = KEY_F8
Frames.Active = false
-- Functions must match module folder name
-- Init function is called once from the main Lua
function Frames:Init()
	print("Frames v1.0a - by Mockba the Borg")
end
-- Run function is called multiple times from the main Lua
function Frames:Run()
	if Frames.Active then
		-- Shows FrameRate
		local fTime = 1.0 / natives.GAMEPLAY._0xE599A503B3837E1B()
		_FrameSum = _FrameSum + fTime
		_FrameCount = _FrameCount + 1
		local divisor = 60
		if _FrameCount == divisor then
			_FrameCount = 0
			_FrameTime = _FrameSum / divisor
			_FrameSum = 0
		end
		if _FrameTime>50 then
			ui.DrawTextUI(string.format("%02.0f", _FrameTime), .979, .0003, 7, .4, COLOR_GREEN_50)
		else
			ui.DrawTextUI(string.format("%02.0f", _FrameTime), .979, .0003, 7, .4, COLOR_RED_50)
		end
	end
	if ui.ChatActive() then
		return
	end
	if IsKeyJustDown(ToggleKey) then
		Frames.Active = not Frames.Active
		if Frames.Active then
			ui.MapMessage("~g~FPS display enabled.")
		else
			ui.MapMessage("~r~FPS display disabled.")
		end
	end
end
-- Run when an addon if (properly) unloaded
function Frames:Unload()
end
-- This line must match the module folder name
export = Frames
