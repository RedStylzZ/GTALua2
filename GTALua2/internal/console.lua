-- Console implementation
console = {}
console.Commands = {}

-- OnInput
function console.OnInput(input)
	if type(input) ~= "string" or input == "" then
		return
	end

	local args = explode(" ", input)
	local cmd = table.remove(args, 1)
	
	local func = console.Commands[cmd]
	if func == nil then
		print("Unknown console command "..cmd)
	else
		func(table.unpack(args))
	end
end

-- Register
function console.RegisterCommand(name, callback)
	console.Commands[name] = callback
end

-- Help
function console.help()
	print("List of available commands:")
	print("-----------------------------")
	for k,v in pairs(console.Commands) do
		print(k)
	end
	print("-----------------------------")
end
console.RegisterCommand("help", console.help)

-- Lists all addons
function console.list()
	print("List of loaded addons:")
	print("-----------------------------")
	for k, v in pairs(addons) do
		print(k)
	end
	print("-----------------------------")
end
console.RegisterCommand("list", console.list)

-- Loads an addon
function console.load(name)
	print("Loading "..name.." ...")
	require(LuaFolder().."/addons/"..name.."/main")
	addons[name] = export
	addons[name].Enabled = true
end
console.RegisterCommand("load", console.load)

-- Reloads an addon
function console.reload(name)
	print("Reloading "..name.." ...")
	if addons[name] then
		console.unload(name)
		console.load(name)
	end
end
console.RegisterCommand("reload", console.reload)

-- Reloads all addons
function console.reloadall()
	print("Reloading all addons:")
	print("-----------------------------")
	for k, v in pairs(addons) do
		console.reload(k)
	end
	print("-----------------------------")
end
console.RegisterCommand("reloadall", console.reloadall)

-- Unload an addon
function console.unload(name)
	if addons[name] then
		print("Unloading "..name.." ...")
		addons[name] = nil
	else
		print("Can't find addon "..name.." ...")
	end	
end
console.RegisterCommand("unload", console.unload)
