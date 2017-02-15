#ifndef __CVEC_H__
#define __CVEC_H__

#include "stdafx.h"
// Cvec.h - v1.0
//
// Implements C Vector (x,y,z) as a Lua Class (metatable)
// (c)2017 by Mockba the Borg
//
// This file is distributed under the "Do whatever
// the fuck you want with it as long as you give
// proper credit" (DWTFYWALAYGPC) license.

// Lua functions to deal with C Vector
//-------------------------------------

// Creates a new Lua C Vector
static int lCvec_new(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)lua_newuserdata(L, 24);
	*cu = NULL;

	luaL_getmetatable(L, "Cvec");
	lua_setmetatable(L, -2);

	return(1);
}

// Reads the C Vector X as table of floats
static int lCvec_get(lua_State *L) {
	Vector3 *cu;

	cu = (Vector3 *)luaL_checkudata(L, 1, "Cvec");
	lua_createtable(L, 2, 0);
	lua_pushstring(L, "x");
	lua_pushnumber(L, cu->x);
	lua_settable(L, -3);
	lua_pushstring(L, "y");
	lua_pushnumber(L, cu->y);
	lua_settable(L, -3);
	lua_pushstring(L, "z");
	lua_pushnumber(L, cu->z);
	lua_settable(L, -3);

	return(1);
}

// Writes the C Vector as table of floats
static int lCvec_set(lua_State *L) {
	Vector3 *cu;

	cu = (Vector3 *)luaL_checkudata(L, 1, "Cvec");
	luaL_checktype(L, 2, LUA_TTABLE);
	lua_getfield(L, 1, "x");
	lua_getfield(L, 1, "y");
	lua_getfield(L, 1, "z");

	cu->x = (float)luaL_checknumber(L, -3);
	cu->y = (float)luaL_checknumber(L, -2);
	cu->z = (float)luaL_checknumber(L, -1);
	return(0);
}

// Reads the memory address (pointer) of the C Vector
static int lCvec_addr(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cvec");
	lua_pushinteger(L, (lua_Integer)cu);

	return(1);
}

// Reads the type of the C Vector
static int lCvec_type(lua_State *L) {
	intptr_t *cu;

	cu = (intptr_t *)luaL_checkudata(L, 1, "Cvec");
	lua_pushstring(L, "Cvec");

	return(1);
}

// Register C Vector as a Lua class
//-------------------------------------

// Implements:
//	Cvec.new()
static const struct luaL_Reg lCvec_functions[] = {
	{ "new",	lCvec_new },
	{ NULL,		NULL }
};

// Implements:
//	Cvec:get
//	Cvec:set
//	Cvec:addr()
//	Cvec:type()
//  Cvec:__gc()
static const struct luaL_Reg lCvec_methods[] = {
	{ "get",	lCvec_get },
	{ "set",	lCvec_set },
	{ "addr",	lCvec_addr },
	{ "type",	lCvec_type },
	{ NULL,		NULL }
};

// Creates the Cvec metatable and makes it global
int register_Cvec(lua_State *L) {
	luaL_newmetatable(L, "Cvec");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_setfuncs(L, lCvec_methods, 0);
	luaL_newlib(L, lCvec_functions);

	lua_setglobal(L, "Cvec");

	return(1);
}

#endif /* __CVEC_H__ */
