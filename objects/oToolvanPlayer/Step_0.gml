var key_left = keyboard_check(ord("A"));
var key_right = keyboard_check(ord("D"));
var key_up = keyboard_check(ord("W"));
var key_down = keyboard_check(ord("S"));

moveH = key_right - key_left;
moveV = key_down - key_up;

if (moveH != 0 or moveV != 0) {
	var targetX = x + moveH;
	var targetY = y + moveV;
				
	direction = point_direction(x, y, targetX, targetY);
	speed = 20;
	
} else {
	speed = 0;
}

x = clamp(x,0,room_width-sprite_width);
y = clamp(y,0,room_height-sprite_height);