enum MsgType {
	NORMAL = 0,
	WARN = 1,
	ERROR = 2,
	GAME = 3
}

function Console() constructor {
	enabled = false;
	comHistory = [];
	bgImage = noone;
	productName = "Toolvan Standalone";
	gameMessages = [];
	maxGameMessages = 4;
	gameMsgDuration = 300;
	
	log = function(msg, msgType = MsgType.NORMAL) {
		array_push(comHistory, {text : msg, kind : msgType});
		show_debug_message(msg);
		
		if (msgType == MsgType.GAME) {
			if (array_length(gameMessages) >= maxGameMessages) {
				array_delete(gameMessages, 0, 1);
			}
			array_push(gameMessages, {text : msg, timer : gameMsgDuration});
		}
	};
	
	step = function() {
		var i = 0;
		while (i < array_length(gameMessages)) {
			gameMessages[i].timer--;
			if (gameMessages[i].timer <= 0) {
				array_delete(gameMessages, i, 1);
			} else {
				i++;
			}
		}
	};
	
	toggle = function() {
		if (enabled) {
			enabled = false;
		} else {
			enabled = true;
		}
	};
	
	getEnabled = function() {
		return enabled;
	}
	
	setBgImage = function(spr) {
		bgImage = spr;
	}
	
	clearBgImage = function() {
		bgImage = noone;
	}
	
	// setBgImage(sConsoleBG);
}

// Wrapper functions
function con_log(msg) {
	global.console.log(msg);
}

function con_warn(msg) {
	global.console.log(msg, MsgType.WARN);
}

function con_error(msg) {
	global.console.log(msg, MsgType.ERROR);
}

function con_game(msg) {
	global.console.log(msg, MsgType.GAME);
}

function debug_log(msg) {
	if (global.wantDebug) {
		global.console.log(msg);
	}
}