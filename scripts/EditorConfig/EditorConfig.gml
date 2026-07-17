// The room that Toolvan will use as the "editor room." Toolvan can ONLY be invoked in this room.
global.editorRoom = rEditor;

// The tile size the tile editor will assume.
global.tileSize = 96;

// Holds the reference to the currently being saved level.
global.currentLevelPath = "";

// This array of strings is printed out when a toolvan editor error is detected.
global.levelErrors = [];

// Wherever you decide to store your .VANNA files.
#macro DEVPATH "C:/Users/nerdy/Documents/SupermelonLevels/"

// Instances that are spared when killEmAll() runs
global.spared = [];

// Objects in this array must be in the level when it is compiled or else they will throw Toolvan errors.
global.editorEssential = [];