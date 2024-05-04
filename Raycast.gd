extends Node2D

var	x = 0;
var	y = 0;
var i = 0;
var walls = [];
var	playerPos = Vector2(2, 2);
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

func	drawMap():
	if (Map[x][y]) == 1:
		draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLUE);
	elif Map[x][y] == 0:
			draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLACK);
	elif Map[x][y] == 2:
			draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.RED);
	

func	_draw():

	if MapToogle:

		# draw lines and sky
		i = 0;
		while (i < 800 / 2):
			draw_line(Vector2(0, i), Vector2(1920, i), Color.AQUAMARINE, 1);
			i = i + 1;
		for j in (800 / 2):
			draw_line(Vector2(0, i), Vector2(1920, i), Color.CORNFLOWER_BLUE, 1);
			i = i + 1;

		# draw walls
		i = 0;
		while (i < 800):
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

func	_ready():
#	get_window().size = Vector2(1920, 1080);
	get_window().size = Vector2(800, 800);
	walls.resize(1920);
	walls.fill(0.0);
	Map[2][2] = 2;
	calculate_walls();
	
func	calculate_walls():
	print("calculate");
	queue_redraw();
	
func	_input(event):
	MousePos = get_viewport().get_mouse_position();
	if event is InputEventKey:
		calculate_walls();
	


