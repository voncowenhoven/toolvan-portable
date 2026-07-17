if (room == rEditor) {
	playstate_change(PlayState.EDITOR);
	instance_create_layer(0, 0, "Instances", oCamera);
	
	toolvan = new Toolvan();
	toolvan.init();
	
	toolvan.setTool("none");
	
} else {
	con_log("[WARN]: Tried to invoke Toolvan in a room that was not the editor room.");
}