#include "stdafx.h"
// Cmem - v1.0
//
// Implements C Memory as a Lua Class (metatable)
// (c)2017 by Mockba the Borg
//
// This file is distributed under the "Do whatever
// the fuck you want with it as long as you give
// proper credit" (DWTFYWALAYGPC) license.

// Lua functions to deal with C Memory
//-------------------------------------

// Creates a new Lua C Memory
static int lCmem_new(lua_State *L) {
	intptr_t *cu;

	int size = (int)luaL_checkinteger(L, 2);
	cu = (intptr_t *)lua_newuserdata(L, size);
	*cu = NULL;

	luaL_getmetatable(L, "Cmem");
	lua_setmetatable(L, -2);

	return(1);
}

// Reads the C Memory as Boolean
static int lCmem_getBool(lua_State *L) {
	bool *cu;

	cu = (bool *)luaL_checkudata(L, 1, "Cmem");
	lua_pushboolean(L, *(cu + (int)luaL_checkinteger(L, 2)));

	return(1);
}

// Writes the C Memory as Boolean
static int lCmem_setBool(lua_State *L) {
	bool *cu;

	cu = (bool *)luaL_checkudata(L, 1, "Cmem");
	*(cu + (int)luaL_checkinteger(L, 2)) = luaL_checkinteger(L, 3) != 0;

	return(0);
}

// Reads the C Memory as Integer
static int lCmem_getInt(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cmem");
	lua_pushinteger(L, *(cu + (int)luaL_checkinteger(L, 2)));

	return(1);
}

// Writes the C Memory as Integer
static int lCmem_setInt(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cmem");
	*(cu + (int)luaL_checkinteger(L, 2)) = luaL_checkinteger(L, 3);

	return(0);
}

// Reads the C Memory as 32 bit Integer
static int lCmem_getInt32(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cmem");
	lua_pushinteger(L, *(cu + (int32_t)luaL_checkinteger(L, 2)));

	return(1);
}

// Writes the C Memory as 32 bit Integer
static int lCmem_setInt32(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cmem");
	*(cu + (int)luaL_checkinteger(L, 2)) = (int32_t)luaL_checkinteger(L, 3);

	return(0);
}

// Reads the C Memory as Float
static int lCmem_getFloat(lua_State *L) {
	float *cu;

	cu = (float *)luaL_checkudata(L, 1, "Cmem");
	lua_pushnumber(L, *(cu + (int)luaL_checkinteger(L, 2)));

	return(1);
}

// Writes the C Memory as Float
static int lCmem_setFloat(lua_State *L) {
	float *cu;

	cu = (float *)luaL_checkudata(L, 1, "Cmem");
	*(cu + (int)luaL_checkinteger(L, 2)) = (float)luaL_checknumber(L, 3);

	return(0);
}

// Reads the memory address (pointer) of the C Memory
static int lCmem_addr(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cmem");
	lua_pushinteger(L, (lua_Integer)cu);

	return(1);
}

// Reads the type of the C Memory
static int lCmem_type(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cmem");
	lua_pushstring(L, "Cmem");

	return(1);
}

// Register C Memory as a Lua class
//-------------------------------------

// Implements:
//	Cmem.new()
static const struct luaL_Reg lCmem_functions[] = {
	{ "new",	lCmem_new },
	{ NULL,		NULL }
};

// Implements:
//	Cmem:getBool()
//	Cmem:setBool(value)
//	Cmem:getInt()
//	Cmem:setInt(value)
//	Cmem:getInt32()
//	Cmem:setInt32(value)
//	Cmem:getFlt()
//	Cmem:setFlt(value)
//	Cmem:addr()
//	Cmem:type()
//  Cmem:__gc()
static const struct luaL_Reg lCmem_methods[] = {
	{ "getBool",	lCmem_getBool },
	{ "setBool",	lCmem_setBool },
	{ "getInt",		lCmem_getInt },
	{ "setInt",		lCmem_setInt },
	{ "getInt32",	lCmem_getInt32 },
	{ "setInt32",	lCmem_setInt32 },
	{ "getFloat",	lCmem_getFloat },
	{ "setFloat",	lCmem_setFloat },
	{ "addr",		lCmem_addr },
	{ "type",		lCmem_type },
	{ NULL,			NULL }
};

// Creates the Cmem metatable and makes it global
int register_Cmem(lua_State *L) {
	luaL_newmetatable(L, "Cmem");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_setfuncs(L, lCmem_methods, 0);
	luaL_newlib(L, lCmem_functions);

	lua_setglobal(L, "Cmem");

	return(1);
}
