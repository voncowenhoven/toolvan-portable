toolvan.gui();

// Master window
if (!(ImGui.IsAnyItemActive() or ImGui.IsAnyItemHovered() or ImGui.IsAnyItemFocused() or ImGui.WantMouseCapture())) {

	if (mouse_check_button_pressed(mb_left)) {
	    toolvan.onClick(mouse_x, mouse_y);
	}
	else if (mouse_check_button(mb_left)) {
	    toolvan.onDrag(mouse_x, mouse_y);
	}
	else if (mouse_check_button_released(mb_left)) {
	    toolvan.onRelease(mouse_x, mouse_y);
	}
}

toolvan.update();

