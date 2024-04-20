extends Node

#11x18

signal enemy_turn

@onready var map = $Map
@onready var tileMap = map.curr_level
@onready var player = $Map/Player
@onready var enemy = $Map/Enemy

func is_moveable(pos):
	var coords = Vector2i(pos[0], pos[1])
	var next_cell = tileMap.get_cell_atlas_coords(0, coords)
	if next_cell == Vector2i(0, 0): #Wall
		#print("No go")
		return false
	elif next_cell == Vector2i(2, 0): #Torch
		#print("Torch")
		turn_on(coords)
		return false
	#print("Can go")
	return true

func _on_player_turn_end(curr_pos):
	if is_moveable(curr_pos):
		player.position = Vector2(curr_pos[0]*64, curr_pos[1]*64)
		player.curr_pos = curr_pos
		enemy.player_path_arr = get_path_arr(enemy.position, player.position)
		find_closest(map.torches)
		#print(enemy.player_path_arr)
		emit_signal("enemy_turn")

func get_path_arr(pt1, pt2):
	return map.astar_grid.get_point_path(Vector2i(pt1[0], pt1[1])/64, Vector2i(pt2[0], pt2[1])/64)

func turn_on(pos):
	for i in range(map.torches.size()):
		if map.torches[i][0] == pos:
			map.status[i] = true
			print("On")

func find_closest(arr):
	var closest_arr = arr.duplicate(true)
	var closest = []
	print(arr)
	for fill in range(11*18):
		closest.append(0)
	for i in range(closest_arr.size()):
		if typeof(closest_arr[i]) == TYPE_ARRAY:
			closest_arr[i] = find_closest(arr[i])
			print(closest_arr, "CA")
		else:
			#print(enemy.position, [arr[i][0]*64+32, arr[i][1]*64+32])
			var pending_path = get_path_arr(enemy.position, [closest_arr[i][0]*64+32, closest_arr[i][1]*64+32])
			#print(pending_path)
			if closest.size() > pending_path.size():
				closest = pending_path
	print(closest, "C")
	return closest
