-- Player
Player = Ped:new()
Player_mt = { __index = Player }

-- Player CTor
function Player:new (id)
	local new_inst = {}
	new_inst.PlayerID = id or natives.PLAYER.PLAYER_ID()
	new_inst.ID = natives.PLAYER.GET_PLAYER_PED(id)
	setmetatable( new_inst, Player_mt )
	return new_inst
end

function LocalPlayer()
	return Player:new()
end