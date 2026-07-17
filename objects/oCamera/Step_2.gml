// Find the bounding rectangle that contains all tracked instances, padded by CAMERA_BORDER,
// then adjust the camera's position and zoom to fit it.

var leftmostX = xprevious;
var rightmostX = xprevious;
var topY = yprevious;
var bottomY = yprevious;

var firstObject = true;

if (array_length(objectsToTrack) == 0) {
	// Nothing to track (menus, cutscenes, et al.), so hold where we are instead of collapsing to a degenerate rect
	// built from mismatched axes
	xTo = x;
	yTo = y;
} else {
	for (var i = 0; i < array_length(objectsToTrack); i++) {
	        var tracked = objectsToTrack[i];
	        with (tracked) {
	                if (firstObject) {
	                        leftmostX = bbox_left;
	                        rightmostX = bbox_right;
	                        topY = bbox_top;
	                        bottomY = bbox_bottom;
	                        firstObject = false;
	                } else {
	                        if (bbox_left < leftmostX) {
	                                leftmostX = bbox_left;
	                        }
	                        if (bbox_right > rightmostX) {
	                                rightmostX = bbox_right;
	                        }
	                        if (bbox_top < topY) {
	                                topY = bbox_top;
	                        }
	                        if (bbox_bottom > bottomY) {
	                                bottomY = bbox_bottom;
	                        }
	                }
        }
}	
}


// Apply padding before any clamping
rightmostX += CAMERA_BORDER / 2;
leftmostX -= CAMERA_BORDER / 2;
topY -= CAMERA_BORDER / 2;
bottomY += CAMERA_BORDER / 2;

var rectWidth = rightmostX - leftmostX;
var rectHeight = bottomY - topY;

// If enabled, keep the rectangle within the room so its center (xTo/yTo) stays in bounds
if (clampsToRoom) {
        if (rectWidth > room_width) {
                rectWidth = room_width;
        }
        if (rectHeight > room_height) {
                rectHeight = room_height;
        }
        if (rightmostX > room_width) {
                rightmostX = room_width;
        }
        if (leftmostX < 0) {
                leftmostX = 0;
        }
        if (topY < 0) {
                topY = 0;
        }
        if (bottomY > room_height) {
                bottomY = room_height;
        }
}

xTo = (rightmostX + leftmostX) / 2;
yTo = (bottomY + topY) / 2;

// Ratio between the bounding rect (with border) and the viewport determines the zoom factor
var xFactor = rectWidth / view_wport[viewportNum];
var yFactor = rectHeight / view_hport[viewportNum];
var factor = max(xFactor, yFactor);

zoomFactor = lerp(zoomFactor, max(DEFAULT_ZOOM, factor), ZOOM_SMOOTHING);

var newHres = view_wport[viewportNum] * zoomFactor;
var newVres = view_hport[viewportNum] * zoomFactor;

if (!initialized) {
        // Snap to the starting position instead of gliding in from the origin
        x = xTo;
        y = yTo;
        initialized = true;
} else {
        x += (xTo - x) / SMOOTHING_FACTOR;
        y += (yTo - y) / SMOOTHING_FACTOR;
}

if (clampsToRoom) {
        x = clamp(x, newHres / 2, room_width - newHres / 2);
        y = clamp(y, newVres / 2, room_height - newVres / 2);
}

var vm = matrix_build_lookat(x, y, -10, x, y, 0, 0, 1, 0);
var pm = matrix_build_projection_ortho(view_wport[viewportNum] * zoomFactor, view_hport[viewportNum] * zoomFactor, -10000, 10000);

camera_set_view_mat(camera, vm);
camera_set_proj_mat(camera, pm);

