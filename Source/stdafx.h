// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers

//#define OpenIV	// Define OpenIV to load OpenIV.asi and allow GTALua2 to work on modded .RPF files.

// Windows Library Files:
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "Winmm.lib")

// Windows Header Files:
#include <windows.h>
#include <Mmsystem.h>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <unordered_map>
#include <algorithm>
#include <functional>
#include <Psapi.h>
#include <MinHook.h>
#include <timeapi.h>
#include <time.h>
#include <intrin.h>

// Additional Header Files:
#include "Memory.h"
#include "types.h"
#include "enums.h"
#include "InputHook.h"
#include "keyboard.h"
#include "CrossMapping.h"
#include "NativeInvoker.h"
#include "nativeCaller.h"
#include "natives.h"
#include "Hooking.h"
#include "script.h"
#include "Texts.h"
#include "MemDump.h"

#include "lua\lua.hpp"
#include "Cvar.h"
#include "Cvec.h"
#include "Cmem.h"
#include "Cptr.h"