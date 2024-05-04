extends Node2D

var	x = 0;
var	y = 0;
var i = 0;
var	width = 800;
var	height = 800;
var walls = [];
var	playerPos = Vector2(2, 2);
var	pa = 0.0;
var	pdx = 0.0;
var	pdy = 0.0;
var	Map_End = [1, 1, 1, 1, 1, 1, 1, 1];
var	Map_Mid = [1, 0, 0, 0, 0, 0, 0, 1];
var	Map = [
Array(Map_End.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_End.duplicate())
];
var MousePos = Vector2.ZERO;
var	MapToogle = true;

func	degToRad(deg: float):
	return ((deg * PI) / 180.0);

func	FixAng(angle: float):
	if angle > 359.0:
		angle = angle - 360;
	if angle < 0:
		angle = angle + 360;
	return angle;

func	drawMap():
	if (Map[x][y]) == 1:
		draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLUE);
	elif Map[x][y] == 0:
		draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLACK);
	elif Map[x][y] == 2:
		draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLACK);
	
func	drawPlayer():
	draw_circle(Vector2((playerPos[0] * 100) + 50, (playerPos[1] * 100) + 50), 25, Color.RED);
	draw_line(
	Vector2((playerPos[0] * 100) + 50, (playerPos[1] * 100) + 50), 
	Vector2(((playerPos[0] + (pdx * 2)) * 100) + 50, ((playerPos[1] + (pdy * 2)) * 100) + 50), 
	Color.CORNFLOWER_BLUE, 5);

func	_draw():

	if MapToogle:

		# draw lines and sky
		i = 0;
		while (i < height / 2):
			draw_line(Vector2(0, i), Vector2(width, i), Color.AQUAMARINE, 1);
			i = i + 1;
		for j in (height / 2):
			draw_line(Vector2(0, i), Vector2(width, i), Color.CORNFLOWER_BLUE, 1);
			i = i + 1;

		# draw walls
		i = 0;
		while (i <= width):
			draw_line(Vector2(i, 100), Vector2(i, 400), Color.DARK_GREEN, 1);
			i = i + 1;
	else:
		x = 0;
		y = 0;
		while (x < 8):
			y = 0;
			while (y < 8):
				drawMap();
				y = y + 1;
			x = x + 1;
		drawPlayer();

func	_ready():
#	get_window().size = Vector2(1920, 1080);
	get_window().size = Vector2(800, 800);
	walls.resize(1920);
	walls.fill(0.0);
	Map[2][2] = 2;
	MapToogle = false;
	calculate_walls();
	
func	calculate_walls():
	queue_redraw();
	
func	_input(event):
	MousePos = get_viewport().get_mouse_position();
	if event is InputEventKey:
		if event.keycode == KEY_M and event.is_pressed():
			MapToogle = !MapToogle;
		if event.keycode == KEY_A and event.is_pressed():
			pa = FixAng(pa + 5.0);
			pdx = cos(degToRad(pa));
			pdy = -sin(degToRad(pa));
			print(pa);
		if (event.keycode == KEY_D or event.keycode == KEY_E) and event.is_pressed():
			pa = FixAng(pa - 5.0);
			pdx = cos(degToRad(pa));
			pdy = -sin(degToRad(pa));
			print(pa);
		calculate_walls();
	
