if (instance_number(oCamera) > 1) {
	con_warn("[WARN]: A duplicate camera instance was detected in room" + string(room) + " and was destroyed.");
	instance_destroy(self);
}

view_enabled = true;
view_visible[0] = true;
view_wport[0] = global.resWidth;
view_hport[0] = global.resHeight;
view_xport[0] = 0;
view_yport[0] = 0;

initialized = false;

camera_stop_tracking_all();

viewportNum = 0; 

camera = camera_create();
view_camera[viewportNum] = camera;

if (global.playstate == PlayState.GAME) {
	zoomFactor = DEFAULT_ZOOM;
} else {
	zoomFactor = 1;
}

if (instance_exists(oPlayer)) {
	camera_track_objects(oPlayer);
} 