// This is not directly implemented. It is the "handshake" or 
// interface that all Toolvan tools must agree to on pain of crashing.
function ToolBase(_editor) constructor {
	editor = _editor;
	
	update = function() {};
	draw = function() {};
	onClick = function(mx, my) {};
	onDrag  = function(mx, my) {};
	onRelease = function(mx, my) {}; 
	gui = function() {};
	
	activate = function() {};
	deactivate = function() {};
	destroy = function() {};
}

function Toolvan() constructor {
	level = undefined;
	activeTool = undefined;
	showErrorPage = false;
	
	setTool = function(toolName) {
		
        if (is_struct(activeTool)) {
			delete activeTool;
        }

        switch (toolName) {
			
		case "none":
			activeTool = new ToolNone();
			break;
				
		case "instances":
			activeTool = new ToolInstances(level);
			break;
		
		case "tiles":
			activeTool = new ToolTiles(level);
			break;
	
		case "options":
			activeTool = new ToolOptions(level);
			break;
        }

        activeTool.activate();
    };
	
	update = function() {
		if (keyboard_check(vk_control) and keyboard_check_pressed(ord("S"))) {
			level.saveCurrentLevel();
		}
		
		activeTool.update();
		
		// tiles objects settings
		if (keyboard_check_released(ord("1"))) {
			setTool("tiles");
		}
		
		if (keyboard_check_released(ord("2"))) {
			setTool("instances");
		}
		
		if (keyboard_check_released(ord("3"))) {
			setTool("options");
		}
	};

	draw = function() {
		activeTool.draw();
	};
	
	onClick = function(mx, my) {
		activeTool.onClick(mx, my);
	};
	
	onDrag = function(mx, my) {
		activeTool.onDrag(mx, my);
	};
	
	onRelease = function(mx, my) {
		activeTool.onRelease(mx, my);
	};
	
	init = function() {
		con_log("Starting Toolvan...");
		
		level = new Level();
		
		var player = instance_create_layer(0, 0, "Instances", oToolvanPlayer);
		var camera = instance_create_layer(0, 0, "Instances", oCamera);

		with (camera) {
			camera_track_objects(player);
			//con_log(other.player);
		}
		
		con_log("Toolvan started!");
		
	}
	
	gui = function() {
		ImGui.Begin("Master Window");
			
	        if (ImGui.Button("Tiles")) {
			setTool("tiles");
	        }
			
	        if (ImGui.Button("Objects")) {
			setTool("instances"); 
	        }
			
		if (ImGui.Button("Edit Mission")) {
			setTool("mission"); 
	        }
			
	        if (ImGui.Button("Level Settings")) {
			setTool("options");
	        }
			
		ImGui.End();
			
			
		if (ImGui.BeginMainMenuBar()) {
			if (ImGui.BeginMenu("File...")) {
				
				if (ImGui.MenuItem("Save Mission...")) {
					level.saveCurrentLevel();
				}
				
				if (ImGui.MenuItem("Save Mission As...")) {
					level.saveLevelAs();
				}
				
				if (ImGui.MenuItem("Load Mission...")) {
					level.loadLevel();
				}
				
				ImGui.EndMenu();
			}
			
			if (ImGui.BeginMenu("Help...")) {
				
				if (ImGui.MenuItem("About")) {
					show_message_async("Toolvan: A World Editor For GameMaker" + "\n" +
									"Revision v0001" + "\n" +
									"" + "\n" +
									"'We do these things not because they are easy, but because we thought they were going to be easy'");
				}
				
				ImGui.EndMenu();
			}
			
			if (ImGui.BeginMenu("Test...")) {
				
				if (ImGui.MenuItem("Test Level")) {
					if (global.currentLevelPath == "") {
						con_game("You need to save your level before it can be tested.");
					} else {
						// Do not load the level if it contains errors
						if (!level_check_for_errors(global.currentLevelPath)) {
							showErrorPage = true;
						} else {
							playstate_change(PlayState.GAME);
							room_goto(TestLevel);	
						}
						
					}
				}
				
				ImGui.EndMenu();
			}
		}
			
			ImGui.EndMainMenuBar();
	        
	        activeTool.gui();
		
		if (showErrorPage) {
			ImGui.SetNextWindowSize(480, 220, ImGuiCond.FirstUseEver);
		        ImGui.Begin("SOUP Error!", true, ImGuiWindowFlags.NoCollapse);
		        
		        for (var i = 0; i < array_length(global.levelErrors); i++) {
				ImGui.Text(global.levelErrors[i]);
		        }
		        
		        if (ImGui.Button("OK")) {
				showErrorPage = false;
		        }
		        
		        ImGui.End();
		}
    };
}


