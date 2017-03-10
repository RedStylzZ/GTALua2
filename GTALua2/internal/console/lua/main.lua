-- Runs a Lua command
function console.lua(...)
	local str = table.concat({...}, " ")
	local func = load(str)
	print("lua> "..str)
	if func then
		success, err = xpcall (func, debug.traceback)
		if not success then
			print ("Error: " .. err .. ".")
		end
	else
		print("Invalid Lua call.")
	end
end
console.RegisterCommand("lua", "Runs a Lua command", console.lua)
