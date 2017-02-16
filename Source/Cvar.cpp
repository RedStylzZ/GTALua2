#include "stdafx.h"
// Cvar - v1.0
//
// Implements C Variable as a Lua Class (metatable)
// (c)2017 by Mockba the Borg
//
// This file is distributed under the "Do whatever
// the fuck you want with it as long as you give
// proper credit" (DWTFYWALAYGPC) license.

// Lua functions to deal with C Variable
//-------------------------------------

// Creates a new Lua C Variable
static int lCvar_new(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)lua_newuserdata(L, 8);
	*cu = NULL;

	luaL_getmetatable(L, "Cvar");
	lua_setmetatable(L, -2);

	return(1);
}

// Reads the C Variable as Boolean
static int lCvar_getBool(lua_State *L) {
	bool *cu;

	cu = (bool *)luaL_checkudata(L, 1, "Cvar");
	lua_pushboolean(L, *cu);

	return(1);
}

// Writes the C Variable as Boolean
static int lCvar_setBool(lua_State *L) {
	bool *cu;

	cu = (bool *)luaL_checkudata(L, 1, "Cvar");
	*cu = luaL_checkinteger(L, 2) != 0;

	return(0);
}

// Reads the C Variable as Integer
static int lCvar_getInt(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cvar");
	lua_pushinteger(L, *cu);

	return(1);
}

// Writes the C Variable as Integer
static int lCvar_setInt(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cvar");
	*cu = luaL_checkinteger(L, 2);

	return(0);
}

// Reads the C Variable as Float
static int lCvar_getFloat(lua_State *L) {
	float *cu;

	cu = (float *)luaL_checkudata(L, 1, "Cvar");
	lua_pushnumber(L, *cu);

	return(1);
}

// Writes the C Variable as Float
static int lCvar_setFloat(lua_State *L) {
	float *cu;

	cu = (float *)luaL_checkudata(L, 1, "Cvar");
	*cu = (float)luaL_checknumber(L, 2);

	return(0);
}

// Reads the memory address (pointer) of the C Variable
static int lCvar_addr(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cvar");
	lua_pushinteger(L, (lua_Integer)cu);

	return(1);
}

// Reads the type of the C Variable
static int lCvar_type(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cvar");
	lua_pushstring(L, "Cvar");

	return(1);
}

// Register C Variable as a Lua class
//-------------------------------------

// Implements:
//	Cvar.new()
static const struct luaL_Reg lCvar_functions[] = {
	{ "new",	lCvar_new	},
	{ NULL,		NULL		}
};

// Implements:
//	Cvar:getBool()
//	Cvar:setBool(value)
//	Cvar:getInt()
//	Cvar:setInt(value)
//	Cvar:getFlt()
//	Cvar:setFlt(value)
//	Cvar:addr()
//	Cvar:type()
//  Cvar:__gc()
static const struct luaL_Reg lCvar_methods[] = {
	{ "getBool",	lCvar_getBool },
	{ "setBool",	lCvar_setBool },
	{ "getInt",		lCvar_getInt	},
	{ "setInt",		lCvar_setInt	},
	{ "getFloat",	lCvar_getFloat	},
	{ "setFloat",	lCvar_setFloat	},
	{ "addr",		lCvar_addr		},
	{ "type",		lCvar_type		},
	{ NULL,			NULL			}
};

// Creates the Cvar metatable and makes it global
int register_Cvar(lua_State *L) {
	luaL_newmetatable(L, "Cvar");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_setfuncs(L, lCvar_methods, 0);
	luaL_newlib(L, lCvar_functions);

	lua_setglobal(L, "Cvar");

	return(1);
}
