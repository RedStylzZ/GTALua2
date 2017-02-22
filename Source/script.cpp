// GTALua2 - Script base - by Mockba the Borg
//
// Implements Lua 5.3.4 onto GTA:V and GTA:O
// (c)2017 by Mockba the Borg
//
// This file is distributed under the "Do whatever
// the fuck you want with it as long as you give
// proper credit" (DWTFYWALAYGPC) license.
//
// Credits:
// Infamous Team for the hook code base
// Jan S. (Freeaky) for GTALua and awesomeness
//
#include "stdafx.h"

lua_State *L;

// Functions to export to Lua
static int LuaFolder(lua_State *L) {
	lua_pushstring(L, LUAFOLDER);
	return 1;
}

static int GameVersion(lua_State *L) {
	lua_pushstring(L, GAME_VERSION);
	return 1;
}

static int OnlineVersion(lua_State *L) {
	lua_pushstring(L, ONLINE_VERSION);
	return 1;
}

static int LuaNativeInit(lua_State *L) {
	UINT64 native = luaL_checkinteger(L, 1);

	nativeInit(native);
	return 0;
}

static int LuaNativePushInt(lua_State *L) {
	UINT64 arg = (UINT64)luaL_checknumber(L, 1);

	nativePush64(arg);

	return 0;
}

static int LuaNativePushFloat(lua_State *L) {
	float arg = (float)luaL_checknumber(L, 1);
	UINT64 *floatAddr = (UINT64 *)&arg;

	nativePush64(*floatAddr);

	return 0;
}

static int LuaNativePushStr(lua_State *L) {
	const char *arg = luaL_checkstring(L, 1);

	nativePush64((UINT64)arg);

	return 0;
}

template <typename T>
static inline T Call() {
	return *reinterpret_cast<T *>(nativeCall());
}

static int LuaNativeCall(lua_State *L) {
	lua_Integer arg = luaL_checkinteger(L, 1);
	Vector3 vector;
	int count = 1;

	switch (arg) {
	case 0:	// Pointer
		lua_pushinteger(L, (lua_Integer)nativeCall());
		break;
	case 1:	// Boolean
		lua_pushboolean(L, Call<bool>());
		break;
	case 2:	// Integer
		lua_pushinteger(L, Call<__int32>());
		break;
	case 3:	// Number
		lua_pushnumber(L, Call<float>());
		break;
	case 4:	// String
		lua_pushstring(L, Call<const char *>());
		break;
	case 5: // Vector3
		vector = Call<Vector3>();
		lua_createtable(L, 2, 0);
		lua_pushstring(L, "x");
		lua_pushnumber(L, vector.x);
		lua_settable(L, -3);
		lua_pushstring(L, "y");
		lua_pushnumber(L, vector.y);
		lua_settable(L, -3);
		lua_pushstring(L, "z");
		lua_pushnumber(L, vector.z);
		lua_settable(L, -3);
		break;
	case 6: // nil (void)
		Call<int>();
		count = 0;
		break;
	default: // Undefined
		lua_pushnil(L);
		break;
	}

	return count;
}

static int IsKeyDown(lua_State *L) {
	int key = (int)luaL_checkinteger(L, 1);

	lua_pushboolean(L, KeyDown(key));

	return 1;
}

static int IsKeyJustDown(lua_State *L) {
	int key = (int)luaL_checkinteger(L, 1);

	lua_pushboolean(L, KeyJustDown(key));

	return 1;
}

static int IsKeyJustUp(lua_State *L) {
	int key = (int)luaL_checkinteger(L, 1);

	lua_pushboolean(L, KeyJustUp(key));

	return 1;
}

static int LuaFGColor(lua_State *L) {
	int color = (int)luaL_checkinteger(L, 1);

	SetTextFGColor(color);

	return 0;
}

static int LuaBGColor(lua_State *L) {
	int color = (int)luaL_checkinteger(L, 1);

	SetTextBGColor(color);

	return 0;
}

static int LuaCurPos(lua_State *L) {
	int curX = (int)luaL_checkinteger(L, 1);
	int curY = (int)luaL_checkinteger(L, 2);

	PositionCursor(curX, curY);

	return 0;
}

static int LuaClrScr(lua_State *L) {

	ClearConsole();

	return 0;
}

static int LuaWait(lua_State *L) {
	int ms = (int)luaL_checkinteger(L, 1);

	WAIT(ms);

	return 0;
}

static int LuaWorldBase(lua_State *L) {
	uint64_t address = Hooking::getWorldPtr();

	lua_pushinteger(L, address);

	return 1;
}

static int LuaGlobalsBase(lua_State *L) {
	uint64_t address = Hooking::getGlobalPtr();

	lua_pushinteger(L, address);

	return 1;
}

static int LuaGlobalPointer(lua_State *L) {
	int index = (int)luaL_checkinteger(L, 1);

	long long **GlobalPointer = (long long**)Hooking::getGlobalPtr();
	lua_pushinteger(L, (uint64_t)&GlobalPointer[index >> 18][index & 0x3FFFF]);

	return 1;
}

// End program execution
void die(const char *why) {
	printf("%s", why);
	char r = getc(stdin);
	exit(1);
}

// Initializer function - runs once
void init() {
	L = luaL_newstate();
	luaL_openlibs(L);

	lua_register(L, "LuaFolder", LuaFolder);
	lua_register(L, "GameVersion", GameVersion);
	lua_register(L, "OnlineVersion", OnlineVersion);
	lua_register(L, "nativeInit", LuaNativeInit);
	lua_register(L, "nativePushInt", LuaNativePushInt);
	lua_register(L, "nativePushFloat", LuaNativePushFloat);
	lua_register(L, "nativePushStr", LuaNativePushStr);
	lua_register(L, "nativeCall", LuaNativeCall);
	lua_register(L, "IsKeyDown", IsKeyDown);
	lua_register(L, "IsKeyJustDown", IsKeyJustDown);
	lua_register(L, "IsKeyJustUp", IsKeyJustUp);
	lua_register(L, "ClrScr", LuaClrScr);
	lua_register(L, "FGColor", LuaFGColor);
	lua_register(L, "BGColor", LuaBGColor);
	lua_register(L, "CurPos", LuaCurPos);
	lua_register(L, "Wait", LuaWait);
	lua_register(L, "WorldBase", LuaWorldBase);
	lua_register(L, "GlobalsBase", LuaGlobalsBase);
	lua_register(L, "GlobalPointer", LuaGlobalPointer);

	register_Cmem(L);
	register_Cvar(L);
	register_Cvec(L);
	register_Cptr(L);

	printf("Lua version is %s\n", LUA_VERSION_MAJOR "." LUA_VERSION_MINOR "." LUA_VERSION_RELEASE);

	int status;
	status = luaL_loadfile(L, LUAMAIN);
	if (status) {
		printf("Error!\nCouldn't load main file: %s\n", lua_tostring(L, -1));
		die(PRESS_ENTER);
	}
	status = lua_pcall(L, 0, LUA_MULTRET, 0);
	if (status) {
		printf("Error!\nFailed to execute main file: %s\n", lua_tostring(L, -1));
		die(PRESS_ENTER);
	}
}

// Updater function - runs every frame
void update() {

	int status;
	status = lua_getglobal(L, "Run");
	if (!status) {
		printf("Failed to fetch Lua Run function: %d - %s\n", status, lua_tostring(L, -1));
		die(PRESS_ENTER);
	}

	status = lua_pcall(L, 0, 0, 0);
	if (status) {
		printf("Failed to execute Lua Run function: %d - %s\n", status, lua_tostring(L, -1));
		die(PRESS_ENTER);
	}

}

// Main program
void main() {
	init();

	while (true) {
		update();
		WAIT(0);
	}
}

// Main script code
void ScriptMain() {
	srand(GetTickCount());

	char *version;

	system("cls");
	printf(DASH);
	printf(APP " - v" VERSION " - build: " BUILD "\n");
	printf(DASH);

	printf("Checking online version...");
	version = UNK3::_GET_ONLINE_VERSION();
	printf("[%s]...", version);
	if (strcmp(version, ONLINE_VERSION) == 0) {
		printf("supported.\n");
	} else {
		printf("not supported.\n");
		die(PRESS_ENTER);
	}

	main();
}
