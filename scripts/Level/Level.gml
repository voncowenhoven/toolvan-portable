#macro LEVEL_SAVE_REVISION "r0003"

// The path that enemies use for pathfind. Generated at runtime.
global.pathGrid = undefined;

/// @desc Represents an actual game level, including associated tile, instance etc. data
function Level() constructor {
	room_width = 5000;
	room_height = 5000;
	
	instanceData = [];
	tileData = [];
	missionData = undefined;
	undovan = new Undovan();
	
	saveCurrentLevel = function() {
		con_game("[Toolvan] Starting mission save");
		
		var startTime = get_timer();
		
		if (global.currentLevelPath == "") {
			var levelName = "mylevel";
			
			var level = get_save_filename_ext("Toolvan Level (*.vanna)|*.vanna", levelName, DEVPATH, "Save your mission file...");
			
			if (level == "") {
				show_message_async("You cannot save a mission file with no name.");
				return;
			}	
			
			global.currentLevelPath = level;
		}
		
		var file = file_text_open_write(global.currentLevelPath);
		
		var missionInfo = json_stringify({
			version : LEVEL_SAVE_REVISION,
			width : room_width,
			height : room_height,
			instances : saveInstances(),
			tiles : saveTiles(),
			mission : saveMission()
		}, true);
		
		file_text_write_string(file, missionInfo);
		
		file_text_close(file);
		
		show_debug_message(missionInfo);
		
		var elapsedTime = get_timer() - startTime;
		elapsedTime /= 1000;
	
		con_game("[Toolvan] mission save took " + string(elapsedTime) + " ms");
	}
	
	saveLevelAs = function() {
		global.currentLevelPath = "";
		saveCurrentLevel();
	}
	
	loadLevel = function() {
		con_game("[Toolvan] Starting mission load");
		
		var startTime = get_timer();
		
		var level = get_open_filename_ext("Toolvan Level (*.vanna)|*.vanna", "", DEVPATH, "Select a mission file to load...");
		
		if (level == "") {
			return;
		}
		
		var json = "";
		var file = file_text_open_read(level);
		
		while (!file_text_eof(file)) {
			json += file_text_read_string(file);
			file_text_readln(file);
		}
		
		file_text_close(file);
		
		try {
			var info = json_parse(json);	
		} catch (ex) {
			show_message_async(@"The level could not be loaded due to data corruption. Check that you are loading a valid .VANNA file.");
			return;
		}
		
		if (info.version != LEVEL_SAVE_REVISION) {
			    var msg = 
			        "Your mission file is version " + string(info.version) +
			        ", but the current mission format version is " + string(LEVEL_SAVE_REVISION) + "." +
			        "\nLoading this file could crash Supermelon." +
			        "\nAre you sure you want to continue?";
			
			    if (!show_question_async(msg)) {
			        return;
			    } 
			}
		
		applyLevelData(info);
		
		var elapsedTime = get_timer() - startTime;
		elapsedTime /= 1000;
	
		global.currentLevelPath = level;
		
		con_game("[Toolvan] Mission load took " + string(elapsedTime) + " ms");
	};
	
	/// @desc Similar to loadLevel, but takes a compiled Toolvan file and strips out all the editor-specific stuff. Meant for loading levels in normal playstate.
	/// @param {Pointer} name The name of the Toolvan file.
	/// @returns The level json.
	loadLevelFromName = function(name) {
		var json = "";
		var file = file_text_open_read(name);
		
		var startTime = get_timer();
		
		while (!file_text_eof(file)) {
			json += file_text_read_string(file);
			file_text_readln(file);
		}
		
		file_text_close(file);
		
		info = json_parse(json);	
		
		applyLevelData(info);
		
		var elapsedTime = get_timer() - startTime;
		elapsedTime /= 1000;
		
		con_log("[Toolvan] Mission load took " + string(elapsedTime) + " ms");
		return info;
		
	}
	
	saveInstances = function() {
		return instanceData;
	}
	
	saveTiles = function() {
		return tileData;
	}
	
	saveMission = function() {
		return missionData;
	}
	
	parseJsonFile = function(path) {
		var json = "";
		var file = file_text_open_read(path);
		while (!file_text_eof(file)) {
			json += file_text_read_string(file);
			file_text_readln(file);
		}
		file_text_close(file);
		return json_parse(json);
	};

	killEmAll = function() {
		destroy_everyone_but_the_chosen();
		
		var tilemap = layer_tilemap_get_id("Tiles");
		if (tilemap != -1) {
			tilemap_clear(tilemap, 0);
		}
		
		var tilemapBackground = layer_tilemap_get_id("TilesBackground");
		if (tilemapBackground != -1) {
			tilemap_clear(tilemapBackground, 0);
		}
		
		instanceData = [];
		tileData = [];
		missionData = undefined;
	}	
	
	
	applyLevelData = function(info) {
		killEmAll();
		
		room_width = info.width;
		room_height = info.height;
		
		for (var i = 0; i < array_length(info.instances); i++) {
			var inst = info.instances[i];
			array_push(instanceData, inst);
			instance_create_layer(inst.ix, inst.iy, "Instances", inst.index);
		}
		
		// This is essentially a "happy accident" hack. Calling the tile tool, even
		// in an undefined way, will just call applyTheme from the constructor.
		for (var i = 0; i < array_length(info.tiles); i++) {
			if (variable_struct_exists(info.tiles[i], "theme")) {
				var toolTiles = new ToolTiles(undefined);
				toolTiles.currentThemeIndex = info.tiles[i].theme;
				break;
			} 
	}
		
		for (var i = 0; i < array_length(info.tiles); i++) {
			var tile = info.tiles[i];
			array_push(tileData, tile);
			
			var layerName = "Tiles";
			if (variable_struct_exists(tile, "layer") && tile.layer == 0) {
				layerName = "TilesBackground";
			}
			
			var tdata = tile.index;
			if (variable_struct_exists(tile, "rotated")  && tile.rotated) tdata = tile_set_rotate(tdata, true);
			if (variable_struct_exists(tile, "flipped")  && tile.flipped) tdata = tile_set_flip(tdata, true);
			if (variable_struct_exists(tile, "mirrored") && tile.mirrored) tdata = tile_set_mirror(tdata, true);
			
			tilemap_set(layer_tilemap_get_id(layerName), tdata, tile.tx, tile.ty);
		}
		
		missionData = info.mission;
	};
	
	getLevelHeight = function() {
		return room_height;
	}
	
	getLevelWidth = function() {
		return room_width;
	}
	
	getMaxInstanceX = function() {
		biggestX = 0;
		
		if (instance_number(all) == 0) {
			return;
		}
		
		for (var i = 0; i < instance_number(oLevelThing); i++) {
			var inst = instance_find(oLevelThing, i);
			
			if (inst.x > biggestX) {
				biggestX = inst.x;
			}
		}
		
		return biggestX;
	}
	
	getMaxInstanceY = function() {
		biggestY = 0;
		
		if (instance_number(oLevelThing) == 0) {
			return;
		}
		
		for (var i = 0; i < instance_number(oLevelThing); i++) {
			var inst = instance_find(oLevelThing, i);
			
			if (inst.y > biggestY) {
				biggestY = inst.y;
			}
		}
		
		return biggestY;
	}
}


// levelName is just the included files string name
function level_init(levelName) {
	lvl = new Level();
	// Pass level info up the chain for the missionmanager
	var info = lvl.loadLevelFromName(levelName);
	
	//var camera = instance_create_layer(0, 0, "Instances", MultiTrackCamera);
	//camera.camera_track_objects(oPlayer);
	var tilemap = layer_tilemap_get_id("Tiles");
	
	var hCells = room_width / TILE_SIZE;
	var vCells = room_height / TILE_SIZE;
	global.pathGrid = mp_grid_create(0, 0, hCells, vCells, TILE_SIZE, TILE_SIZE);
	
	for (var i = 0; i < hCells; i++) {
		for (var j = 0; j < vCells; j++) {
			if (tilemap_get(tilemap, i, j) != 0) {
				mp_grid_add_cell(global.pathGrid, i, j);
			}
		}
	}
	
	var foreground = layer_get_id("Tiles");
	
	return info;
}

/// @desc Checks the level for errors and stops execution if there are.
/// @param {pointer} levelName The level.
/// @returns {bool} Whether or not the level has errors.
function level_check_for_errors(levelName) {
	
	global.levelErrors = [];
	
	var lvl = new Level();
	var info = lvl.parseJsonFile(levelName);
	
	for (var i = 0; i < array_length(global.editorEssential); i++) {
	        var essentialObject = global.editorEssential[i];
	        var objectIsPresent = false;
	        
	        for (var j = 0; j < array_length(info.instances); j++) {
	                if (info.instances[j].index == essentialObject) {
	                        objectIsPresent = true;
	                        break;
	                }
	        }
	        
	        if (!objectIsPresent) {
	                array_push(global.levelErrors, "ERROR: There must be a " + object_get_name(essentialObject) + " object present in the level.");
	        }
	}
	
	// If there are errors, do not allow loading of the level
	if (array_length(global.levelErrors) > 0) {
		array_push(global.levelErrors, "-----------------------------------------------------------------");
		array_push(global.levelErrors, "Issues tagged as ERROR must be fixed before the level is tested.");
		// array_push(global.levelErrors, "You may optionally suppress warnings by relaunching the game and passing --smartypants on the comamndline.");
		return false;
	}
	 
	// Otherwise it's fine
	return true;
}

/// @desc Destroys all instances except for those specified in the "spared" array
function destroy_everyone_but_the_chosen() {
	with (all) {
		debug_log(object_get_name(object_index) + " -> spared? " + string(array_contains(global.spared, object_index)));

		if (!array_contains(global.spared, object_index)) {
			instance_destroy();
		}
	}
}

function editor_notify_reload_level() {
	if (global.currentLevelPath == "") {
		con_game("editor_notify_reload_level() was called with no level in context. You should not be seeing this.");
		return;
	}
	
	lvl = new Level();
	var info = lvl.parseJsonFile(global.currentLevelPath);
	
	lvl.applyLevelData(info);
}