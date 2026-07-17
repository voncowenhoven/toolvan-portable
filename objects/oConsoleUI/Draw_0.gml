var startX = 30;
var startY = 380;
var consoleBottom = 400;
var slideY = -consoleBottom;
var slideSpeed = 30;
var maxTextWidth = global.resWidth - (startX * 2); 

// Game messages (quake-style) always drawn if console is disabled
// (otherwise the console overlaps and they look strange)
if (!global.console.getEnabled()) {
	var gameMsgs = global.console.gameMessages;
	var gameMsgCount = array_length(gameMsgs);
	if (gameMsgCount > 0) {
		draw_set_font(font);
		draw_set_halign(fa_left);
		
		font_enable_effects(font, true, {
			outlineEnable: true,
			outlineColour: c_black,
			outlineDistance: 2
		});
		
		for (var i = 0; i < gameMsgCount; i++) {
			var entry = gameMsgs[i];
			var alpha = min(1, entry.timer / 30);
			draw_set_color(c_white);
			draw_set_alpha(alpha);
			draw_text(startX, 30 + (i * 32), entry.text);
		}
		draw_set_alpha(1);
	}	
}


if (global.console.getEnabled()) {
	font_enable_effects(font, false);
	
	// bg img
	if (global.console.bgImage != noone) {
		var spr = global.console.bgImage;
		
		var surf = surface_create(global.resWidth, consoleBottom);
		surface_set_target(surf);
		draw_clear_alpha(c_black, 0); 
		
		draw_set_color(c_white);
		draw_set_alpha(1);
		draw_sprite_stretched(spr, 0, 0, 0, global.resWidth, consoleBottom);
		
		surface_reset_target();
		
		draw_set_color(c_white);
		draw_set_alpha(0.25);
		draw_surface(surf, 0, 0);
		surface_free(surf);
		draw_set_alpha(1);
	}
	
	// bg
	draw_set_color(bgColor);
	draw_set_alpha(0.6);
	draw_rectangle(0, 0, global.resWidth, consoleBottom, false);
	
	// console txt
	draw_set_font(font);
	draw_set_halign(fa_left);
	
	// product name
	if (global.console.productName != "") {
		draw_set_font(font);
		draw_set_color(textColor);
		draw_set_alpha(1);
		draw_set_halign(fa_right);
		draw_text(global.resWidth - 10, 20, global.console.productName);
		draw_set_halign(fa_left); 
	}
	
	// Pre-wrap all lines so we know total line count before drawing
	var wrappedLines = []; // where each entry: { text: string, kind: msgType }
	
	var n = array_length(global.console.comHistory);
	for (var i = 0; i < n; i++) {
		var entry = global.console.comHistory[i];
		var words = string_split(entry.text, " ");
		var line = "";
		var wCount = array_length(words);
		
		for (var w = 0; w < wCount; w++) {
			var word = words[w];
			var testLine = (line == "") ? word : line + " " + word;
			
			if (string_width(testLine) > maxTextWidth && line != "") {
				// Push completed line and start a new one
				array_push(wrappedLines, { text: line, kind: entry.kind });
				line = word;
			} else {
				line = testLine;
			}
		}
		// Push whatever's left
		if (line != "") {
			array_push(wrappedLines, { text: line, kind: entry.kind });
		}
	}
	
	// Draw lines bottom-up
	var totalLines = array_length(wrappedLines);
	for (var i = 0; i < totalLines; i++) {
		var wEntry = wrappedLines[i];
		var yPos   = startY - ((totalLines - 1 - i) * 32);
		
		// Skip lines that have scrolled above the console area
		if (yPos < 0) continue;
		
		switch (wEntry.kind) {
			case MsgType.WARN:  draw_set_color(c_yellow); break;
			case MsgType.ERROR: draw_set_color(c_red);    break;
			default:                       draw_set_color(textColor); break;
		}
		
		draw_text(startX, yPos, wEntry.text);
	}
	
	draw_set_alpha(1);
}