-- Blank mod to serve as example only

-- These two lines must match the module folder name
Blank = {}
Blank.__index = Blank

-- ScriptInfo table must exist and define Name, Author and Version
Blank.ScriptInfo = {
	Name = "Blank",	-- Must match the module folder name
	Author = "Mockba the Borg",
	Version = "1.0"
}

-- Global variables
Blank.Active = false

-- Functions must match module folder name

-- Init function is called once from the main Lua
function Blank:Init()
	-- Initialization code goes here

end

-- Run function is called multiple times from the main Lua
function Blank:Run()
	-- Runtime code goes here

end

-- Run when an addon if (properly) unloaded
function Blank:Unload()

end

-- This line must match the module folder name
export = Blank
