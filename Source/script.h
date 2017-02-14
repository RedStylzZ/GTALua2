#pragma once

#define LUAFOLDER "GTALUA2"
#define LUAMAIN LUAFOLDER "\\main.lua"

enum TextColor
{
	Black,
	Blue,
	Green,
	Aqua,
	Red,
	Purple,
	Yellow,
	White,
	Gray,
	LightBlue,
	LightGreen,
	LightAqua,
	LightRed,
	LightPurple,
	LightYellow,
	LightWhite
};

void ConsoleAttach();
void SetTextFGColor(int textColor);
void SetTextBGColor(int textColor);
void PositionCursor(int CursorX, int CursorY);
void ClearConsole(void);
void ScriptMain();
