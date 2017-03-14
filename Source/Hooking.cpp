//Hooking.cpp
#include "stdafx.h"

using namespace Memory;

ScriptThread*(*GetActiveThread)()							= nullptr;
HANDLE mainFiber, scriptFiber;
DWORD wakeAt;
eGameState* 												m_gameState;
uint64_t													m_worldPtr;
__int64**													m_globalPtr;
BlipList*													m_blipList;
Hooking::NativeRegistration**								m_registrationTable;
HMODULE 													Hooking::_hmoduleDLL;
HWND 														Hooking::hWindow;
static std::unordered_map<uint64_t,Hooking::NativeHandler>	m_handlerCache;
enum RunningState { state_running, state_closing, }; RunningState mod_state = state_running;

/* Start Hooking */

void Hooking::Start(HMODULE hmoduleDLL)
{
	_hmoduleDLL = hmoduleDLL;

	// Don't do anything until you see the game window
	printf(WAIT_WINDOW);
	while (!hWindow) {
		hWindow = FindWindow("grcWindow", NULL);
	}
	printf(OK);

	FindPatterns();
	if (!InitializeHooks()) {
		Cleanup();
	} else {
		printf(OK);
	}
}

/* Hooks */

// Initialization
BOOL Hooking::InitializeHooks()
{
	printf(INIT_HOOKS);

	// Init input hook
	if (!iHook.Initialize(hWindow)) {
		printf(FAILED_INIT_INPUTHOOK);
		return FALSE;
	}

	// init native hook
	if (!HookNatives()) {
		printf(FAILED_INIT_NATIVEHOOK);
		return FALSE;
	}

	return TRUE;
}

/* Native Hook Function  */
template <typename T>
bool Native(DWORD64 hash, LPVOID hookFunction, T** trampoline)
{
	if (*reinterpret_cast<LPVOID*>(trampoline) != NULL)
		return true;
	auto originalFunction = Hooking::GetNativeHandler(hash);
	if (originalFunction != 0) {
		MH_STATUS createHookStatus = MH_CreateHook(originalFunction, hookFunction, reinterpret_cast<LPVOID*>(trampoline));
		if (((createHookStatus == MH_OK) || (createHookStatus == MH_ERROR_ALREADY_CREATED)) && (MH_EnableHook(originalFunction) == MH_OK))
		{
			return true;
		}
	}

	return false;
}

Hooking::NativeHandler ORIG_WAIT = NULL;
void* __cdecl MY_WAIT(NativeContext *cxt) {
	ScriptThread* pThread = GetActiveThread();

	if (pThread->m_ctx.ScriptHash == 0x5700179c) {
		if (pThread->m_ctx.State == ThreadStateRunning) {
			Hooking::scriptRun();
		}
	}

	ORIG_WAIT(cxt);
	return cxt;
}

bool Hooking::HookNatives()
{
	return true
	// native hooks	
		&& Native(0x4EDE34FBADD967A6, &MY_WAIT, &ORIG_WAIT)
		;
}

void __stdcall ScriptFunction(LPVOID lpParameter)
{
	try
	{
		ScriptMain();
		SwitchToFiber(mainFiber);
	}
	catch (...)
	{
		printf(FAILED_SCRIPTFIBER);
	}
}

void Hooking::scriptRun()
{
	switch (mod_state)
	{
	case state_running:

	if (!mainFiber)
	{
		mainFiber = ConvertThreadToFiber(nullptr);

		if (!mainFiber)
			mainFiber = GetCurrentFiber();
	}

	if (timeGetTime() < wakeAt) return;
	
	scriptFiber ? SwitchToFiber(scriptFiber) : scriptFiber = CreateFiber(NULL, ScriptFunction, nullptr);

	break;
	case state_closing:
		if (scriptFiber) Cleanup();
		break;
	}
}

/* Pattern Scanning */

void Hooking::FailPatterns(const char* name)
{
	printf(NO_PATTERN, name);
	Cleanup();
}

void Hooking::FindPatterns()
{
	auto p_activeThread =				pattern("E8 ? ? ? ? 48 8B 88 10 01 00 00");
	auto p_blipList =					pattern("4C 8D 05 ? ? ? ? 0F B7 C1");
	auto p_fixVector3Result =			pattern("83 79 18 00 48 8B D1 74 4A FF 4A 18");
	auto p_gameLegals =					pattern("72 1F E8 ? ? ? ? 8B 0D");
	auto p_gameLogos =					pattern("70 6C 61 74 66 6F 72 6D 3A");
	auto p_gameState =					pattern("83 3D ? ? ? ? ? 8A D9 74 0A");
	auto p_modelCheck =					pattern("48 85 C0 0F 84 ? ? ? ? 8B 48 50");
	auto p_modelSpawn =					pattern("48 8B C8 FF 52 30 84 C0 74 05 48");
	auto p_nativeTable =				pattern("76 61 49 8B 7A 40 48 8D 0D");
	auto p_worldPtr =					pattern("48 8B 05 ? ? ? ? 45 ? ? ? ? 48 8B 48 08 48 85 C9 74 07");
	auto p_globalPtr =					pattern("4C 8D 05 ? ? ? ? 4D 8B 08 4D 85 C9 74 11");

	char * c_location = nullptr;
	void * v_location = nullptr;

	// Executable Base Address
	printf(BASE_ADDR, (long long)get_base());

	// Executable End Address
	printf(END_ADDR, (long long)(get_base() + get_size()));	

	// Get game state
	printf(GET_GAME_STATE);
	c_location = p_gameState.count(1).get(0).get<char>(2);
	c_location == nullptr ? FailPatterns("gameState") : m_gameState = reinterpret_cast<decltype(m_gameState)>(c_location + *(int32_t*)c_location + 5);
	printf(OK);

	// Skip game logos
	printf(SKIP_GAME_LOGOS);
	v_location = p_gameLogos.count(1).get(0).get<void>(0);
	v_location == nullptr ? FailPatterns("logoSkip") : Memory::putVP<uint8_t>(v_location, 0xC3);
	printf(OK);

	// Wait for legals
	printf(WAIT_FOR_LEGALS);
	DWORD ticks = GetTickCount();
	while (*m_gameState != GameStateLicenseShit || GetTickCount() < ticks + 5000) Sleep(50);
	printf(OK);

	// Skip game legals
	printf(SKIP_LEGALS);
	v_location = p_gameLegals.count(1).get(0).get<void>(0);
	v_location == nullptr ? FailPatterns("legalsSkip") : Memory::nop(v_location, 2);
	printf(OK);

	// Get vector3 result fixer function
	printf(VECTOR3_FIXER);
	v_location = p_fixVector3Result.count(1).get(0).get<void>(0);
	if (v_location != nullptr) scrNativeCallContext::SetVectorResults = (void(*)(scrNativeCallContext*))(v_location);
	printf(OK);

	// Get native registration table
	printf(NATIVES_REGTABLE);
	c_location = p_nativeTable.count(1).get(0).get<char>(9);
	c_location == nullptr ? FailPatterns("native registration table") : m_registrationTable = reinterpret_cast<decltype(m_registrationTable)>(c_location + *(int32_t*)c_location + 4);
	printf(OK);

	// Get world pointer
	printf(GET_WORLD_POINTER);
	c_location = p_worldPtr.count(1).get(0).get<char>(0);
	c_location == nullptr ? FailPatterns("World Pointer") : m_worldPtr = reinterpret_cast<uint64_t>(c_location) + *reinterpret_cast<int*>(reinterpret_cast<uint64_t>(c_location) + 3) + 7;
	printf(OK);

	// Get global pointer
	printf(GET_GLOBAL_POINTER);
	c_location = p_globalPtr.count(1).get(0).get<char>(0);
	__int64 patternAddr = NULL;
	c_location == nullptr ? FailPatterns("GLobal Pointer") : patternAddr = reinterpret_cast<decltype(patternAddr)>(c_location);
	m_globalPtr = (__int64**)(patternAddr + *(int*)(patternAddr + 3) + 7);
	printf(OK);

	// Get blip list
	printf(GET_BLIP_LIST);
	c_location = p_blipList.count(1).get(0).get<char>(0);
	c_location == nullptr ? FailPatterns("blip List") : m_blipList = (BlipList*)(c_location + *reinterpret_cast<int*>(c_location + 3) + 7);
	printf(OK);

	// Bypass online model requests block
	printf(BYPASS_ONLINE_MODEL);
	v_location = p_modelCheck.count(1).get(0).get<void>(0);
	v_location == nullptr ? FailPatterns("modelCheck") : Memory::nop(v_location, 24);
	printf(OK);

	// Bypass is player model allowed to spawn checks
	printf(BYPASS_PLAYER_MODEL);
	v_location = p_modelSpawn.count(1).get(0).get<void>(8);
	v_location == nullptr ? FailPatterns("modelSpawn") : Memory::nop(v_location, 2);
	printf(OK);

	// Get Active Script Thread
	printf(GET_SCRIPT_THREAD);
	c_location = p_activeThread.count(1).get(0).get<char>(1);
	c_location == nullptr ? FailPatterns("Active Script Thread") : GetActiveThread = reinterpret_cast<decltype(GetActiveThread)>(c_location + *(int32_t*)c_location + 4);
	printf(OK);

	// Initialize Native Hashmap
	printf(INIT_NATIVE_HASHMAP);
	CrossMapping::initNativeMap();
	printf(OK);

	// Check if game is ready
	printf(WAIT_GAME_READY);
	while (*m_gameState != GameStatePlaying) {
		Sleep(100);
	}
	printf(OK);
}

static Hooking::NativeHandler _Handler(uint64_t origHash) {

	uint64_t newHash = CrossMapping::MapNative(origHash);
	if (newHash == 0) {
		return nullptr;
	}

	Hooking::NativeRegistration * table = m_registrationTable[newHash & 0xFF];

	for (; table; table = table->nextRegistration)
	{
		for (uint32_t i = 0; i < table->numEntries; i++)
		{
			if (newHash == table->hashes[i])
			{
				return table->handlers[i];
			}

		}
	}

	return nullptr;
}

Hooking::NativeHandler Hooking::GetNativeHandler(uint64_t origHash)
{
//	auto& handler = m_handlerCache[origHash];
//
//	if (handler == nullptr)
//	{
//		handler = _Handler(origHash);
//	}
//
//	return handler;
	return _Handler(origHash);
}

eGameState Hooking::GetGameState()
{
	return *m_gameState;
}

BlipList* Hooking::GetBlipList()
{
	return m_blipList;
}

uint64_t Hooking::getWorldPtr() {
	return m_worldPtr;
}

__int64** Hooking::getGlobalPtr() {
	return m_globalPtr;
}

void WAIT(DWORD ms)
{
	wakeAt = timeGetTime() + ms;
	SwitchToFiber(mainFiber);
}

/* Clean Up */
void Hooking::Cleanup()
{
	// restore thread
	SwitchToFiber(mainFiber);
	DeleteFiber(scriptFiber);
	scriptFiber = NULL;
	ConvertFiberToThread();

	HANDLE hThread = CreateThread(NULL, THREAD_ALL_ACCESS, [](LPVOID) -> DWORD
	{
		// remove input hook
		iHook.keyboardHandlerUnregister(OnKeyboardMessage); iHook.Remove();

		// Disable the All hooks
		if (MH_DisableHook(MH_ALL_HOOKS) != MH_OK) return 1;
		
		// Remove all hooks
		if (MH_RemoveHook(MH_ALL_HOOKS) != MH_OK) return 1;

		// Uninitialize MinHook.
		if (MH_Uninitialize() != MH_OK) return 1;

		Sleep(1000); FreeLibraryAndExitThread(_hmoduleDLL, 0);
		return 0;
	}, NULL, NULL, NULL);
}

bool Hooking::HookFunction(DWORD64 pAddress, void* pDetour, void** ppOriginal) {
	// Create Hook
	int iResult = MH_CreateHook((void*)pAddress, pDetour, ppOriginal);
	if (iResult != MH_OK) {
		printf("[Memory::HookFunction] MH_CreateHook failed: %p [Error %i]\n", (void *)pAddress, iResult);
		return false;
	}

	// Enable Hook
	iResult = MH_EnableHook((void*)pAddress);
	if (iResult != MH_OK) {
		printf("[Memory::HookFunction] MH_EnableHook failed: %p [Error %i]\n", (void *)pAddress, iResult);
		return false;
	}

	// Success
	return true;
}

bool Hooking::HookLibraryFunction(char* sLibrary, char* sName, void* pDetour, void** ppOriginal) {
	// Module
	HMODULE hModule = GetModuleHandle(sLibrary);
	if (hModule == NULL) {
		printf("[Memory::HookLibraryFunction] Module %s not (yet) loaded!\n", sLibrary);
		return false;
	}

	// Proc
	void* pProc = GetProcAddress(hModule, sName);
	if (pProc == NULL) {
		printf("[Memory::HookLibraryFunction] Module %s has no exported function %s!\n", sLibrary, sName);
		return false;
	}

	// Hook
	return Hooking::HookFunction((DWORD64)pProc, pDetour, ppOriginal);
}
