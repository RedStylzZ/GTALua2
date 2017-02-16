-- Player
Player = Ped:new()
Player_mt = { __index = Player }

-- Player CTor
function Player:new (id)
	local new_inst = {}
	new_inst.PlayerID = id or natives.PLAYER.PLAYER_ID()
	new_inst.ID = natives.PLAYER.GET_PLAYER_PED(id)
	new_inst._type = "Player"
	setmetatable( new_inst, Player_mt )
	return new_inst
end

function LocalPlayer()
	return Player:new()
end

-- Methods

-- Name
function Player:GetName()
	return natives.PLAYER.GET_PLAYER_NAME(self.PlayerID)
end

-- Wanted Level
function Player:GetWantedLevel()
	return natives.PLAYER.GET_PLAYER_WANTED_LEVEL(self.PlayerID)
end
function Player:SetWantedLevel(i)
	natives.PLAYER.SET_PLAYER_WANTED_LEVEL(self.PlayerID, i, false)
	natives.PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(self.PlayerID, false)
end
function Player:ClearWantedLevel()
	natives.PLAYER.CLEAR_PLAYER_WANTED_LEVEL(self.PlayerID)
end

-- Dead
-- Overwrites Entity.IsDead
function Player:IsDead()
	return natives.PLAYER.IS_PLAYER_DEAD(self.PlayerID)
end

-- Model
function Player:SetModel(h)
	if not streaming.HasModelLoaded(h) then
		error("You need to load the model before applying it to a Player!")
	end
	
	natives.PLAYER.SET_PLAYER_MODEL(self.PlayerID, h)
end

-- Aiming at entity (returns true or false)
function Player:IsFreeAimingAtEntity(e)
	return natives.PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(self.PlayerID,e)
end

-- Is free aiming (returns true or false)
function Player:IsFreeAiming()
	return natives.PLAYER.IS_PLAYER_FREE_AIMING(self.PlayerID)
end

-- Set if player can use cover.
function Player:SetCanCover(b)
	natives.PLAYER.SET_PLAYER_CAN_USE_COVER(self.PlayerID,b)
end

-- prohibited any form of fighting
function Player:SetAllowFighting(b)
	natives.PLAYER.DISABLE_PLAYER_FIRING(self.PlayerID,b)
end

-- Multiplies player noise making
function Player:SetNoiseMaking(i)
	natives.PLAYER.SET_PLAYER_NOISE_MULTIPLIER(self.PlayerID,i)
end

-- Returns true/false depending if play is climb.
function Player:IsClimbing()
	natives.PLAYER.IS_PLAYER_CLIMBING(self.PlayerID)
end

-- Aimed Entity
function Player:GetAimedEntity()
	local c_handle = Cval:new()
	if not natives.PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(self.PlayerID, c_handle) then
		return nil
	end
	
	-- memory
	local ent_id = c_handle:getInt()
	
	-- return ent
	local ent = Entity:new(ent_id)
	if not ent:Exists() then return nil end
	
	-- proper type
	if ent:IsPed() then
		return Ped:new(ent_id)
	elseif ent:IsVehicle() then
		return Vehicle:new(ent_id)
	elseif ent:IsObject() then
		return Object:new(ent_id)
	end
	return ent
end

-- Gets current Player's radio station ID
function Player:GetRadioStation()
	return natives.AUDIO.GET_PLAYER_RADIO_STATION_INDEX()
end

-- Gets current Player's radio station name
function Player:GetRadioStationName()
	return natives.AUDIO.GET_PLAYER_RADIO_STATION_NAME()
end

