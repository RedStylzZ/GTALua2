#include "stdafx.h"
#include <windows.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <iostream>
#include <fstream>
#ifndef _USE_OLD_IOSTREAMS
using namespace std;
#endif

// maximum mumber of lines the output console should have
static const WORD MAX_CONSOLE_LINES = 500;

void ConsoleAttach() {
	// Attach
	AllocConsole();
	AttachConsole(GetCurrentProcessId());

	// Relay Input/Output
	FILE* x;
	freopen_s(&x, "CONOUT$", "w", stdout);
	freopen_s(&x, "CONIN$", "r", stdin);

	// Title
	HWND hConsole = GetConsoleWindow();
	string title = TEXT(CONSOLE_TITLE);
	SetConsoleTitle(title.c_str());

	// Position
	RECT rect;
	GetWindowRect(hConsole, &rect);
	SetWindowPos(hConsole, NULL, 20, 20, 800, 600, 0);
}

void SetTextFGColor(int textColor) {
	HANDLE cOutHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO cBufferInfo;
	GetConsoleScreenBufferInfo(cOutHandle, &cBufferInfo);
	WORD attributes = cBufferInfo.wAttributes & ~FOREGROUND_RED & ~FOREGROUND_GREEN & ~FOREGROUND_BLUE & ~FOREGROUND_INTENSITY;
	attributes |= textColor;
	SetConsoleTextAttribute(cOutHandle, attributes);
}

void SetTextBGColor(int textColor) {
	HANDLE cOutHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO cBufferInfo;
	GetConsoleScreenBufferInfo(cOutHandle, &cBufferInfo);
	WORD attributes = cBufferInfo.wAttributes & ~BACKGROUND_RED & ~BACKGROUND_GREEN & ~BACKGROUND_BLUE & ~BACKGROUND_INTENSITY;
	attributes |= textColor;
	SetConsoleTextAttribute(cOutHandle, attributes);
}

void PositionCursor(int CursorX, int CursorY) {
	HANDLE cOutHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	COORD cCursorPosition;
	cCursorPosition.X = CursorX;
	cCursorPosition.Y = CursorY;
	SetConsoleCursorPosition(cOutHandle, cCursorPosition);
}

void ClearConsole(void) {
	system("cls");
}
