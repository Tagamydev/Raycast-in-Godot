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
var	maxdist = 30;

# this arrays work as blocks in the map, 
# you can add or edit them to make diferent maps.
var	Map_End = [1, 1, 1, 1, 1, 1, 1, 1];
var	Map_Mid = [1, 0, 0, 0, 0, 0, 0, 1];
var	Map_MidE = [1, 0, 0, 0, 1, 0, 0, 1];

# place your blocks here, 
# only dont forget to change the resolution.
var	Map = [
Array(Map_End.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_Mid.duplicate()), 
Array(Map_MidE.duplicate()), 
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

func	calculateWall(wall: float):
	var	wallStart = Vector2(i, 0);
	var	wallEnd = Vector2(i, 0);
	var	wallLen = 0;
	var	result = [];

	result.resize(2);
	wallLen = 500 / wall;
	wallStart[1] = (height / 2.0) - (wallLen / 2);
	wallEnd[1] = (height / 2.0) + (wallLen / 2.0);

	
	result[0] = wallStart;
	result[1] = wallEnd;
	return result;

func	drawWalls(iterator: int):
	var	wall = [];

	wall = calculateWall(walls[iterator][0]);
	if walls[iterator][1] == 1:
		draw_line(wall[0], wall[1], Color.CHARTREUSE, 1);
	else:
		draw_line(wall[0], wall[1], Color.DARK_GREEN, 1);


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
			drawWalls(i);
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
	walls.fill(Vector2(0, 0));
	rays.resize(width + 1);
	rays.fill(Vector3(0, 0, 0));
	
	MapToogle = true;
	fovMulti = float(fov) / float(width);
	calculate_walls();

# funtions
func	ddaGetnextX(nextx: float, raya: float):
	return ((nextx - playerPos[0]) / (cos(degToRad(raya))));
	
func	ddaGetnextY(nexty: float, raya: float):
	return ((nexty - playerPos[1]) / (-sin(degToRad(raya))));
	

func	ddaCheckMap(mapx: float, mapy: float):
	if mapx < 0 or mapy < 0:
		return (false);
	if mapy > Map.size() or mapx > Map[0].size():
		return (false);
	return (true); 

func	ddaCalculateXRight(raya: float):
	var rayx = 0.0;
	var	rayy = 0.0;
	var	delty = 0.0;
	var	nextx = 0.0;
	var	z = 0;
	
	rayx = int(playerPos[0] + 1);
	delty = -sin(degToRad(raya));
	rayy = playerPos[1] + delty * ddaGetnextX(rayx, raya);
	
	# check if this ray hits a wall, if not then start the loop
	if ddaCheckMap(rayx, rayy) == false:
		return Vector2(rayx, rayy);
	if Map[rayy][rayx] == 1:
		return Vector2(rayx, rayy);
		
	nextx = (int(rayx + 1) - rayx) / (cos(degToRad(raya)));
	z = 0;
	while z < 10:
		rayx = int(rayx + 1);
		rayy = rayy + delty * nextx;
		if ddaCheckMap(rayx, rayy) == false:
			return Vector2(rayx, rayy);
		if Map[rayy][rayx] == 1:
			return Vector2(rayx, rayy);
		z = z + 1;
	return (Vector2(rayx, rayy));
	

func	ddaCalculateXLeft(raya: float):
	var rayx = 0.0;
	var	rayy = 0.0;
	var	delty = 0.0;
	var	nextx = 0.0;
	var	z = 0;
	
	rayx = int(playerPos[0]);
	delty = -sin(degToRad(raya));
	rayy = playerPos[1] + delty * ddaGetnextX(rayx, raya);

	# check if this ray hits a wall, if not then start the loop
	if ddaCheckMap(rayx - 1, rayy) == false:
		return Vector2(rayx, rayy);
	if Map[rayy][rayx - 1] == 1:
		return Vector2(rayx, rayy);

	nextx = (int(rayx - 1) - rayx) / (cos(degToRad(raya)));
	z = 0;
	while z < 10:
		rayx = int(rayx - 1);
		rayy = rayy + delty * nextx;
		if ddaCheckMap(rayx - 1, rayy) == false:
			return Vector2(rayx, rayy);
		if Map[rayy][rayx - 1] == 1:
			return Vector2(rayx, rayy);
		z = z + 1;
	return (Vector2(rayx, rayy));

func	ddaCalculateYUp(raya: float):
	var rayx = 0.0;
	var	rayy = 0.0;
	var	delty = 0.0;
	var	nexty = 0.0;
	var	z = 0;
	
	rayy = int(playerPos[1]);
	delty = cos(degToRad(raya));
	rayx = playerPos[0] + delty * ddaGetnextY(rayy, raya);

	# check if this ray hits a wall, if not then start the loop
	if ddaCheckMap(rayx, rayy - 1) == false:
		return Vector2(rayx, rayy);
	if Map[rayy - 1][rayx] == 1:
		return Vector2(rayx, rayy);

	nexty = (int(rayy - 1) - rayy) / (-sin(degToRad(raya)));
	z = 0;
	while z < 10:
		rayy = int(rayy - 1);
		rayx = rayx + delty * nexty;
		if ddaCheckMap(rayx, rayy - 1) == false:
			return Vector2(rayx, rayy);
		if Map[rayy - 1][rayx] == 1:
			return Vector2(rayx, rayy);
		z = z + 1;
	return (Vector2(rayx, rayy));

func	ddaCalculateYDown(raya: float):
	var rayx = 0.0;
	var	rayy = 0.0;
	var	delty = 0.0;
	var	nexty = 0.0;
	var	z = 0;
	
	rayy = int(playerPos[1] + 1);
	delty = cos(degToRad(raya));
	rayx = playerPos[0] + delty * ddaGetnextY(rayy, raya);

	# check if this ray hits a wall, if not then start the loop
	if ddaCheckMap(rayx, rayy) == false:
		return Vector2(rayx, rayy);
	if Map[rayy][rayx] == 1:
		return Vector2(rayx, rayy);

	nexty = (int(rayy + 1) - rayy) / (-sin(degToRad(raya)));
	z = 0;
	while z < 10:
		rayy = int(rayy + 1);
		rayx = rayx + delty * nexty;
		if ddaCheckMap(rayx, rayy) == false:
			return Vector2(rayx, rayy);
		if Map[rayy][rayx] == 1:
			return Vector2(rayx, rayy);
		z = z + 1;
	return (Vector2(rayx, rayy));

func	distanceVectors(vector1: Vector2, vector2: Vector2):
	return (
		sqrt(
		pow((vector2[0] - vector1[0]), 2) + 
		pow((vector2[1] - vector1[1]), 2)));

func	distComparation(ray1: Vector2, ray2: Vector2):
	if distanceVectors(playerPos, ray1) < distanceVectors(playerPos, ray2):
		return Vector3(ray1[0], ray1[1], 0);
	else:
		return Vector3(ray2[0], ray2[1], 1);

# raya is ray angle
func	ddaAlgorithm(raya: float):
	var ray1 = Vector2(0, 0);
	var	ray2 = Vector2(0, 0);
	var	result = Vector3(0, 0, 0);
	var	side = 0;
	
	if (raya < 90.0 and raya > 0):
		ray1 = ddaCalculateXRight(raya);
		ray2 = ddaCalculateYUp(raya);

		result = distComparation(ray1, ray2);
	elif (raya > 270.0 and raya < 360.0):
		ray1 = ddaCalculateXRight(raya);
		ray2 = ddaCalculateYDown(raya);
		
		result = distComparation(ray1, ray2);
	elif (raya > 90.0 and raya < 180.0):
		ray1 = ddaCalculateXLeft(raya);
		ray2 = ddaCalculateYUp(raya);

		result = distComparation(ray1, ray2);;
	elif (raya > 180 and raya < 270):
		ray1 = ddaCalculateXLeft(raya);
		ray2 = ddaCalculateYDown(raya);
		
		result = distComparation(ray1, ray2);
	elif (raya == 180 or raya == 0):
		if raya == 180:
			ray1 = ddaCalculateXLeft(raya);
		else:
			ray1 = ddaCalculateXRight(raya);
		result = Vector3(ray1[0], ray1[1], 0);
	elif (raya == 90 or raya == 270):
		if raya == 90:
			ray1 = ddaCalculateYUp(raya);
		else:
			ray1 = ddaCalculateYDown(raya);
		result = Vector3(ray1[0], ray1[1], 1);
	return (result);

func	calcRayDist(ray: int):
	var	angle = FixAng((float(pa) - (fov / 2.0)) + (ray * fovMulti));
	var	distance = 0;

	rays[ray] = ddaAlgorithm(angle);
	distance = distanceVectors(playerPos, Vector2(rays[ray][0], rays[ray][1]));
	if distance > maxdist:
		distance = maxdist;
	return (Vector2(distance, rays[ray][2]));

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
	
