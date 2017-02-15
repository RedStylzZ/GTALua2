-- Entity class
Entity = {}
Entity_mt = { __index = Entity }

-- Entity CTor
function Entity:new (id)
	local new_inst = {}
	new_inst.ID = id or -1
	setmetatable (new_inst, Entity_mt)
	return new_inst
end

-- Exists
function Entity:Exists ()
	return natives.ENTITY.DOES_ENTITY_EXIST (self.ID)
end
function Entity:_CheckExists ()
	if not self:Exists () then
		error ("Entity " .. self.ID .. " is not valid!")
	end
end

-- Methods

-- Position
function Entity:SetPosition (x, y, z)
	self:_CheckExists ()

	if type (x) == "Vector" then
		z = x.z
		y = x.y
		x = x.x
	end

	natives.ENTITY.SET_ENTITY_COORDS (self.ID, x, y, z, false, false, false, true)
end
function Entity:GetPosition ()
	self:_CheckExists ()
	return natives.ENTITY.GET_ENTITY_COORDS (self.ID, false)
end

-- Velocity
function Entity:SetVelocity (x, y, z)
	self:_CheckExists ()
	if type (x) == "Vector" then
		z = x.z
		y = x.y
		x = x.x
	end

	natives.ENTITY.SET_ENTITY_VELOCITY (self.ID, x, y, z)
end
function Entity:GetVelocity ()
	self:_CheckExists ()
	return natives.ENTITY.GET_ENTITY_VELOCITY (self.ID)
end

-- Heading
function Entity:SetHeading (f)
	self:_CheckExists ()
	natives.ENTITY.SET_ENTITY_HEADING (self.ID, f)
end
function Entity:GetHeading ()
	self:_CheckExists ()
	return natives.ENTITY.GET_ENTITY_HEADING (self.ID)
end

-- Freeze
function Entity:Freeze ()
	self:_CheckExists ()
	natives.ENTITY.FREEZE_ENTITY_POSITION (self.ID, true)
end
function Entity:UnFreeze ()
	self:_CheckExists ()
	natives.ENTITY.FREEZE_ENTITY_POSITION (self.ID, false)
end

-- Health
function Entity:SetHealth (h)
	self:_CheckExists ()
	natives.ENTITY.SET_ENTITY_HEALTH (self.ID, h)
end
function Entity:GetHealth ()
	self:_CheckExists ()
	return natives.ENTITY.GET_ENTITY_HEALTH (self.ID)
end
function Entity:GetMaxHealth ()
	self:_CheckExists ()
	return natives.ENTITY.GET_ENTITY_MAX_HEALTH (self.ID)
end
function Entity:IsDead ()
	self:_CheckExists ()
	return natives.ENTITY.IS_ENTITY_DEAD (self.ID)
end
function Entity:SetInvincible (b)
	self:_CheckExists ()
	natives.ENTITY.SET_ENTITY_INVINCIBLE (self.ID, b)
end

-- Nearest Player
function Entity:GetNearestPlayer ()
	self:_CheckExists ()
	return natives.ENTITY.GET_NEAREST_PLAYER_TO_ENTITY (self.ID)
end

-- Visible
function Entity:IsVisible ()
	self:_CheckExists ()
	return natives.ENTITY.IS_ENTITY_VISIBLE (self.ID)
end
function Entity:SetVisible (b)
	self:_CheckExists ()
	natives.ENTITY.SET_ENTITY_VISIBLE (self.ID, b)
end

-- Model
function Entity:GetModel ()
	self:_CheckExists ()
	return natives.ENTITY.GET_ENTITY_MODEL (self.ID)
end

-- Fire
function Entity:Ignite ()
	self:_CheckExists ()
	natives.FIRE.START_ENTITY_FIRE (self.ID)
end
function Entity:Extinguish ()
	self:_CheckExists ()
	natives.FIRE.STOP_ENTITY_FIRE (self.ID)
end

