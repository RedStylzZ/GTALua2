-- Runs a Lua command
function console.lua(...)
	local str = table.concat({...}, " ")
	local func = load(str)
	if func then
		func()
	else
		print("Invalid Lua call.")
	end
end
console.RegisterCommand("lua", "Runs a Lua command", console.lua)
