-- Game specific functions
game = {}

-- IsPaused
function game.IsPaused()
	return natives.UI.IS_PAUSE_MENU_ACTIVE()
end

-- Time - hours
function game.GetHours()
	return natives.TIME.GET_CLOCK_HOURS()
end

-- Time - minutes
function game.GetMinutes()
	return natives.TIME.GET_CLOCK_MINUTES()
end

-- Time - seconds
function game.GetSeconds()
	return natives.TIME.GET_CLOCK_SECONDS()
end

-- Set game TimerA
function game.SetTimerA(n)
	natives.SYSTEM.SETTIMERA(n)
end

-- Set game TimerB
function game.SetTimerB(n)
	natives.SYSTEM.SETTIMERB(n)
end

-- Get game TimerA
function game.GetTimerA()
	return natives.SYSTEM.TIMERA()
end

-- Get game TimerB
function game.GetTimerB()
	return natives.SYSTEM.TIMERB()
end

