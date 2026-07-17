#region License
/*
Copyright 2025 Isaac von Cowenhoven

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
#endregion

// Set one of these to true to use their respective collision mode.
// These are not mutually exclusive! You can have both run at the same time.
#macro USE_OBJECT_COLLISION true
#macro USE_TILE_COLLISION true

function cowdmc(_owner) constructor {
	/*
		Replace this with your actual "wall" object.
		Note that you can also pass an array here (i.e [oWall1, oWall2]) and 
		collision will be checked against all of them.
	*/
	solidObj = oWall;
	
	/*
		Replace this with your Tiles layer. 
	*/
	tileLayer = "Tiles";
	
	againstVertWall = 0;
	againstHorizWall = 0;
	
	xRemainder = 0;
	yRemainder = 0;
	
	owner = _owner;
	
	stepX = 0;
	stepY = 0;
	
	xSpd = 0;
	ySpd = 0;
	
	placeMeeting = function(_x, _y, _collision) {
		var result = false;
		
		if (USE_OBJECT_COLLISION) {
			with (owner) {
				result = cow_place_meeting(_x, _y, _collision);
			}
		}
		
		if (USE_TILE_COLLISION and !result) {
			with (owner) {
				result = tile_meeting(_x, _y, _collision);
			}
		}
		
		return result;
	}
	
	spdDir = function(spd, dir) {
		xSpdYSpd(lengthdir_x(spd, dir), lengthdir_y(spd, dir));
	}
	
	xSpdYSpd = function(xSpd, ySpd) {
		// Add incoming speed to leftover motion
		xRemainder += xSpd;
		yRemainder += ySpd;
		
		self.xSpd = xSpd;
		self.ySpd = ySpd;
		
		againstVertWall = 0;
		againstHorizWall = 0;
		
		// We continue moving as normal until we hit a horizontal or vertical wall.
		doXMovement();
		doYMovement();
	}
	
	doXMovement = function() {
		while (abs(xRemainder) >= 1) {
			stepX = sign(xRemainder);
			
			if (!placeMeeting(owner.x + stepX, owner.y, solidObj) and 
				!placeMeeting(owner.x + stepX, owner.y, tileLayer)) {
				owner.x += stepX;
				xRemainder -= stepX;
			} else { 
				againstHorizWall = stepX;
				xRemainder = 0;
				break;
			}
			
		}
	}
	
	doYMovement = function() {
		while (abs(yRemainder) >= 1) {
			stepY = sign(yRemainder);
			
			if (!placeMeeting(owner.x, owner.y + stepY, solidObj) and
				!placeMeeting(owner.x, owner.y + stepY, tileLayer)) {
				owner.y += stepY;
				yRemainder -= stepY;
			} else { 
				againstVertWall = stepY;
				yRemainder = 0;
				break;
			}
		}
	}
	
	getSpeed = function() {
		return point_distance(0, 0, xSpd, ySpd);
	}
}

/// @function tile_meeting(x, y, layer)
/// @param _x
/// @param _y
/// @param _layer
function tile_meeting(_x, _y, _layer) {
	
	// Hack to make sure solidObj isn't getting passed here and messing it up
	if !is_string(_layer) return;
	
    var tilemap = layer_tilemap_get_id(_layer);

    if (layer_get_element_type(tilemap) != layerelementtype_tilemap) {
        return false;
    }

    var _x1 = tilemap_get_cell_x_at_pixel(tilemap, bbox_left + (_x - x), _y);
    var _y1 = tilemap_get_cell_y_at_pixel(tilemap, _x, bbox_top + (_y - y));
    var _x2 = tilemap_get_cell_x_at_pixel(tilemap, bbox_right + (_x - x), _y);
    var _y2 = tilemap_get_cell_y_at_pixel(tilemap, _x, bbox_bottom + (_y - y));

    for (var i = _x1; i <= _x2; i++) {
        for (var j = _y1; j <= _y2; j++) {
            if (tilemap_get(tilemap, i, j)) {
                return true;
            }
        }
    }

    return false;
}

function cow_place_meeting(_x, _y, _obj) {
	// Hack to make sure tile layers aren't getting passed into place_meeting
	 if (is_string(_obj)) return false;
	
	return place_meeting(_x, _y, _obj);
}