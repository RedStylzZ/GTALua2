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

// -----------------------------------------------------------------------------------

// Functions to export to Lua
static int LuaFolder(lua_State *L) {
	lua_pushstring(L, LUAFOLDER);
	return 1;
}

static int LuaGameVersion(lua_State *L) {
	lua_pushstring(L, GAME_VERSION);
	return 1;
}

static int LuaOnlineVersion(lua_State *L) {
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

static int LuaIsKeyDown(lua_State *L) {
	int key = (int)luaL_checkinteger(L, 1);

	lua_pushboolean(L, KeyDown(key));

	return 1;
}

static int LuaIsKeyJustDown(lua_State *L) {
	int key = (int)luaL_checkinteger(L, 1);

	lua_pushboolean(L, KeyJustDown(key));

	return 1;
}

static int LuaIsKeyJustUp(lua_State *L) {
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
	uint64_t address = (uint64_t)Hooking::getGlobalPtr();

	lua_pushinteger(L, address);

	return 1;
}

static int LuaGlobalPointer(lua_State *L) {
	int index = (int)luaL_checkinteger(L, 1);

	long long **GlobalPointer = (long long**)Hooking::getGlobalPtr();
	lua_pushinteger(L, (uint64_t)&GlobalPointer[index >> 18 & 0x3F][index & 0x3FFFF]);

	return 1;
}

static int LuaJoaat(lua_State *L) {
	const char *arg = luaL_checkstring(L, 1);

	lua_pushinteger(L, (int32_t)GAMEPLAY::GET_HASH_KEY((char *)arg));

	return 1;
}

#define HEXDUMP_COLS 16
static int LuaMemDump(lua_State *L) {
	auto mem = (void*)luaL_checkinteger(L, 1);
	printf("Base: 0x%llx\n", (UINT64)mem);
	unsigned int len = (unsigned int)luaL_checkinteger(L, 2);

	unsigned int i, j;

	for (i = 0; i < len + ((len % HEXDUMP_COLS) ? (HEXDUMP_COLS - len % HEXDUMP_COLS) : 0); i++)
	{
		/* print offset */
		if (i % HEXDUMP_COLS == 0)
		{
			printf("0x%06x: ", i);
		}
		/* print hex data */
		if (i < len)
		{
			printf("%02x ", 0xFF & ((char*)mem)[i]);
		} else /* end of block, just aligning for ASCII dump */
		{
			printf("   ");
		}
		/* print ASCII dump */
		if (i % HEXDUMP_COLS == (HEXDUMP_COLS - 1))
		{
			for (j = i - (HEXDUMP_COLS - 1); j <= i; j++)
			{
				if (j >= len) /* end of block, not really printing */
				{
					putchar(' ');
				} else if (isprint(((char*)mem)[j])) /* printable char */
				{
					putchar(0xFF & ((char*)mem)[j]);
				} else /* other char */
				{
					putchar('.');
				}
			}
			putchar('\n');
		}
	}
	return 0;
}

// -----------------------------------------------------------------------------------

// End program execution
void die(const char *why) {
	printf("%s", why);
	char r = getc(stdin);
	exit(1);
}

// -----------------------------------------------------------------------------------

// Get EntityId from veh/ped creation pointers
typedef DWORD32(__fastcall* GetEntityID_t)(__int64* pEntity);
GetEntityID_t orig_GetEntityID = NULL;

int my_GetEntityID(__int64* pEntity) {
	if (pEntity == NULL || orig_GetEntityID == NULL)
		return 0;

	return orig_GetEntityID(pEntity);
}

// Vehicle creation hooking for OnVehicleCreated event
typedef __int64*(__thiscall* CreateVeh_t)(__int64* pThis, __int64* a2, __int64 a3, __int64 a4, __int64 a5, __int64* a6, bool a7, bool a8);
CreateVeh_t orig_CreateVeh = NULL;

__int64* __fastcall my_CreateVeh(__int64* pThis, __int64* a2, __int64 a3, __int64 a4, __int64 a5, __int64* a6, bool a7, bool a8) {
	__int64 *pVehEntity = orig_CreateVeh(pThis, a2, a3, a4, a5, a6, a7, a8);
	int status;
	status = lua_getglobal(L, "OnVehSpawn");
	if (!status) {
		printf("Failed to fetch Lua OnVehSpawn function: %d - %s\n", status, lua_tostring(L, -1));
		die(PRESS_ENTER);
	}
	lua_pushinteger(L, my_GetEntityID(pVehEntity));
	status = lua_pcall(L, 1, 0, 0);
	if (status) {
		printf("Failed to execute Lua OnVehSpawn function: %d - %s\n", status, lua_tostring(L, -1));
		die(PRESS_ENTER);
	}
	return pVehEntity;
}

// Ped creation hooking for OnPedCreated event
typedef __int64*(__thiscall* CreatePed_t)(__int64* pThis, __int64* a2, __int64 a3, __int64 a4, __int64 a5, __int64* a6, bool a7);
CreatePed_t orig_CreatePed = NULL;

__int64* __fastcall my_CreatePed(__int64* pThis, __int64* a2, __int64 a3, __int64 a4, __int64 a5, __int64* a6, bool a7) {
	__int64 *pPedEntity = orig_CreatePed(pThis, a2, a3, a4, a5, a6, a7);
	int status;
	status = lua_getglobal(L, "OnPedSpawn");
	if (!status) {
		printf("Failed to fetch Lua OnPedSpawn function: %d - %s\n", status, lua_tostring(L, -1));
		die(PRESS_ENTER);
	}
	lua_pushinteger(L, my_GetEntityID(pPedEntity));
	status = lua_pcall(L, 1, 0, 0);
	if (status) {
		printf("Failed to execute Lua OnPedSpawn function: %d - %s\n", status, lua_tostring(L, -1));
		die(PRESS_ENTER);
	}
	return pPedEntity;
}

// -----------------------------------------------------------------------------------

// Initializer function - runs once
void init() {

	L = luaL_newstate();
	luaL_openlibs(L);

	lua_register(L, "LuaFolder", LuaFolder);
	lua_register(L, "GameVersion", LuaGameVersion);
	lua_register(L, "OnlineVersion", LuaOnlineVersion);
	lua_register(L, "nativeInit", LuaNativeInit);
	lua_register(L, "nativePushInt", LuaNativePushInt);
	lua_register(L, "nativePushFloat", LuaNativePushFloat);
	lua_register(L, "nativePushStr", LuaNativePushStr);
	lua_register(L, "nativeCall", LuaNativeCall);
	lua_register(L, "IsKeyDown", LuaIsKeyDown);
	lua_register(L, "IsKeyJustDown", LuaIsKeyJustDown);
	lua_register(L, "IsKeyJustUp", LuaIsKeyJustUp);
	lua_register(L, "ClrScr", LuaClrScr);
	lua_register(L, "FGColor", LuaFGColor);
	lua_register(L, "BGColor", LuaBGColor);
	lua_register(L, "CurPos", LuaCurPos);
	lua_register(L, "Wait", LuaWait);
	lua_register(L, "WorldBase", LuaWorldBase);
	lua_register(L, "GlobalsBase", LuaGlobalsBase);
	lua_register(L, "GlobalPointer", LuaGlobalPointer);
	lua_register(L, "joaat", LuaJoaat);
	lua_register(L, "MemDump", LuaMemDump);

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

// Hookings for the OnVehCreated and OnPedCreated events

	auto pat_GetEntityID = Memory::pattern("48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC 20 8B 15 ? ? ? ? 48 8B F9 48 83 C1 10 33 DB");
	void *pGetEntityID = pat_GetEntityID.count(1).get(0).get<void>(0);
	Hooking::HookFunction((DWORD64)pGetEntityID, &my_GetEntityID, (void**)&orig_GetEntityID);

	printf(ON_VEHICLE_CREATED);
	auto pat_CreateVeh = Memory::pattern("48 8B C4 48 89 58 08 48 89 70 18 48 89 78 20 55 41 54 41 55 41 56 41 57 48 8D 68 B9");
	void *pCreateVeh = pat_CreateVeh.count(2).get(1).get<void>(0);
	Hooking::HookFunction((DWORD64)pCreateVeh, &my_CreateVeh, (void**)&orig_CreateVeh);
	printf(OK);

	printf(ON_PED_CREATED);
	auto pat_CreatePed = Memory::pattern("48 8B C4 48 89 58 08 48 89 68 10 48 89 78 18 41 55");
	void *pCreatePed = pat_CreatePed.count(1).get(0).get<void>(0);
	Hooking::HookFunction((DWORD64)pCreatePed, &my_CreatePed, (void**)&orig_CreatePed);
	printf(OK);
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
	SetTextFGColor(3);
	printf(DASH);
	printf(APP " - v" VERSION " - build: " BUILD "\n");
	printf(DASH);
	SetTextFGColor(7);

	printf("Checking online version ... ");
	version = UNK3::_GET_ONLINE_VERSION();
	printf("[%s] ... ", version);
	if (strcmp(version, ONLINE_VERSION) == 0) {
		printf("supported.\n");
	} else {
		printf("not supported.\n");
		die(PRESS_ENTER);
	}

	main();
}
