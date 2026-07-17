// '192' is the key code for ~. On US keyboards, anyways.
// Supermelon is NOT for the British!
var toggleConsole = keyboard_check_pressed(192);

if (toggleConsole) {
	global.console.toggle();
}

global.console.step();
