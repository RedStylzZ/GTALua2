#include "stdafx.h"
// Cptr - v1.0
//
// Implements C Pointer as a Lua Class (metatable)
// (c)2017 by Mockba the Borg
//
// This file is distributed under the "Do whatever
// the fuck you want with it as long as you give
// proper credit" (DWTFYWALAYGPC) license.

// Lua functions to deal with C Pointer
//-------------------------------------

// Creates a new Lua C Pointer
static int lCptr_new(lua_State *L) {
	intptr_t *cu;

	intptr_t addr = luaL_checkinteger(L, 2);
	cu = (intptr_t *)lua_newuserdata(L, 8);
	*cu = addr;

	luaL_getmetatable(L, "Cptr");
	lua_setmetatable(L, -2);

	return(1);
}

// Reads the C Pointer as Boolean
static int lCptr_getBool(lua_State *L) {
	intptr_t *cu, *addr;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	addr = (intptr_t *)*cu;
	intptr_t offset = (intptr_t)luaL_checkinteger(L, 2);
	lua_pushboolean(L, *(addr + offset) == 1);

	return(1);
}

// Writes the C Pointer as Boolean
static int lCptr_setBool(lua_State *L) {
	intptr_t *cu, *addr;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	addr = (intptr_t *)*cu;
	intptr_t offset = (intptr_t)luaL_checkinteger(L, 2);
	*(addr + offset) = luaL_checkinteger(L, 3) != 0;

	return(0);
}

// Reads the C Pointer as Integer
static int lCptr_getInt(lua_State *L) {
	intptr_t *cu, *addr;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	addr = (intptr_t *)*cu;
	intptr_t offset = (intptr_t)luaL_checkinteger(L, 2);
	lua_pushinteger(L, (int)*(addr + offset));

	return(1);
}

// Writes the C Pointer as Integer
static int lCptr_setInt(lua_State *L) {
	intptr_t *cu, *addr;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	addr = (intptr_t *)*cu;
	intptr_t offset = (intptr_t)luaL_checkinteger(L, 2);
	*(addr + offset) = luaL_checkinteger(L, 3);

	return(0);
}

// Reads the C Pointer as Float
static int lCptr_getFloat(lua_State *L) {
	intptr_t *cu, *addr;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	addr = (intptr_t *)*cu;
	intptr_t offset = (intptr_t)luaL_checkinteger(L, 2);
	lua_pushnumber(L, (float)*(addr + offset));

	return(1);
}

// Writes the C Pointer as Float
static int lCptr_setFloat(lua_State *L) {
	intptr_t *cu;
	float *addr;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	addr = (float *)*cu;
	intptr_t offset = (intptr_t)luaL_checkinteger(L, 2);
	*(addr + offset) = (float)luaL_checknumber(L, 3);

	return(0);
}

// Reads the memory address of the C Pointer
static int lCptr_addr(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	intptr_t addr = *cu;
	lua_pushinteger(L, (lua_Integer)addr);

	return(1);
}

// Writes the memory address of the C Pointer
static int lCptr_set(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	*cu = luaL_checkinteger(L, 2);

	return(0);
}

// Reads the type of the C Pointer
static int lCptr_type(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cptr");
	lua_pushstring(L, "Cptr");

	return(1);
}

// Register C Pointer as a Lua class
//-------------------------------------

// Implements:
//	Cptr.new()
static const struct luaL_Reg lCptr_functions[] = {
	{ "new",	lCptr_new },
	{ NULL,		NULL }
};

// Implements:
//	Cptr:getBool()
//	Cptr:setBool(value)
//	Cptr:getInt()
//	Cptr:setInt(value)
//	Cptr:getFlt()
//	Cptr:setFlt(value)
//	Cptr:addr()
//	Cptr:set()
//	Cptr:type()
//  Cptr:__gc()
static const struct luaL_Reg lCptr_methods[] = {
	{ "getBool",	lCptr_getBool },
	{ "setBool",	lCptr_setBool },
	{ "getInt",		lCptr_getInt },
	{ "setInt",		lCptr_setInt },
	{ "getFloat",	lCptr_getFloat },
	{ "setFloat",	lCptr_setFloat },
	{ "addr",		lCptr_addr },
	{ "set",        lCptr_set },
	{ "type",		lCptr_type },
	{ NULL,			NULL }
};

// Creates the Cptr metatable and makes it global
int register_Cptr(lua_State *L) {
	luaL_newmetatable(L, "Cptr");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_setfuncs(L, lCptr_methods, 0);
	luaL_newlib(L, lCptr_functions);

	lua_setglobal(L, "Cptr");

	return(1);
}
