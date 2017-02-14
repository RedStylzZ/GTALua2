//InputHook.cpp
#include "stdafx.h"

#define GXLPARAM(lp) ((short)LOWORD(lp))
#define GYLPARAM(lp) ((short)HIWORD(lp))

InputHook iHook;
WNDPROC	oWndProc;

static std::set<InputHook::TKeyboardFn> g_keyboardFunctions;

void InputHook::keyboardHandlerRegister(TKeyboardFn function) {

	g_keyboardFunctions.insert(function);
}

void InputHook::keyboardHandlerUnregister(TKeyboardFn function) {

	g_keyboardFunctions.erase(function);
}

bool InputHook::Initialize(HWND hWindow) {

	oWndProc = (WNDPROC)SetWindowLongPtr(hWindow, GWLP_WNDPROC, (__int3264)(LONG_PTR)WndProc);
	if (oWndProc == NULL) {
		return false;
	} else {
		keyboardHandlerRegister(OnKeyboardMessage);
		return true;
	}
}

void InputHook::Remove() {

	SetWindowLongPtr(Hooking::getWindow(), GWLP_WNDPROC, (LONG_PTR)oWndProc);
}

LRESULT APIENTRY WndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_KEYDOWN: case WM_KEYUP: case WM_SYSKEYDOWN: case WM_SYSKEYUP:
		for (auto & function : g_keyboardFunctions) function((DWORD)wParam, lParam & 0xFFFF, (lParam >> 16) & 0xFF, (lParam >> 24) & 1, (uMsg == WM_SYSKEYDOWN || uMsg == WM_SYSKEYUP), (lParam >> 30) & 1, (uMsg == WM_SYSKEYUP || uMsg == WM_KEYUP));
		break;
	}

	return CallWindowProc(oWndProc, hwnd, uMsg, wParam, lParam);

}
