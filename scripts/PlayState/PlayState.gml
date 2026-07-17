enum PlayState {
	MAINMENU,
	PAWSED,
	EDITOR,
	GAME
}

/// @desc  Toggles a given group of layers given by an array.
/// @arg {Array} group The array of layers to toggle.
/// @arg {Bool} hideOrShow Whether or not to hide (false) or show this layer (true).
function toggle_layer_group(group, hideOrShow = false) {
        for (var i = 0; i < array_length(group); i++) {
                layer_set_visible(group[i], hideOrShow);
        }
}

/// @function playstate_change(state)
/// @desc Swaps the current playstate. Will also do things like hide layers, etc. associated with a previous playstate.
/// @arg {enum} state The playstate to swap to.
function playstate_change(state) {
	switch (state) {
        	    case PlayState.GAME:
        			global.playstate = PlayState.GAME;
        	        break;
        		case PlayState.EDITOR:
        			global.playstate = PlayState.EDITOR;
                        break;
        	    case PlayState.MAINMENU:
                                global.playstate = PlayState.MAINMENU;
                        break;
        	}
}

