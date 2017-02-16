-- Object
Object = Entity:new()
Object_mt = { __index = Object }

-- Object CTor
function Object:new (id)
	local new_inst = {}
	new_inst.ID = id or -1
	new_inst._type = "Object"
	setmetatable( new_inst, Object_mt )
	return new_inst
end

-- Methods

-- Delete
function Object:Delete()
	self:_CheckExists()
	local c_handle = Cvar:new()
	c_handle:setInt(self.ID)
	natives.OBJECT.DELETE_OBJECT(c_handle)
end

--Set not needed
function Object:SetNotNeeded()
	self:_CheckExists()
	local c_handle = Cvar:new()
	c_handle:setInt(self.ID)
	natives.ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(c_handle)
end
