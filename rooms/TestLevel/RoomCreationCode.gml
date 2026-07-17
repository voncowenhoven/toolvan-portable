// Clear out the level
tilemap_clear(layer_tilemap_get_id("Tiles"), 0);
tilemap_clear(layer_tilemap_get_id("TilesBackground"), 0);
// It's physically impossible to actually destroy all objects because the inputcontroller will bitch if you do so just
// don't leave loose objects hanging around

if (global.currentLevelPath == "") {
	con_game("Somehow, a level load was requested even though no level exists.");
} else {
	level_init(global.currentLevelPath);
}