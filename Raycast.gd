extends Node2D

# here is the velocity of the player.
# I'm lazy, if this value is bigger than 1 the map breaks 
# (Out of boundry problem)
var	velocity = 0.1;

# variables for iteration, used externally
var	x = 0;
var	y = 0;
var i = 0;

# screen values
var	width = 800;
var	height = 800;

# an array for save walls distance.
var walls = [];
var	rays = [];

# variables for Player.
var	playerPos = Vector2(1.0, 1.0);
var	pa = 0.0;
var	pdx = 0.0;
var	pdy = 0.0;
var	fov = 90.0;
var	fovMulti = 0.0;

# this arrays work as blocks in the map, 
# you can add or edit them to make diferent maps.
var	Map_End = [1, 1, 1, 1, 1, 1, 1, 1];
var	Map_Mid = [1, 0, 0, 0, 0, 0, 0, 1];

# place your blocks here, 
# only dont forget to change the resolution.
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

var	MapToogle = true;

func	degToRad(deg: float):
	return ((deg * PI) / 180.0);

func	FixAng(angle: float):
	if angle > 359.0:
		angle = angle - 360.0;
	if angle < 0:
		angle = angle + 360.0;
	return float(angle);

func	drawRays():
	var	iter = 0;
	
	while (iter < width):
		draw_line(
		Vector2((playerPos[0] * 100) + 0, (playerPos[1] * 100) + 0),  
		Vector2((rays[iter][0] * 100) + 0, (rays[iter][1] * 100) + 0), 
		Color.CHARTREUSE, 2);
		iter = iter + 1;

#
func	drawMap():
	if (Map[x][y]) == 1:
		draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLUE);
	elif Map[x][y] == 0:
		draw_rect(Rect2(x * 100, y * 100, 100, 100), Color.BLACK);
	
func	drawPlayer():
	draw_circle(Vector2(playerPos[0] * 100, playerPos[1] * 100), 10, Color.RED);
	draw_line(
	Vector2((playerPos[0] * 100) + 0, (playerPos[1] * 100) + 0), 
	Vector2(((playerPos[0] + (pdx * 0.3)) * 100) + 0, ((playerPos[1] + (pdy * 0.3)) * 100) + 0), 
	Color.CORNFLOWER_BLUE, 5);
	drawRays();

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
	get_window().size = Vector2(800, 800);
	
	# set 0 and save size for the arrays
	walls.resize(width + 1);
	walls.fill(0.0);
	rays.resize(width + 1);
	rays.fill(Vector2(0, 0));
	
	MapToogle = false;
	fovMulti = float(fov) / float(width);
	calculate_walls();

func	ddaGetnextX(nextx: float, raya: float):
	return((nextx - playerPos[0]) / (cos(degToRad(raya))));
	

# raya is ray angle
func	ddaAlgorithm(raya: float):
	var rayx = 0;
	var	rayy = 0;
	
	if (raya < 90.0 and raya > 0):
		rayx = playerPos[0] + 1;
		rayy = playerPos[1] - sin(degToRad(raya)) * ddaGetnextX(rayx, raya);
		print("sector 1");
	elif (raya > 270.0 and raya < 360.0):
		rayx = playerPos[0] + 1;
		rayy = playerPos[1] - sin(degToRad(raya)) * ddaGetnextX(rayx, raya);
		print("sector 2");
	elif (raya > 90.0 and raya < 180.0):
		rayx = int(playerPos[0]);
		rayy = playerPos[1] - sin(degToRad(raya)) * ddaGetnextX(rayx, raya);
		print("sector 3");
	elif (raya > 180 and raya < 270):
		rayx = int(playerPos[0]);
		rayy = playerPos[1] - sin(degToRad(raya)) * ddaGetnextX(rayx, raya);
		print("sector 4");
	elif (raya == 180 or raya == 0):
		print("bad sector!!!");
	elif (raya == 90 or raya == 270):
		print("bad sector!!!");
	return (Vector2(rayx, rayy));

func	calcRayDist(ray: int):
	var	angle = FixAng((float(pa) - (fov / 2.0)) + (ray * fovMulti));
	var	rayx = 0;
	var	rayy = 0;
	var	positionx = 0;

	if !MapToogle:
		rays[ray] = ddaAlgorithm(pa);
		#rays[ray][0] = playerPos[0] + cos(degToRad(angle)) * 5.0;
		#rays[ray][1] = playerPos[1] - sin(degToRad(angle)) * 5.0;
	else:
		rayx = 0;
		rayy = 0;
	return (1);

func	raycast():
	var ray = 0;

	while ray < width:
		walls[ray] = calcRayDist(ray);
		ray = ray + 1;

func	calculate_walls():
	raycast();
	queue_redraw();
	
func	_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_M and event.is_pressed():
			MapToogle = !MapToogle;
		if event.keycode == KEY_A and event.is_pressed():
			pa = FixAng(pa + 5.0);
			pdx = cos(degToRad(pa));
			pdy = -sin(degToRad(pa));
		if (event.keycode == KEY_D or event.keycode == KEY_E) and event.is_pressed():
			pa = FixAng(pa - 5.0);
			pdx = cos(degToRad(pa));
			pdy = -sin(degToRad(pa));
		if (event.keycode == KEY_W or event.keycode == KEY_COMMA) and event.is_pressed():
			if Map[int(playerPos[0] + pdx * velocity)][int(playerPos[1] + pdy * velocity)] != 1:
				playerPos[0] = float(playerPos[0] + pdx * velocity);
				playerPos[1] = float(playerPos[1] + pdy * velocity);
		if (event.keycode == KEY_S or event.keycode == KEY_O) and event.is_pressed():
			if Map[int(playerPos[0] - (pdx * velocity))][int(playerPos[1] - (pdy * velocity))] != 1:
				playerPos[0] = float(playerPos[0] - (pdx * velocity));
				playerPos[1] = float(playerPos[1] - (pdy * velocity));
		calculate_walls();
	
