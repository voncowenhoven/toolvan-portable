function Undovan() constructor {
	undoStack = ds_stack_create();
	redoStack = ds_stack_create();
	maxHistory = 5000;
	
	push = function(command) {
		command.run();
		
		ds_stack_push(undoStack, command);
		
		ds_stack_clear(redoStack);
		
		if (ds_stack_size(undoStack) > maxHistory) {
			ds_stack_pop(undoStack);	
		}
	};
	
	undo = function() {
		if (ds_stack_size(undoStack) == 0) return;
			
		var cmd = ds_stack_pop(undoStack);
		cmd.undo();
		ds_stack_push(redoStack, cmd);
	};
	
	redo = function() {
	        if (ds_stack_size(redoStack) == 0) return;
	        var cmd = ds_stack_pop(redoStack);
	        cmd.run();
	        ds_stack_push(undoStack, cmd);
	};
}

function CommandInstanceScale(_level, _inst, _oldSX, _oldSY, _newSX, _newSY) constructor {
	level = _level;
	inst = _inst;
	oldSX = _oldSX;
	oldSY = _oldSY;
	newSX = _newSX;
	newSY = _newSY;

	static run = function() {
		inst.image_xscale = newSX;
		inst.image_yscale = newSY;
		for (var i = 0; i < array_length(level.instanceData); i++) {
			var d = level.instanceData[i];
			if (d.ix == inst.x && d.iy == inst.y
			&& d.name == object_get_name(inst.object_index)) {
				d.scalex = newSX;
				d.scaleY = newSY;
				break;
			}
		}
	};

	static undo = function() {
		inst.image_xscale = oldSX;
		inst.image_yscale = oldSY;
		for (var i = 0; i < array_length(level.instanceData); i++) {
			var d = level.instanceData[i];
			if (d.ix == inst.x && d.iy == inst.y
			&& d.name == object_get_name(inst.object_index)) {
				d.scalex = oldSX;
				d.scaleY = oldSY;
				break;
			}
		}
	};
}