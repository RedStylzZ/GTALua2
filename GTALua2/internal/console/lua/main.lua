-- Runs a Lua command
function console.lua(...)
	local str = table.concat({...}, " ")
	local func = load(str)
	func()
end
console.RegisterCommand("lua", "Runs a Lua command", console.lua)
