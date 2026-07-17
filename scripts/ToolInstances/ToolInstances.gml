function ToolInstances(_level) constructor {
	selectedCategory = -1;
	selectedObject = noone;
	selectedInstance = noone;
	selectedInstanceId = noone;
	level = _level;

	dragInstance = noone;
	dragOffsetX = 0;
	dragOffsetY = 0;
	dragStartX = 0;
	dragStartY = 0;
	hoveredInstance = noone;

	scaleEdge = noone;
	scaleOriginX = 0;
	scaleOriginY = 0;
	scaleStartScaleX = 1;
	scaleStartScaleY = 1;
	scaleStartMouseX = 0;
	scaleStartMouseY = 0;

	scalableObjs = [oWall, oLevelHazard];

	#region helpers

	isScalable = function(inst) {
		if (!instance_exists(inst)) return false;
		for (var i = 0; i < array_length(scalableObjs); i++) {
			if (inst.object_index == scalableObjs[i]) return true;
		}
		return false;
	};

	getHoveredEdge = function(mx, my) {
		var THRESH = 6;
		if (selectedInstance == noone || !instance_exists(selectedInstance)) return noone;
		if (!isScalable(selectedInstance)) return noone;
		with (selectedInstance) {
			var inX = (mx >= bbox_left - THRESH && mx <= bbox_right  + THRESH);
			var inY = (my >= bbox_top  - THRESH && my <= bbox_bottom + THRESH);
			if (inY && abs(mx - bbox_left)   < THRESH) return "left";
			if (inY && abs(mx - bbox_right)  < THRESH) return "right";
			if (inX && abs(my - bbox_top)    < THRESH) return "top";
			if (inX && abs(my - bbox_bottom) < THRESH) return "bottom";
		}
		return noone;
	};

	#endregion

	update = function() {
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Z"))) {
			level.undovan.undo();
		}
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Y"))) {
			level.undovan.redo();
		}

		if (keyboard_check_pressed(vk_delete) && selectedInstance != noone && instance_exists(selectedInstance)) {
			level.undovan.push(new CommandInstanceDelete(level, selectedInstance));
			selectedInstance = noone;
		}

		hoveredInstance = noone;
		with (all) {
			if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
				other.hoveredInstance = id;
				break;
			}
		}
	};

	draw = function() {
		if (hoveredInstance != noone && hoveredInstance != selectedInstance) {
			draw_set_color(c_yellow);
			draw_set_alpha(0.3);
			with (hoveredInstance) {
				draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);	
			} 
			draw_set_alpha(1);
		}

		if (selectedInstance != noone && instance_exists(selectedInstance)) {
			draw_set_color(c_lime);
			draw_set_alpha(0.6);
			with (selectedInstance) {
				draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);	
			} 
			draw_set_alpha(1);

			if (isScalable(selectedInstance)) {
				draw_set_color(c_lime);
				draw_set_alpha(0.9);
				var HSIZE = 5;
				with (selectedInstance) {
					var mx = (bbox_left + bbox_right)  / 2;
					var my = (bbox_top  + bbox_bottom) / 2;
					draw_rectangle(bbox_left  - HSIZE, my - HSIZE, bbox_left  + HSIZE, my + HSIZE, false);
					draw_rectangle(bbox_right - HSIZE, my - HSIZE, bbox_right + HSIZE, my + HSIZE, false);
					draw_rectangle(mx - HSIZE, bbox_top    - HSIZE, mx + HSIZE, bbox_top    + HSIZE, false);
					draw_rectangle(mx - HSIZE, bbox_bottom - HSIZE, mx + HSIZE, bbox_bottom + HSIZE, false);
				}
				draw_set_alpha(1);
			}
		}

		if (dragInstance != noone) {
			draw_set_color(c_aqua);
			draw_set_alpha(0.5);
			with (dragInstance) {
				draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);	
			} 
			draw_set_alpha(1);
		}
	};

	onClick = function(mx, my) {
		var edge = getHoveredEdge(mx, my);
		if (edge != noone) {
			scaleEdge = edge;
			scaleOriginX = selectedInstance.x;
			scaleOriginY = selectedInstance.y;
			scaleStartScaleX = selectedInstance.image_xscale;
			scaleStartScaleY = selectedInstance.image_yscale;
			scaleStartMouseX = mx;
			scaleStartMouseY = my;
			return;
		}

		var clicked = noone;
		with (all) {
			if (point_in_rectangle(mx, my, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
				clicked = id;
				break;
			}
		}

		if (clicked != noone) {
			selectedInstance = clicked;
			dragInstance = clicked;
			dragOffsetX = clicked.x - mx;
			dragOffsetY = clicked.y - my;
			dragStartX = clicked.x;
			dragStartY = clicked.y;
		} else if (selectedObject != noone) {
			level.undovan.push(new CommandInstancePlace(level, selectedObject, mx, my));
		}
	};

	onRightClick = function(mx, my) {
		selectedObject = noone;
		selectedInstance = noone;
	};

	onDrag = function(mx, my) {
		if (scaleEdge != noone && instance_exists(selectedInstance)) {
			var baseW = sprite_get_width(selectedInstance.sprite_index);
			var baseH = sprite_get_height(selectedInstance.sprite_index);

			switch (scaleEdge) {
				case "right":
					var newW = (mx - scaleOriginX) + (baseW * scaleStartScaleX * 0.5);
					selectedInstance.image_xscale = max(0.1, (newW / baseW) * 2);
					break;
				case "left":
					var newW = (scaleOriginX - mx) + (baseW * scaleStartScaleX * 0.5);
					selectedInstance.image_xscale = max(0.1, (newW / baseW) * 2);
					break;
				case "bottom":
					var newH = (my - scaleOriginY) + (baseH * scaleStartScaleY * 0.5);
					selectedInstance.image_yscale = max(0.1, (newH / baseH) * 2);
					break;
				case "top":
					var newH = (scaleOriginY - my) + (baseH * scaleStartScaleY * 0.5);
					selectedInstance.image_yscale = max(0.1, (newH / baseH) * 2);
					break;
			}
			return;
		}

		if (dragInstance != noone) {
			dragInstance.x = mx + dragOffsetX;
			dragInstance.y = my + dragOffsetY;
		}
	};

	onRelease = function(mx, my) {
		if (scaleEdge != noone) {
			if (instance_exists(selectedInstance)) {
				var newSX = selectedInstance.image_xscale;
				var newSY = selectedInstance.image_yscale;
				if (newSX != scaleStartScaleX || newSY != scaleStartScaleY) {
					level.undovan.push(new CommandInstanceScale(
						level, selectedInstance,
						scaleStartScaleX, scaleStartScaleY,
						newSX, newSY
					));
				}
			}
			scaleEdge = noone;
			return;
		}

		if (dragInstance != noone) {
			if (dragInstance.x != dragStartX || dragInstance.y != dragStartY) {
				level.undovan.push(new CommandInstanceMove(level, dragInstance, dragStartX, dragStartY, dragInstance.x, dragInstance.y));
			}
			dragInstance = noone;
		}
	};

	activate = function() {};
	deactivate = function() {
		dragInstance = noone;
		selectedInstance = noone;
		scaleEdge = noone;
	};
	destroy = function() {};

	gui = function() {
		ImGui.SetNextWindowPos(1495, 36, ImGuiCond.Once);
		//ImGui.SetNextWindowContentSize(428, 1049);
		ImGui.SetNextWindowSize(428, 1049, ImGuiCond.Once);
		ImGui.Begin("Place And Edit Mapthings");

		var keyList = ds_map_keys_to_array(global.editorObjectCategories);
		for (var i = 0; i < array_length(keyList); i++) {
			var key = keyList[i];
			if (ImGui.Button(key)) selectedCategory = key;
			if (i < array_length(keyList) - 1) ImGui.SameLine();
		}

		ImGui.NewLine();

		var category = global.editorObjectCategories[? selectedCategory];
		if (is_array(category)) {
			for (var j = 0; j < array_length(category); j++) {
				var objName = object_get_name(category[j]);
				var isSelected = (selectedObject == category[j]);
				if (isSelected) ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.6, 0.2, 1.0);
				if (ImGui.Button(objName)) selectedObject = category[j];
				if (isSelected) ImGui.PopStyleColor(1);
			}
		}

		ImGui.Separator();

		var inspectTarget = selectedInstance != noone ? selectedInstance : hoveredInstance;
		if (inspectTarget != noone && instance_exists(inspectTarget)) {
			ImGui.Text("[ " + object_get_name(inspectTarget.object_index) + " ]");
			ImGui.Text("Position: " + string(inspectTarget.x) + ", " + string(inspectTarget.y));

			if (isScalable(inspectTarget)) {
				ImGui.Text("Scale: " + string(inspectTarget.image_xscale) + ", " + string(inspectTarget.image_yscale));
			}
		} else {
			ImGui.Text("No instance selected.");
		}

		ImGui.Separator();

		if (ImGui.CollapsingHeader("Placed Instances")) {
			for (var i = 0; i < array_length(level.instanceData); i++) {
				var inst = level.instanceData[i];
				var label = inst.name + " (" + string(inst.ix) + ", " + string(inst.iy) + ")";
				if (ImGui.Selectable(label, selectedInstance != noone
				&& instance_exists(selectedInstance)
				&& selectedInstance.x == inst.ix
				&& selectedInstance.y == inst.iy)) {
					with (all) {
						if (x == inst.ix && y == inst.iy && object_get_name(object_index) == inst.name) {
							other.selectedInstance = id;
							break;
						}
					}
					oToolvanPlayer.x = selectedInstance.x;
					oToolvanPlayer.y = selectedInstance.y;
				}
			}
		}

		ImGui.Separator();
		ImGui.Text("CTRL + Z: Undo");
		ImGui.Text("CTRL + Y: Redo");
		ImGui.Text("DEL: Delete selected");
		ImGui.Text("Right click: Deselect");

		ImGui.End();
	};

	serializeInstance = function(instance) {
		var instanceData = {
			"index" : instance.object_index,
			"name"  : object_get_name(instance.object_index),
			"ix"    : instance.x,
			"iy"    : instance.y,
			"scalex" : instance.image_xscale,
			"scaleY" : instance.image_yscale,
		};
		array_push(level.instanceData, instanceData);
	};
};