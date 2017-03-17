#pragma once

#define APP "GTALua2"
#define VERSION "1.2"
#define BUILD __DATE__ "-" __TIME__

#define GAME_VERSION "1.0.1011.1"
#define ONLINE_VERSION "1.38"

#define DLLNAME "iphlpapi.dll"

static const char* texts[] = {
	"Message",
	"Fatal error",
	"=------------------------------------------=\n",
	" Self loading mod v1.0 - by Mockba the Borg\n",
	"ok.\n",
	DLLNAME " proxy: Unable to find original dll!",
	"Press enter to exit the game...",
	"Initializing hooks ... ",
	"\nFailed to initialize MinHook.",
	"\nFailed to initialize InputHook.",
	"\nFailed to initialize NativeHooks.",
	"Failed scriptFiber!",
	"Error finding %s!",
	"baseAddr: 0x%08llx\n",
	"endAddr : 0x%08llx\n",
	"Get game state ... ",
	"Skip game logos ... ",
	"Waiting for legals ... ",
	"Skipping legals ... ",
	"Get Vector3 fixer ... ",
	"Natives registration table ... ",
	"Get world pointer ... ",
	"Get globals pointer ... ",
	"Get blip list ... ",
	"Bypass online model request block ... ",
	"Bypass player model spawning checks ... ",
	"Get active script thread ... ",
	"Initialize native hashmap ... ",
	"Waiting for the game to be ready ... ",
	"Grand Theft Auto V - " APP,
	"Failed to find new hash for 0x%016llx\n",
	"Error %s executing native 0x%016llx at address %p.\n",
	"Enabling MP DLC vehicles ... ",
	"Initializing MinHook ... ",
	"Remapping DLL exports ... ",
	"Creating Mod thread ... ",
	"Waiting for the game window ... ",
	"Hooking OnVehicleCreated ... ",
	"Hooking OnPedCreated ... ",
	"Build time: " __TIMESTAMP__ "\n",
	"Loading OpenIV.asi ... ",
	"Done.\n"
};

#define	MESSAGE					texts[0]
#define FATAL_ERROR				texts[1]
#define DASH					texts[2]
#define MODULE_TITLE			texts[3]
#define OK						texts[4]
#define NO_ORIGINAL_DLL			texts[5]
#define PRESS_ENTER				texts[6]
#define INIT_HOOKS				texts[7]
#define FAILED_INIT_MINHOOK		texts[8]
#define FAILED_INIT_INPUTHOOK	texts[9]
#define FAILED_INIT_NATIVEHOOK	texts[10]
#define FAILED_SCRIPTFIBER		texts[11]
#define NO_PATTERN				texts[12]
#define BASE_ADDR				texts[13]
#define END_ADDR				texts[14]
#define GET_GAME_STATE			texts[15]
#define SKIP_GAME_LOGOS			texts[16]
#define WAIT_FOR_LEGALS			texts[17]
#define SKIP_LEGALS				texts[18]
#define VECTOR3_FIXER			texts[19]
#define NATIVES_REGTABLE		texts[20]
#define GET_WORLD_POINTER		texts[21]
#define GET_GLOBAL_POINTER		texts[22]
#define GET_BLIP_LIST			texts[23]
#define BYPASS_ONLINE_MODEL		texts[24]
#define BYPASS_PLAYER_MODEL		texts[25]
#define GET_SCRIPT_THREAD		texts[26]
#define INIT_NATIVE_HASHMAP		texts[27]
#define WAIT_GAME_READY			texts[28]
#define CONSOLE_TITLE			texts[29]
#define NO_NEW_HASH				texts[30]
#define ERROR_EXECUTING_NATIVE	texts[31]
#define ENABLE_MP_VEHS			texts[32]
#define INIT_MINHOOK			texts[33]
#define REMAP_EXPORTS			texts[34]
#define CREATE_THREAD			texts[35]
#define WAIT_WINDOW				texts[36]
#define ON_VEHICLE_CREATED		texts[37]
#define ON_PED_CREATED			texts[38]
#define BUILT_ON				texts[39]
#define LOADING_OPENIV			texts[40]
#define DONE					texts[41]