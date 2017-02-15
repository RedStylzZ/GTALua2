-- Ped
Ped = Entity:new()
Ped_mt = { __index = Ped }

-- Ped CTor
function Ped:new (id)
	local new_inst = {}
	new_inst.ID = id or -1
	setmetatable( new_inst, Ped_mt )
	return new_inst
end

-- Vehicle
function Ped:IsInVehicle()
	self:_CheckExists()
	return natives.PED.IS_PED_IN_ANY_VEHICLE(self.ID, false)
end
function Ped:GetVehicle()
	self:_CheckExists()
	if self:IsInVehicle() then
		local veh = natives.PED.GET_VEHICLE_PED_IS_IN(self.ID, false)
		return Vehicle(veh)
	end
end

