-- Lists information about the game
function console.info(...)
	print("Game info...")
end
console.RegisterCommand("info", "Lists useful game information", console.info)
