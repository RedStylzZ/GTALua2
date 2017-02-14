-- Simple ui implementation
ui = {}

-- Draws a text onscreen with the option to have it blink
function ui.DrawTextUI(text, x, y, font, scale, color, blink)
	font = font or FontChaletComprimeCologne
	scale = scale or .5
	color = color or {r=255, g=255, b=255, a=255}

	local draw = not blink

	if math.floor(game.GetSeconds()/10)%2 == 0 or draw then
		natives.UI.SET_TEXT_FONT(font);
		natives.UI.SET_TEXT_SCALE(0.0, scale);
		natives.UI.SET_TEXT_COLOUR(color.r, color.g, color.b, color.a);
		natives.UI.SET_TEXT_CENTRE(false);
		natives.UI.SET_TEXT_OUTLINE();
		natives.UI.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING");
		natives.UI.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(string.format("%s",text));
		natives.UI.END_TEXT_COMMAND_DISPLAY_TEXT(x, y);
	end
end

