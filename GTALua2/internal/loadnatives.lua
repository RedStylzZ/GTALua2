-- Loads the native descriptions from natives.h

natives = {}
nativeDescription = {}

local nativesH = LuaFolder().."/API/natives.h"
local namespaces = 0
local nativecount = 0
local namespace = ""

function RegisterNative(namespace, native, hash, nargs, takes, returns)
	nativecount = nativecount + 1
	nativeDescription[namespace][native] = {["hash"]=hash, ["nargs"]=nargs, ["takes"]=takes, ["returns"]=returns}
	x = load("natives."..namespace.."."..native.." = function(...) return CallNative(\""..namespace.."\", \""..native.."\", ...) end")
	x()
end

if file_exists(nativesH) then
	print("Loading native methods from natives.h ...")
	file = io.open(nativesH, "r")
	for line in file:lines() do
		line = trim(line)
		if string.sub(line, 1, 9) == "namespace" then
			local array = explode(" ", line)
			namespace = array[2]
			namespaces = namespaces + 1
			nativeDescription[namespace] = {}
			natives[namespace] = {}
		end
		if string.sub(line, 1, 6) == "static" then
			local array = explode(" ", line)
			local returns = array[2]
			local array2 = explode("(", array[3])
			local native = array2[1]
			local array3 = explode("(", line)
			local array4 = explode(")", array3[3])
			local array5 = explode(",", array4[1])
			local hash = array5[1]
			local array6 = explode(")", array3[2])
			local takes = array6[1]
			local nargs = 0
			if takes ~= "" then
				array9 = {}
				local array7 = explode(",", takes)
				local k, v
				for k, v in pairs(array7) do
					v = trim(v)
					array8 = explode(" ", v)
					array9[k] = array8[1]
					nargs = nargs + 1
				end
				takes = trim(table.concat(array9,","))
			end
			RegisterNative(namespace, native, hash, nargs, takes, returns)
		end
	end
--	print_r(natives)
	file:close()
	print("Detected "..namespaces.." namespaces.")
	print("Loaded "..nativecount.." natives.")
	
-- This is for adding natives that are not present on natives.h
-- These may need to be manually changed when the game version advances
	print("Adding custom natives ...")
	nativecount = 0 
	RegisterNative("VEHICLE", "_GET_VEHICLE_ACCENT_COLOR", 0xB7635E80A5C31BFF, 2, "int,int*", "void")
	RegisterNative("VEHICLE", "_SET_VEHICLE_ACCENT_COLOR", 0x6089CDF6A57F326C, 2, "int,int", "void")
	RegisterNative("VEHICLE", "_GET_VEHICLE_TRIM_COLOR", 0x7D1464D472D32136, 2, "int,int*", "void")
	RegisterNative("VEHICLE", "_SET_VEHICLE_TRIM_COLOR", 0xF40DD601A65F7F19, 2, "int,int", "void")
	print("Added "..nativecount.." custom natives.")

else
	error("File natives.h not found. Cannot continue.")
end
