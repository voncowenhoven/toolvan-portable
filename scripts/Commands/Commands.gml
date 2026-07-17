function CommandInstancePlace(_level, _object, _x, _y) constructor {
        level = _level;
        obj = _object;
        xx = _x;
        yy = _y;
        instID = noone;
        instanceData = undefined;

        static run = function() {
                instID = instance_create_layer(xx, yy, "Instances", obj);
                
                instanceData = {
                        "index" : obj,
                        "name" : object_get_name(obj),
                        "ix" : xx,
                        "iy" : yy
                };
                
                array_push(level.instanceData, instanceData);
        };

        static undo = function() {
                if (instance_exists(instID)) {
                        instance_destroy(instID);
                }
                
                for (var i = 0; i < array_length(level.instanceData); i++) {
                        if (level.instanceData[i] == instanceData) {
                                array_delete(level.instanceData, i, 1);
                                break;
                        }
                }
        };
}

function CommandInstanceMove(_level, _inst, _oldX, _oldY, _newX, _newY) constructor {
        level = _level;
        inst = _inst;
        oldX = _oldX; 
	oldY = _oldY;
        newX = _newX; 
	newY = _newY;
        
        static run = function() {
                inst.x = newX;
                inst.y = newY;
                for (var i = 0; i < array_length(level.instanceData); i++) {
                        if (level.instanceData[i].ix == oldX && level.instanceData[i].iy == oldY
                        && object_get_name(inst.object_index) == level.instanceData[i].name) {
                                level.instanceData[i].ix = newX;
                                level.instanceData[i].iy = newY;
                                break;
                        }
                }
        };
        
        static undo = function() {
                inst.x = oldX;
                inst.y = oldY;
                for (var i = 0; i < array_length(level.instanceData); i++) {
                        if (level.instanceData[i].ix == newX && level.instanceData[i].iy == newY
                        && object_get_name(inst.object_index) == level.instanceData[i].name) {
                                level.instanceData[i].ix = oldX;
                                level.instanceData[i].iy = oldY;
                                break;
                        }
                }
        };
}

function CommandInstanceDelete(_level, _inst) constructor {
        level = _level;
        obj = _inst.object_index;
        xx = _inst.x;
        yy = _inst.y;
        instID = _inst;
        savedData = undefined;
        
        static run = function() {
                for (var i = 0; i < array_length(level.instanceData); i++) {
                        if (level.instanceData[i].ix == xx && level.instanceData[i].iy == yy
                        && level.instanceData[i].name == object_get_name(obj)) {
                                savedData = level.instanceData[i];
                                array_delete(level.instanceData, i, 1);
                                break;
                        }
                }
                if (instance_exists(instID)) instance_destroy(instID);
        };
        
        static undo = function() {
                instID = instance_create_layer(xx, yy, "Instances", obj);
                if (savedData != undefined) array_push(level.instanceData, savedData);
        };
}

function CommandTilePlace(_level, _tilemap, _changes) constructor {
	level    = _level;
	tilemap  = _tilemap;
	changes  = _changes; // array of tile edits
	
	static run = function() {

		for (var i = 0; i < array_length(changes); i++) {
			var c = changes[i];
			tilemap_set(tilemap, c.newData, c.tx, c.ty);
		
			var found = -1;
			for (var j = 0; j < array_length(level.tileData); j++) {
				if (level.tileData[j].tx == c.tx && level.tileData[j].ty == c.ty) {
					found = j;
					break;
				}
			}
			
			var tileData = {
				"tx" : c.tx,
				"ty" : c.ty,
				"index" : tile_get_index(c.newData),
				"flipped" : tile_get_flip(c.newData),
				"rotated" : tile_get_rotate(c.newData),
				"mirrored" : tile_get_mirror(c.newData)
			};
			
			if (found == -1) {
				array_push(level.tileData, tileData);
			} else {
				level.tileData[found] = tileData;
			}
		}
	};
	
	static undo = function() {
		for (var i = 0; i < array_length(changes); i++) {
			var c = changes[i];
			tilemap_set(tilemap, c.oldData, c.tx, c.ty);
			
			var found = -1;
			for (var j = 0; j < array_length(level.tileData); j++) {
				if (level.tileData[j].tx == c.tx && level.tileData[j].ty == c.ty) {
					found = j;
					break;
				}
			}
			
			if (tile_get_index(c.oldData) == 0) {
				if (found != -1) array_delete(level.tileData, found, 1);
			} else {
				var tileData = {
					"tx" : c.tx,
					"ty" : c.ty,
					"index" : tile_get_index(c.oldData),
					"flipped" : tile_get_flip(c.oldData),
					"rotated" : tile_get_rotate(c.oldData),
					"mirrored" : tile_get_mirror(c.oldData)
				};
			
				if (found == -1) {
					array_push(level.tileData, tileData);
				} else {
					level.tileData[found] = tileData;
				}
			}
		}
	};
}



