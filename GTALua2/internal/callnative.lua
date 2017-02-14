-- Calls the game native

local AconvTable = {
	BOOL			= "boolean",
	["BOOL*"]		= "userdata",

	Any				= "integer",
	Blip			= "integer",
	Cam				= "integer",
	Entity			= "integer",
	Hash			= "integer",
	Object			= "integer",
	Ped				= "integer",
	Pickup			= "integer",
	Player			= "integer",
	ScrHandle		= "integer",
	Vehicle			= "integer",
	["Any*"]		= "userdata",
	["Blip*"]		= "userdata",
	["Cam*"]		= "userdata",
	["Entity*"]		= "userdata",
	["Hash*"]		= "userdata",
	["Object*"]		= "userdata",
	["Ped*"]		= "userdata",
	["Pickup*"]		= "userdata",
	["Player*"]		= "userdata",
	["ScrHandle*"]	= "userdata",
	["Vehicle*"]	= "userdata",

	int				= "integer",
	float			= "number",
	["int*"]		= "userdata",
	["float*"]		= "userdata",

	void			= "nil",

	["char*"]		= "string",

	Vector3			= "Vector3",
	["Vector3*"]	= "userdata"
}

-- Converts the arg type into Lua type
function Aconv(atype)
	return AconvTable[atype] or "Unknown"
end

-- Effectively calls the native after some sanity check
function CallNative(namespace, native, ...)

	-- Sanity check

	if nativeDescription[namespace] == nil then
		error(namespace.." is not a valid namespace")
	end
	local descr = nativeDescription[namespace][native]
	if descr == nil then
		error(native.." is not a valid native")
	end
	local dnargs = nativeDescription[namespace][native].nargs
	local nargs = select("#", ...)
	if dnargs ~= nargs then
		error(native.." called with "..nargs.." arguments instead of "..dnargs)
	end
	local expected = explode(",", nativeDescription[namespace][native].takes)
	for k,v in pairs({...}) do
		local atype = type(v)
		local etype = expected[k]
		local cetype = Aconv(expected[k])
		if cetype == "Unknown" then
			error("Arg "..k.." of "..namespace.."."..native.." is of Unknown type ("..expected[k]..")")
		end
		if cetype == "integer" then
			cetype = "number"
		end
		if atype ~= cetype then
			error("Arg "..k.." of "..namespace.."."..native.." should be "..etype.."("..cetype.."), got "..atype)
		end
	end
	
	-- Sanity check done, just call the natives
	nativeInit(nativeDescription[namespace][native].hash)

	if nargs > 0 then
		for k,v in pairs({...}) do
			cetype = Aconv(expected[k])
			if cetype == "boolean" then
				nativePushInt(v and 1 or 0)
			end
			if cetype == "integer" then
				nativePushInt(v)
			end
			if cetype == "number" then
				nativePushFloat(v)
			end
			if cetype == "string" then
				nativePushStr(v)
			end
			if cetype == "userdata" then
				nativePushInt(v:addr())
			end
			if cetype == "Vector3" then
				print ("Found parameter Vector3 - not pushing")
			end
			if cetype == "nil" then
				print("Found parameter nil - not pushing")
			end
			if cetype == "Unknown" then
				print ("Error: Found parameter Unknown - not pushing")
			end
		end
	end

	local returns = Aconv(nativeDescription[namespace][native].returns)

	if returns == "boolean" then
		return(nativeCall(1))
	end
	if returns == "integer" then
		return(nativeCall(2))
	end
	if returns == "number" then
		return(nativeCall(3))
	end
	if returns == "string" then
		return(nativeCall(4))
	end
	if returns == "userdata" then
		rvalue = nativeCall(0)
		Pointer = Cptr.new()
		Pointer.address = rvalue
		return(Pointer)
	end
	if returns == "Vector3" then
		return(nativeCall(5))
	end
	if returns == "nil" then
		return(nativeCall(6))
	end
	if returns == "Unknown" then
		print ("Error: Found return == Unknown")
		return(nil)
	end
end
