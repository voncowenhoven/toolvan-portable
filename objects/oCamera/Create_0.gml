// The value the camera will default to if the game is in singleplayer.
#macro DEFAULT_ZOOM 1.5 
// The higher the smoothing, the slower the camera pans. 1 makes this immediate.
#macro SMOOTHING_FACTOR 15 
// How quickly the camera zooms out. 1 = immediate, 0 = never.
#macro ZOOM_SMOOTHING 0.2 
// The amount of padding in pixels around tracked objects.
#macro CAMERA_BORDER 100 

view_enabled = true;
view_visible[0] = true;
view_wport[0] = global.resWidth;
view_hport[0] = global.resHeight;
view_xport[0] = 0;
view_yport[0] = 0;

viewportNum = 0; 

camera = camera_create();
view_camera[viewportNum] = camera;
objectsToTrack = [];
zoomFactor = DEFAULT_ZOOM;
clampsToRoom = true; 
initialized = false; 


	

/// @func camera_track_objects(args...)
/// @param {Asset.GMObject} args... Object(s) to be tracked by the camera.
/// @desc Adds an object to the tracking array, enabling it to be tracked. Multiple objects can be passed. Should work for instances too.
function camera_track_objects() {
	for (var i = 0; i < argument_count; i++) {
		
		if (!instance_exists(argument[i])) {
			con_log("[WARN]: camera_track_objects() was passed an instance that does not exist. Ignoring.");
			continue;
		}
		
		array_push(objectsToTrack, argument[i]);
	}
	return array_length(objectsToTrack);
}

/// @func camera_stop_tracking_objects(args...)
/// @param {Asset.GMObject} args... Object(s) to stop tracking.
function camera_stop_tracking_objects() {
	for (var i = 0; i < argument_count; i++) {
		
		if (!instance_exists(argument[i])) {
			con_log("[WARN]: camera_stop_tracking_objects() was passed an instance that does not exist. Ignoring.");
			continue;
		}
		
		array_remove_element(objectsToTrack, argument[i]);
	}
	
}


function camera_stop_tracking_all() {
	objectsToTrack = [];
}