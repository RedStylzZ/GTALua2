#ifndef __CVAL_H__
#define __CVAL_H__

#include "stdafx.h"
// Cval.h - v1.0
//
// Implements C Value as a Lua Class (metatable)
// (c)2017 by Mockba the Borg
//
// This file is distributed under the "Do whatever
// the fuck you want with it as long as you give
// proper credit" (DWTFYWALAYGPC) license.

// Lua functions to deal with C Value
//-------------------------------------

// Creates a new Lua C Value
static int lCval_new(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)lua_newuserdata(L, 8);
	*cu = NULL;

	luaL_getmetatable(L, "Cval");
	lua_setmetatable(L, -2);

	return(1);
}

// Reads the C Value as Boolean
static int lCval_getBool(lua_State *L) {
	bool *cu;

	cu = (bool *)luaL_checkudata(L, 1, "Cval");
	lua_pushboolean(L, *cu);

	return(1);
}

// Writes the C Value as Boolean
static int lCval_setBool(lua_State *L) {
	bool *cu;

	cu = (bool *)luaL_checkudata(L, 1, "Cval");
	*cu = luaL_checkinteger(L, 2) != 0;

	return(0);
}

// Reads the C Value as Integer
static int lCval_getInt(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cval");
	lua_pushinteger(L, *cu);

	return(1);
}

// Writes the C Value as Integer
static int lCval_setInt(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cval");
	*cu = luaL_checkinteger(L, 2);

	return(0);
}

// Reads the C Value as Float
static int lCval_getFloat(lua_State *L) {
	float *cu;

	cu = (float *)luaL_checkudata(L, 1, "Cval");
	lua_pushnumber(L, *cu);

	return(1);
}

// Writes the C Value as Float
static int lCval_setFloat(lua_State *L) {
	float *cu;

	cu = (float *)luaL_checkudata(L, 1, "Cval");
	*cu = (float)luaL_checknumber(L, 2);

	return(0);
}

// Reads the memory address (pointer) of the C Value
static int lCval_addr(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cval");
	lua_pushinteger(L, (lua_Integer)cu);

	return(1);
}

// Reads the type of the C Value
static int lCval_type(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cval");
	lua_pushstring(L, "Cval");

	return(1);
}

// Register C Value as a Lua class
//-------------------------------------

// Implements:
//	Cval.new()
static const struct luaL_Reg lCval_functions[] = {
	{ "new",	lCval_new	},
	{ NULL,		NULL		}
};

// Implements:
//	Cval:getBool()
//	Cval:setBool(value)
//	Cval:getInt()
//	Cval:setInt(value)
//	Cval:getFlt()
//	Cval:setFlt(value)
//	Cval:addr()
//	Cval:type()
//  Cval:__gc()
static const struct luaL_Reg lCval_methods[] = {
	{ "getBool",	lCval_getBool },
	{ "setBool",	lCval_setBool },
	{ "getInt",		lCval_getInt	},
	{ "setInt",		lCval_setInt	},
	{ "getFloat",	lCval_getFloat	},
	{ "setFloat",	lCval_setFloat	},
	{ "addr",		lCval_addr		},
	{ "type",		lCval_type		},
	{ NULL,			NULL			}
};

// Creates the Cval metatable and makes it global
int register_Cval(lua_State *L) {
	luaL_newmetatable(L, "Cval");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_setfuncs(L, lCval_methods, 0);
	luaL_newlib(L, lCval_functions);

	lua_setglobal(L, "Cval");

	return(1);
}

#endif /* __CVAL_H__ */
