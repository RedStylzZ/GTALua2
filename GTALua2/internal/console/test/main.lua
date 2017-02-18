-- Loads a test addon
function console.test(name)
	print("Loading test "..name.." ...")
	if file_exists(LuaFolder().."/addons-test/"..name.."/main.lua") then
		package.loaded[LuaFolder().."/addons-test/"..name.."/main"] = nil
		require(LuaFolder().."/addons-test/"..name.."/main")
		addons[name] = export
		success, err = xpcall (addons[name].Init, debug.traceback)
		if success == false then
			print ("Error: " .. err .. " - Test addon removed.")
			addons[name] = nil
		end
	else
		print("Test addon folder or main file doesn't exist.")
	end
end
console.RegisterCommand("test", "Loads a test addon from file", console.test)

