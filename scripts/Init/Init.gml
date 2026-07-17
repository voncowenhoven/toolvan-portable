// Very basic template init script

function init() {
	global.console = new Console();
	instance_create_layer(0, 0, "Console", oConsoleUI);
	
	global.playstate = PlayState.MAINMENU;
	global.resWidth = 1920;
	global.resHeight = 1080;
	display_set_gui_size(global.resWidth, global.resHeight);
	
	window_set_size(global.resWidth, global.resHeight);
	
	surface_resize(application_surface, global.resWidth, global.resHeight);
	window_center();
	
	game_set_speed(60, gamespeed_fps);
	
	room_goto(rEditor);
	playstate_change(PlayState.MAINMENU);
	random_set_seed(1112009);
}