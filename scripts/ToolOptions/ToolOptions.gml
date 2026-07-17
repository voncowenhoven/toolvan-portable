function ToolOptions(_level) constructor {
	level = _level;
	levelWidth = 0;
	levelHeight = 0;
	pendingHeight = 0;
	pendingWidth = 0;
	
	update = function() {
		if (levelHeight <= 0) or (levelWidth <= 0) {
			con_error("[ERROR]: Tried to set level dimensions to impossible size. Resetting to default...");
			levelHeight = 5000;
			levelWidth = 5000;
		}
	};
	
	draw = function() {
		draw_set_color(c_purple);
		draw_set_alpha(1);
		
		for (var i = 0; i < 30; i++) {
    			draw_rectangle(i, i, room_width - 1 - i, room_height - 1 - i, true);
		}
	};
	
	onClick = function(mx, my) {
	
	};
	
	onDrag  = function(mx, my) {
	
	};
	
	onRelease = function(mx, my) {
	
	};
	
	gui = function() {
		ImGui.SetNextWindowPos(50, 500, ImGuiCond.Once);
                ImGui.SetNextWindowContentSize(400, 400);
                ImGui.Begin("Level Settings");
		ImGui.Text("Warning: These settings can be very destructive!");
		
		ImGui.Separator();
		pendingHeight = ImGui.InputInt("Level Height", pendingHeight);
		pendingWidth  = ImGui.InputInt("Level Width",  pendingWidth);
		
		var biggestX = level.getMaxInstanceX(); 
		var biggestY = level.getMaxInstanceY();
		if (pendingWidth < biggestX or pendingHeight < biggestY) {
			ImGui.PushStyleColor(ImGuiCol.Text, c_red, 1);
			ImGui.Text("There are mapthings that exist outside of these bounds.");
			ImGui.Text("If you apply this width/height, they will be irrecoverably culled.");
			ImGui.PopStyleColor();
    		}
		
		if (ImGui.Button("Apply")) {
			levelHeight = pendingHeight;
			levelWidth = pendingWidth;
			
			room_width = levelWidth;
			room_height = levelHeight;
		}

                ImGui.End();
	};
	
	activate = function() {
		levelHeight = level.getLevelHeight();
		levelWidth = level.getLevelWidth();
		pendingHeight = levelHeight;
		pendingWidth = levelWidth;
		
	};
	
	deactivate = function() {
	
	};
	
	destroy = function() {
	
	};

}