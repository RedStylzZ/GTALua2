-- Console implementation
console = {}
console.Commands = {}
console.Descriptions = {}

-- Process input
function console.Process(input)
	if type(input) ~= "string" or input == "" then
		return
	end

	local args = explode(" ", input)
	local cmd = string.lower(table.remove(args, 1))
	
	local func = console.Commands[cmd]
	if func == nil then
		print("Unknown console command: "..cmd)
	else
		func(table.unpack(args))
	end
end

-- Register a Command onto the console list
function console.RegisterCommand(name, descr, callback)
	console.Commands[name] = callback
	console.Descriptions[name] = descr
end

-- Help
function console.help()
	print("List of available commands:")
	print("-----------------------------")
	for k,v in pairs(console.Commands) do
		print(k .. " - " .. console.Descriptions[k])
	end
	print("-----------------------------")
end
console.RegisterCommand("help", "Lists all registered commands", console.help)

-- Lists all addons
function console.list()
	print("List of loaded addons:")
	print("-----------------------------")
	for k, v in pairs(addons) do
		print(k)
	end
	print("-----------------------------")
end
console.RegisterCommand("list", "Lists all registered addons", console.list)

-- Loads an addon
function console.load(name)
	print("Loading "..name.." ...")
	require(LuaFolder().."/addons/"..name.."/main")
	addons[name] = export
	success, err = xpcall (addons[name].Init, debug.traceback)
	if success == false then
		print ("Error: " .. err .. " - Addon removed.")
		addons[name] = nil
	end
end
console.RegisterCommand("load", "Loads an addon from file", console.load)

-- Reloads an addon
function console.reload(name)
	if addons[name] then
		console.unload(name)
		console.load(name)
	end
end
console.RegisterCommand("reload", "Reloads an addon from file", console.reload)

-- Reloads all addons
function console.reloadall()
	print("Reloading all addons:")
	print("-----------------------------")
	for k, v in pairs(addons) do
		console.reload(k)
	end
	print("-----------------------------")
end
console.RegisterCommand("reloadall", "Reloads all addons", console.reloadall)

-- Unload an addon
function console.unload(name)
	if addons[name] then
		print("Unloading "..name.." ...")
		package.loaded[LuaFolder().."/addons/"..name.."/main"] = nil
		addons[name] = nil
	else
		print("Can't find addon "..name.." ...")
	end	
end
console.RegisterCommand("unload", "Unloads an addon", console.unload)

-- Runs a Lua command
function console.lua(...)
	local str = table.concat({...}, " ")
	local func = load(str)
	func()
end
console.RegisterCommand("lua", "Runs a Lua command", console.lua)
