-- Ped
Ped = Entity:new()
Ped_mt = { __index = Ped }

-- Ped CTor
function Ped:new (id)
	local new_inst = {}
	new_inst.ID = id or -1
	new_inst._type = "Ped"
	setmetatable( new_inst, Ped_mt )
	return new_inst
end

-- Methods

-- Delete
function Ped:Delete()
	self:_CheckExists()
	local c_handle = Cvar:new()
	c_handle:setInt(self.ID)
	natives.PED.DELETE_PED(c_handle)
end

--Set not needed
function Ped:SetNotNeeded()
	self:_CheckExists()
	local c_handle = Cvar:new()
	c_handle:setInt(self.ID)
	natives.ENTITY.SET_PED_AS_NO_LONGER_NEEDED(c_handle)
end

-- Weapon Switching
function Ped:AllowWeaponSwitching(b)
	self:_CheckExists()
	b = b or true
	
	natives.PED.SET_PED_CAN_SWITCH_WEAPON(self.ID, b)
end

-- Weapon
function Ped:GiveWeapon(wep, ammo)
	self:_CheckExists()
	if type(wep) == "string" then
		wep = natives.GAMEPLAY.GET_HASH_KEY(wep)
	end
	natives.WEAPON.GIVE_WEAPON_TO_PED(self.ID, wep, ammo, 0, false)
end

function Ped:GiveDelayedWeapon(wep)
	self:_CheckExists()
	if type(wep) == "string" then
		wep = natives.GAMEPLAY.GET_HASH_KEY(wep)
	end
	natives.WEAPON.GIVE_DELAYED_WEAPON_TO_PED(self.ID, wep, 600, false)
end

function Ped:RemoveWeapon(wep)
	self:_CheckExists()
	if type(wep) == "string" then
		wep = natives.GAMEPLAY.GET_HASH_KEY(wep)
	end
	natives.WEAPON.REMOVE_WEAPON_FROM_PED(self.ID, wep)
end

function Ped:RemoveAllWeapons()
	self:_CheckExists()
	natives.WEAPON.REMOVE_ALL_PED_WEAPONS(self.ID, true)
end

function Ped:GiveWeaponComponent(wep, comp)
	self:_CheckExists()
	if type(wep) == "string" then
		wep = natives.GAMEPLAY.GET_HASH_KEY(wep)
	end
	if type(comp) == "string" then
		comp = natives.GAMEPLAY.GET_HASH_KEY(comp)
	end
	natives.WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(self.ID, wep, comp)
end

-- Group Member
function Ped:AddGroupMember(other_ped)
	self:_CheckExists()
	local group_id = other_ped
	if type(other_ped) == "Ped" or type(other_ped) == "Player" then
		group_id = other_ped:GetGroupIndex()
	end
	natives.PED.SET_PED_AS_GROUP_MEMBER(self.ID, group_id)
end
function Ped:GetGroupIndex()
	self:_CheckExists()
	return natives.PED.GET_PED_GROUP_INDEX(self.ID)
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
		return Vehicle:new(veh)
	end
end

-- Armour
function Ped:SetArmour(i)
	self:_CheckExists()
	natives.PED.SET_PED_ARMOUR(self.ID, i)
end
Ped.SetArmor = Ped.SetArmour
function Ped:GetArmour()
	self:_CheckExists()
	return natives.PED.GET_PED_ARMOUR(self.ID)
end
Ped.GetArmor = Ped.GetArmour

-- Money
function Ped:SetMoney(i)
	self:_CheckExists()
	natives.PED.SET_PED_MONEY(self.ID, i)
end
function Ped:GetMoney()
	self:_CheckExists()
	return natives.PED.GET_PED_MONEY(self.ID)
end

-- Type
function Ped:GetType()
	self:_CheckExists()
	return natives.PED.GET_PED_TYPE(self.ID)
end

-- Nearby Peds
function Ped:GetNearbyPeds(max_peds)
	self:_CheckExists()
	
	-- default value
	max_peds = max_peds or 50
	
	-- c array
	local array_size = max_peds + 1
	local c_array_peds = Cmem:new(array_size * 8)
	c_array_peds:setInt(0, max_peds)

	-- call native
	local found=natives.PED.GET_PED_NEARBY_PEDS(self.ID, c_array_peds, -1)
	
	-- check returned peds
	local nearby_peds = {}
	local i=0
	while i<found do
		offset = (i+1)*2
		local ped = Ped:new(c_array_peds:getInt(offset))
		if ped:Exists() then
			table.insert(nearby_peds, ped)
		end
		i=i+1
	end
	
	return nearby_peds
end

-- Nearby Vehicles
function Ped:GetNearbyVehicles(max_vehicles)
	self:_CheckExists()
	
	-- default value
	max_vehicles = max_vehicles or 50
	
	-- c array
	local array_size = max_vehicles + 1
	local c_array_vehicles = Cmem:new(array_size * 8)
	c_array_vehicles:setInt(0, max_vehicles)
	
	-- call native
	local found=natives.PED.GET_PED_NEARBY_VEHICLES(self.ID, c_array_vehicles)
	
	-- check
	local nearby_vehicles = {}
	local i=0
	while i<found do
		offset = (i+1)*2
		local veh = Vehicle:new(c_array_vehicles:getInt(offset))
		if veh:Exists() then
			table.insert(nearby_vehicles, veh)
		end
		i=i+1
	end
	
	return nearby_vehicles
end

-- Set Ped into specified vehicle's seat
function Ped:SetIntoVehicle(vehicle, seat)
	self:_CheckExists()
	natives.PED.SET_PED_INTO_VEHICLE(self.ID, vehicle, seat)
end

-- Explode Ped's head
function Ped:ExplodeHead(weapon)
	self:_CheckExists()
	natives.PED.EXPLODE_PED_HEAD(self.ID, weapon)
end

