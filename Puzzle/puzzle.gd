extends Node2D

#11x18

signal enemy_turn
signal lantern_moved(lantern_light)

@onready var map = $Map
@onready var tileMap = map.curr_level
@onready var player = $Map/Player
@onready var enemy = $Map/Enemy
@onready var lantern = $Map/Lantern
@onready var collidable = []
@onready var light_fire = $LightFire

var lantern_light = []

signal player_won
signal player_lost

func _ready():
	pass
	#enemy.spawn = enemy.global_position
	#make_light()
	#lantern.position = Vector2(lantern_light[0][0]*64, lantern_light[0][1]*64)
	#lantern.visible = false
	#print(lantern_light)

func _process(delta):
	enemy.can_chase = check_lit()
	check_win_lose()
	if check_lit():
		map.make_grid_dark()
	else:
		map.make_grid_light()

func check_win_lose():
	if player.position == enemy.position && enemy.can_chase && !player.on_script:
		emit_signal("player_lost")
		print("lost")
		#get_tree().reload_current_scene()
	if player.position == enemy.position && !enemy.can_chase && !player.on_script:
		if player.has_lantern:
			emit_signal("player_won")
		elif map.status == [true, true, true]:
			emit_signal("player_won")
		print("won")
	if map.status == [true, true, true] && map.curr_level == map.levelCT && !player.on_script:
		emit_signal("player_won")
		print("won_torches")

func is_moveable(pos):
	var coords = Vector2i(pos[0], pos[1])
	var next_cell = tileMap.get_cell_atlas_coords(0, coords)
	if next_cell == Vector2i(0, 0) or next_cell == Vector2i(0, 1): #Wall
		print("No go")
		return false
	elif next_cell in map.torch_cells: #Torch
		print("Torch")
		turn_on(coords)
		return false
	elif next_cell == Vector2i(2, 1):
		return false
	return true

func _on_player_turn_end(curr_pos):
	if is_moveable(curr_pos):
		player.position = Vector2(curr_pos[0]*64, curr_pos[1]*64)
		player.curr_pos = curr_pos
	if !player.has_lantern:
		lantern.visible = true
		lantern.position = Vector2(lantern_light[0][0]*64, lantern_light[0][1]*64)
	else:
		player.lantern_pos = player.curr_pos
		lantern.visible = false
		make_light()
	check_win_lose()
	start_enemy_turn()

func get_path_arr(pt1, pt2):
	return map.astar_grid.get_point_path(Vector2i(pt1[0], pt1[1])/64, Vector2i(pt2[0], pt2[1])/64)

func turn_on(pos):
	for i in range(map.torches.size()):
		if map.torches[i][0] == pos:
			map.status[i] = true
			light_fire.play()
			print("On")

func start_enemy_turn():
	update_collidable()
	enemy.player_path_arr = get_path_arr(enemy.global_position, player.global_position)
	get_torch_path()
	emit_signal("enemy_turn")

func _on_enemy_turn_off(pos):
	for i in range(map.torches.size()):
		#print(map.torches, pos)
		if map.torches[i][0] == pos:
			map.status[i] = false
			print("Off")

func check_lit():
	var lit = 0
	var unlit = 0
	for i in range(map.status.size()):
		if map.status[i]:
			lit += 1
		else:
			unlit += 1
	if lit > unlit:
		return false
	return true

func get_torch_path():
	var closest_arr = map.torches.duplicate(true)
	var closest = []
	for fill in range(11*18):
		closest.append(0)
	for i in range(map.torches.size()): #All the torches
		for j in range(map.torches[i].size()): #Torch position + All the directions the torch can be accessed
			var path = get_path_arr(enemy.position, [map.torches[i][j][0]*64+32, map.torches[i][j][1]*64+32])
			if path:
				closest_arr[i][j] = path
				#print(closest_arr)
			else:
				closest_arr[i][j] = closest
	for k in range(closest_arr.size()):
		if closest_arr[k].size() > 2:
			var direc_min = closest_arr[k][1]
			#print(direc_min)
			for h in range(2, closest_arr[k].size()):
				if direc_min.size() > closest_arr[k][h].size():
					direc_min = closest_arr[k][h]
			closest_arr[k][1] = direc_min
		if closest.size() - 1 > closest_arr[k][1].size() && map.status[k]:
			closest = closest_arr[k][1]
			closest.append(map.torch_pos[k])
	enemy.torch_path_arr = closest

func update_collidable():
	var lit = 0
	var unlit = 0
	for tor in range(map.torches.size()):
		collidable.append(map.torches[tor])
		if map.status[tor]:
			lit += 1
		else:
			unlit += 1
	collidable.append(player.position)

func make_light():
	lantern_light = map.direc_array(player.lantern_pos)
	if player.has_lantern:
		emit_signal("lantern_moved", lantern_light)
		#print(lantern_light)

func reset_map():
	print('reset')
	for i in range(map.old_lit.size()):
		map.curr_level.set_cell(0, map.old_lit[i], 0, Vector2i(1, 0))
	enemy.position = map.curr_level.enemy_spawn
	player.curr_pos = map.curr_level.player_spawn
	player.position = create_posi(player.curr_pos)
	map.ori_status = tileMap.status
	map.status = map.ori_status.duplicate(true)
	print(map.status)
	player.lantern_pos = map.curr_level.player_spawn
	player.has_lantern = true
	lantern.position = player.position
	lantern.visible = false
	make_light()

func _on_map_set_up_spawns():
	reset_map()

func create_posi(pos):
	return Vector2(pos[0]*64, pos[1]*64)

func _on_enemy_player_lost():
	reset_map()
