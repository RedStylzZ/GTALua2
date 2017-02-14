#pragma once

enum eThreadState
{
	ThreadStateIdle = 0x0,
	ThreadStateRunning = 0x1,
	ThreadStateKilled = 0x2,
	ThreadState3 = 0x3,
	ThreadState4 = 0x4,
};

struct scrThreadContext
{
	int ThreadID;
	int ScriptHash;
	eThreadState State;
	int _IP;
	int FrameSP;
	int _SPP;
	float TimerA;
	float TimerB;
	int TimerC;
	int _mUnk1;
	int _mUnk2;
	int _f2C;
	int _f30;
	int _f34;
	int _f38;
	int _f3C;
	int _f40;
	int _f44;
	int _f48;
	int _f4C;
	int _f50;
	int pad1;
	int pad2;
	int pad3;
	int _set1;
	int pad[17];
};

struct scrThread
{
	void *vTable;
	scrThreadContext m_ctx;
	void *m_pStack;
	void *pad;
	void *pad2;
	const char *m_pszExitMessage;
};

struct ScriptThread : scrThread
{
	char Name[64];
	void *m_pScriptHandler;
	char gta_pad2[40];
	char flag1;
	char m_networkFlag;
	bool bool1;
	bool bool2;
	bool bool3;
	bool bool4;
	bool bool5;
	bool bool6;
	bool bool7;
	bool bool8;
	bool bool9;
	bool bool10;
	bool bool11;
	bool bool12;
	char gta_pad3[10];
};

class Hooking
{
public:
	static void Start(HMODULE hmoduleDLL);
	static void Cleanup();
	static eGameState GetGameState();
	static BlipList* GetBlipList();
	static uint64_t getWorldPtr();
	static void scriptRun();
	static bool HookNatives();
	static HWND getWindow() { return hWindow; }
	static HMODULE getModule() { return _hmoduleDLL; }

	// Native function handler type
	typedef void(__cdecl * NativeHandler)(scrNativeCallContext * context);
	struct NativeRegistration
	{
		NativeRegistration * nextRegistration;
		Hooking::NativeHandler handlers[7];
		uint32_t numEntries;
		uint64_t hashes[7];
	};	
	static NativeHandler GetNativeHandler(uint64_t origHash);

private:
	static BOOL InitializeHooks();
	static void FindPatterns();
	static void FailPatterns(const char* name);
	static HMODULE _hmoduleDLL;
	static HWND hWindow;
};	void WAIT(DWORD ms);
