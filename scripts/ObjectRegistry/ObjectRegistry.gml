global.editorObjectCategories = ds_map_create();

function editor_register_object(category, object) {
	if (!ds_map_exists(global.editorObjectCategories, category)) {
		ds_map_add(global.editorObjectCategories, category, array_create(0));
	}
	var arr = global.editorObjectCategories[? category];
	array_push(arr, object);
}

// Define new editor categories here.
//editor_register_object("Living", oRheanApprentice);
//editor_register_object("Living", oPlayer);

//editor_register_object("Level", oWall);