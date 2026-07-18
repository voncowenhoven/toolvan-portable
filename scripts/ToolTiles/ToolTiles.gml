function ToolTiles(_level) constructor {
	level = _level;
	
	themes = [
			
			{
				name: "Beach",
				background: {
						tileset: tBeach,
						tilesetSpr: sTileBeach,
				},
				foreground: {
						tileset: tBeach,
						tilesetSpr: sTileBeach,
				}
			}
	];
	
	// TODO: Initialize theme properly when serializing
	currentThemeIndex = 0; 
	
	/*
	* Note that for each layer defined here, you must set a tileset manually in the IDE.
	* Can be literally any tileset (I just throw in tDummy.) Otherwise it won't work.
	*/
	layers = [
		{ 
			name: "Background", 
			layerName: "TilesBackground", 
			tilemap: -1,
			focused : false
		},
		{ 
			name: "Foreground", 
			layerName: "Tiles", 
			tilemap: -1,
			focused : false
		}
	];
	
	currentLayerIndex = 1; 
	
	// Initialize tilemaps for each layer
	for (var i = 0; i < array_length(layers); i++) {
		if (layer_exists(layers[i].layerName)) {
			layers[i].tilemap = layer_tilemap_get_id(layers[i].layerName);
		}
	}
	
	updateCurrentLayerCache = function() {
		var theme = themes[currentThemeIndex];
		var layerThemeData = (currentLayerIndex == 0) ? theme.background : theme.foreground;
		
		tilemap = layers[currentLayerIndex].tilemap;
		tileset = layerThemeData.tileset;
		tilesetSpr = layerThemeData.tilesetSpr;
		//tilesetSprFrames = layerThemeData.tilesetSprFrames;
		
		tilesetInfo = tileset_get_info(tileset);
		tileSize = tilesetInfo.tile_width;
		tileCount = tilesetInfo.tile_count;
		tileIndexMax = tileCount - 1;
		
		tileIndexCurrent = clamp(tileIndexCurrent, 0, tileIndexMax);
		pageCurrent = 0; 
	};
	
	applyTheme = function() {
		var theme = themes[currentThemeIndex];
		
		if (layers[0].tilemap != -1) {
			tilemap_tileset(layers[0].tilemap, theme.background.tileset);
		}
		
		if (layers[1].tilemap != -1) {
			tilemap_tileset(layers[1].tilemap, theme.foreground.tileset);
		}
		
		updateCurrentLayerCache();
		buildPickerSprites();
	};
	
	tilemap = -1;
	tileset = -1;
	tilesetSpr = -1;
	tilesetSprFrames = -1;
	tilesetInfo = undefined;
	tileSize = global.tileSize;
	tileCount = 0;
	tileIndexCurrent = 5;
	tileIndexMin = 0;
	tileIndexMax = 0;
	brushSize = 0;
	selectionGrid = [[0]];
	selectionWidth = 1;
	selectionHeight = 1;
	// Picker drag state. This is done via GML instead of the IMGUI wrapper because IMGUI is a liar when it comes to drag state.
	pickerDragActive = false;
	pickerDragStartCol = 0;
	pickerDragStartRow = 0;
	pickerDragEndCol = 0;
	pickerDragEndRow = 0;
	// Cached pixel origin of the tile grid inside the ImGui window, set each gui() call
	pickerOriginX = 0;
	pickerOriginY = 0;
	tilesPerPage = 50; 
	pageCurrent = 0;
	pendingRotation = 0;
	numColumns = 30;
	pickerSprites = [];
	
	buildPickerSprites = function() {
		for (var i = 0; i < array_length(pickerSprites); i++) {
			sprite_delete(pickerSprites[i]);
		}
		pickerSprites = [];
		
		var surf = surface_create(tileSize, tileSize);
		for (var i = 0; i < tileCount; i++) {
			surface_set_target(surf);
			draw_clear_alpha(c_black, 0);
			draw_tile(tileset, i, 0, 0, 0);
			surface_reset_target();
			array_push(pickerSprites, sprite_create_from_surface(surf, 0, 0, tileSize, tileSize, false, false, 0, 0));
		}
		surface_free(surf);
	};
	
	applyTheme();

	getCurrentTilemap = function() {
		return layers[currentLayerIndex].tilemap;
	};
	
	getCurrentLayer = function() {
		return layers[currentLayerIndex].layerName;
	}
	
	applyRotationStep = function(data, step) {
		switch (step) {
			case 0: data = tile_set_rotate(data, false); data = tile_set_flip(data, false); data = tile_set_mirror(data, false); break;
			case 1: data = tile_set_rotate(data, true);  data = tile_set_flip(data, false); data = tile_set_mirror(data, false); break;
			case 2: data = tile_set_rotate(data, false); data = tile_set_flip(data, true);  data = tile_set_mirror(data, true);  break;
			case 3: data = tile_set_rotate(data, true);  data = tile_set_flip(data, true);  data = tile_set_mirror(data, true);  break;
		}
			
		return data;
	};

	buildSelectionFromPicker = function() {
		var c0 = min(pickerDragStartCol, pickerDragEndCol);
		var c1 = max(pickerDragStartCol, pickerDragEndCol);
		var r0 = min(pickerDragStartRow, pickerDragEndRow);
		var r1 = max(pickerDragStartRow, pickerDragEndRow);
		
		selectionWidth  = (c1 - c0) + 1;
		selectionHeight = (r1 - r0) + 1;
		selectionGrid   = array_create(selectionWidth);
		
		var tilesPerRow = 7; // must match tilesPerColumn in gui()
		var pageStart = pageCurrent * tilesPerPage;
		
		for (var col = 0; col < selectionWidth; col++) {
			selectionGrid[col] = array_create(selectionHeight);
			for (var row = 0; row < selectionHeight; row++) {
				var tileIndex = pageStart + (r0 + row) * tilesPerRow + (c0 + col);
				tileIndex = clamp(tileIndex, 0, tileIndexMax);
				selectionGrid[col][row] = tileIndex;
			}
		}
		
		tileIndexCurrent = selectionGrid[0][0];
	};

	// HACK: This has to be done because ImGui or this wrapper does not properly track mouse dragging between buttons.
	// Returns the picker cell [col, row] under gui-space coordinate (gx, gy),
	// or [-1, -1] if the position is outside the grid.
	// buttonSize is the rendered pixel size of each ImageButton (44px + any padding).
	getPickerCellAt = function(gx, gy) {
		var buttonSize = 44; // must match ImageButton width/height in gui()
		var tilesPerRow = 7; // must match tilesPerColumn in gui()
		
		var localX = gx - pickerOriginX;
		var localY = gy - pickerOriginY;
		
		if (localX < 0 or localY < 0) {
			return [-1, -1];
		}
		
		var col = localX div buttonSize;
		var row = localY div buttonSize;
		
		if (col >= tilesPerRow) {
			return [-1, -1];
		}
		
		var pageIndex = row * tilesPerRow + col;
		if (pageIndex >= tilesPerPage) {
			return [-1, -1];
		}
		
		return [col, row];
	};

	update = function() {
			if (keyboard_check_pressed(vk_tab)) {
				currentLayerIndex = (currentLayerIndex + 1) % array_length(layers);
				updateCurrentLayerCache();
				
				for (var i = 0; i < array_length(layers); i++) {
					layer_shader(layers[i].layerName, i == currentLayerIndex ? shaderNothing : shaderBasicOpacity);
				}
			}
			
			// Previous versions of this code assumed that a tile was always facing "symbolically upwards",
			// which caused issues with tilesets that defied that convention. It should now mirror the way the
			// tile rotator in the IDE works.
			if (keyboard_check_pressed(ord("R"))) {
					var activeMap = getCurrentTilemap();
					var data = tilemap_get_at_pixel(activeMap, mouse_x, mouse_y);
					
					if (tile_get_index(data) == 0) {
						pendingRotation = (pendingRotation + 1) % 4;
					} else {
						var baseX = tilemap_get_cell_x_at_pixel(activeMap, mouse_x, mouse_y);
						var baseY = tilemap_get_cell_y_at_pixel(activeMap, mouse_x, mouse_y);
					
						for (var dx = -brushSize; dx <= brushSize; dx++) {
							for (var dy = -brushSize; dy <= brushSize; dy++) {
								var tx = baseX + dx;
								var ty = baseY + dy;
								var tdata = tilemap_get(activeMap, tx, ty);
								if (tdata == 0) continue;
						
								var r = tile_get_rotate(tdata);
								var f = tile_get_flip(tdata);
								var m = tile_get_mirror(tdata);
						
								var step;
								if (!r && !f && !m) step = 0;
								else if ( r && !f && !m) step = 1;
								else if (!r &&  f &&  m) step = 2;
								else if ( r &&  f &&  m) step = 3;
								else step = 0;
						
								step = (step + 1) % 4;
								tdata = applyRotationStep(tdata, step);
								tilemap_set(activeMap, tdata, tx, ty);
							}
						}
					}
			}
			
			if (mouse_wheel_up()) {
				brushSize += 1;
			}
			
			if (mouse_wheel_down()) {
				brushSize -= 1;
			}
			
			if (brushSize < 0) {
				brushSize = 0;
			}
			
			if (brushSize > 5) {
				brushSize = 5;
			}
			
			if (keyboard_check(vk_control) and keyboard_check(ord("Z"))) {
				level.undovan.undo();
			}
			
			if (keyboard_check(vk_control) and keyboard_check(ord("Y"))) {
				level.undovan.redo();
			}
			
			if (keyboard_check_pressed(ord("E"))) {
				tileIndexCurrent = 0;
			}
			
			// HACK: This is where the fun begins.
			var mx = display_mouse_get_x();
			var my = display_mouse_get_y();
			var cell = getPickerCellAt(mx, my);
			var cellCol = cell[0];
			var cellRow = cell[1];
			var overPicker = (cellCol != -1);
			
			if (overPicker) {
				if (mouse_check_button_pressed(mb_left)) {
					pickerDragActive   = true;
					pickerDragStartCol = cellCol;
					pickerDragStartRow = cellRow;
					pickerDragEndCol   = cellCol;
					pickerDragEndRow   = cellRow;
					buildSelectionFromPicker();
				}
			}
			
			if (pickerDragActive) {
				if (mouse_check_button(mb_left)) {
					// Extend while held, even if cursor drifts outside grid
					if (overPicker) {
						pickerDragEndCol = cellCol;
						pickerDragEndRow = cellRow;
						buildSelectionFromPicker();
					}
				} else {
					// Released
					pickerDragActive = false;
					buildSelectionFromPicker();
				}
			}
	};

	draw = function() {
		draw_set_color(c_white);
		draw_set_alpha(0.4);

		var baseTx = mouse_x div tileSize;
		var baseTy = mouse_y div tileSize;
		
		var basePx = baseTx * tileSize;
		var basePy = baseTy * tileSize;

		for (var col = 0; col < selectionWidth; col++) {
			for (var row = 0; row < selectionHeight; row++) {
				var px = (baseTx + col) * tileSize;
				var py = (baseTy + row) * tileSize;

				var previewData = applyRotationStep(selectionGrid[col][row], pendingRotation);
				draw_tile(tileset, previewData, 0, px, py);
			}
		}
		
		for (var dx = -brushSize; dx <= brushSize; dx++) {
			for (var dy = -brushSize; dy <= brushSize; dy++) {
				var px = basePx + dx * tileSize;
				var py = basePy + dy * tileSize;

				var previewData = applyRotationStep(tileIndexCurrent, pendingRotation);
				draw_tile(tileset, previewData, 0, px, py);
			}
		}
	};

	onClick = function(mx, my) {};
	
	onDrag = function(mx, my) {
		var activeMap = getCurrentTilemap();
		var baseTx = mx div tileSize;
		var baseTy = my div tileSize;
		var changes = [];
		
		var singleTile = (selectionWidth == 1 and selectionHeight == 1);
		
		if (singleTile and brushSize > 0) {
			for (var dx = -brushSize; dx <= brushSize; dx++) {
				for (var dy = -brushSize; dy <= brushSize; dy++) {
					var tx = baseTx + dx;
					var ty = baseTy + dy;
					
					var oldData = tilemap_get(activeMap, tx, ty);
					var newData = applyRotationStep(selectionGrid[0][0], pendingRotation);
					tilemap_set(activeMap, newData, tx, ty);
					
					array_push(changes, {
						tx: tx, ty: ty,
						oldData: oldData,
						newData: newData
					});
					serializeTile(tx, ty);
				}
			}
		} else {
			for (var col = 0; col < selectionWidth; col++) {
			for (var row = 0; row < selectionHeight; row++) {
				var tx = baseTx + col;
				var ty = baseTy + row;
				
				var oldData = tilemap_get(activeMap, tx, ty);
				var newData = applyRotationStep(selectionGrid[col][row], pendingRotation);
				tilemap_set(activeMap, newData, tx, ty);
				
				array_push(changes, {
					tx: tx, ty: ty,
					oldData: oldData,
					newData: newData
				});
				serializeTile(tx, ty);
			}
			}
    }
        
    level.undovan.push(new CommandTilePlace(level, activeMap, changes));
};

	onRelease = function(mx, my) {};
	
	activate = function() {};
	
	deactivate = function() {};
	
	destroy = function() {
			shader_reset();
			for (var i = 0; i < array_length(pickerSprites); i++) {
				sprite_delete(pickerSprites[i]);
			}
	};

	gui = function() {
		ImGui.SetNextWindowPos(1495, 36, ImGuiCond.Once);
		ImGui.SetNextWindowSize(428, 1049, ImGuiCond.Once);
		ImGui.Begin("Place and edit tiles");
		
		ImGui.Text("Theme:");
		for (var i = 0; i < array_length(themes); i++) {
				if (ImGui.RadioButton(themes[i].name, currentThemeIndex == i)) {
						currentThemeIndex = i;
						applyTheme();
				}
				if (i < array_length(themes) - 1) {
						ImGui.SameLine();
				}
		}
		
		ImGui.Separator();
		
		ImGui.Text("Current Layer:");
		for (var i = 0; i < array_length(layers); i++) {
				if (ImGui.RadioButton(layers[i].name, currentLayerIndex == i)) {
						currentLayerIndex = i;
						updateCurrentLayerCache();
				}
				if (i < array_length(layers) - 1) {
						ImGui.SameLine();
				}
		}
		
		ImGui.Separator();

		var numPages = ceil(tileCount / tilesPerPage);
		pageCurrent = clamp(pageCurrent, 0, numPages - 1);

		if (ImGui.Button("<")) {
				pageCurrent = max(0, pageCurrent - 1);
				pickerDragStartCol = 0; pickerDragStartRow = 0;
				pickerDragEndCol   = 0; pickerDragEndRow   = 0;
				buildSelectionFromPicker();
		}
		
		ImGui.SameLine();
		ImGui.Text("Page " + string(pageCurrent + 1) + " / " + string(numPages));
		ImGui.SameLine();
		if (ImGui.Button(">")) {
				pageCurrent = min(numPages - 1, pageCurrent + 1);
				pickerDragStartCol = 0; 
				pickerDragStartRow = 0;
				pickerDragEndCol = 0; 
				pickerDragEndRow = 0;
				buildSelectionFromPicker();
		}

		var tilesPerColumn = 7;
		var start = pageCurrent * tilesPerPage;
		var _end = min(start + tilesPerPage, tileCount);

		// Record the pixel origin of the tile grid so update() can hit-test against it.
		// We sample it on the first button of each frame. GetCursorScreenPos gives the
		// position ImGui is about to draw the next item at, in display/screen coordinates.
		var recordedOrigin = false;

		var selC0 = min(pickerDragStartCol, pickerDragEndCol);
		var selC1 = max(pickerDragStartCol, pickerDragEndCol);
		var selR0 = min(pickerDragStartRow, pickerDragEndRow);
		var selR1 = max(pickerDragStartRow, pickerDragEndRow);

		var colCount = 0;

		for (var i = start; i < _end; i++) {
			var pageIndex = i - start;
			var cellCol = pageIndex mod tilesPerColumn;
			var cellRow = pageIndex div tilesPerColumn;

			// Capture the screen-space origin of the grid from the very first button
			if (!recordedOrigin) {
				pickerOriginX = ImGui.GetCursorScreenPosX();
				pickerOriginY = ImGui.GetCursorScreenPosY();
				recordedOrigin = true;
			}

			var inSelection = (cellCol >= selC0 and cellCol <= selC1
					&& cellRow >= selR0 and cellRow <= selR1);

			var tintCol = c_white;
			var tintAlpha = 1.0;
			var bgCol = c_black;
			var bgAlpha = 0.0;

			ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0.0, 0.0);
			ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 0.0, 0.0);
			
			ImGui.ImageButton("##tile" + string(i), pickerSprites[i], 0, tintCol, tintAlpha, bgCol, bgAlpha, 44, 44);
			
			if (inSelection) {
				var rectMinX = ImGui.GetItemRectMinX();
				var rectMinY = ImGui.GetItemRectMinY();
				var rectMaxX = ImGui.GetItemRectMaxX();
				var rectMaxY = ImGui.GetItemRectMaxY();
				
				var drawList = ImGui.GetWindowDrawList();
				ImGui.DrawListAddRect(drawList, rectMinX, rectMinY, rectMaxX, rectMaxY, c_yellow, 1.0, 0, 3.0);
			}
			
			ImGui.PopStyleVar(2);

			colCount++;
			if (colCount < tilesPerColumn) {
				ImGui.SameLine();
			} else {
				colCount = 0;
			}
		}
		
		ImGui.NewLine();
		
		var w = ImGui.GetWindowWidth();
		var h = ImGui.GetWindowHeight();
		var posX = ImGui.GetWindowPosX();
		var posY = ImGui.GetWindowPosY();
		ImGui.Text("Window size: " + string(w) + " x " + string(h));
		
		ImGui.NewLine();
		ImGui.Text("Window pos: " + string(posX) + " x " + string(posY));
		
		ImGui.End();
	};
	
	serializeTile = function(tileX, tileY) {
		var activeMap = getCurrentTilemap();
		var tdata = tilemap_get(activeMap, tileX, tileY);
		
		var found = -1;
		for (var i = 0; i < array_length(level.tileData); i++) {
			if (level.tileData[i].tx == tileX
			&&  level.tileData[i].ty == tileY
			&&  variable_struct_exists(level.tileData[i], "layer")
			&&  level.tileData[i].layer == currentLayerIndex) {
			found = i;
			break;
		}
		}
		
		var tileData = {
			"tx" : tileX,
			"ty" : tileY,
			"index" : tile_get_index(tdata),     
			"layer" : currentLayerIndex,
			"theme" : currentThemeIndex,
			"flipped" : tile_get_flip(tdata),
			"mirrored": tile_get_mirror(tdata),
			"rotated" : tile_get_rotate(tdata)
		};
		
		if (found == -1) {
			array_push(level.tileData, tileData);
		} else {
			level.tileData[found] = tileData;
		}
	};
}
