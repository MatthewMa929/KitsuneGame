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
		var closest_arr = map.torches.duplicate(true)
		var closest = []
		for fill in range(11*18):
			closest.append(0)
		for i in range(map.torches.size()):
			for j in range(map.torches[i].size()):
				var path = get_path_arr(enemy.position, [map.torches[i][j][0]*64+32, map.torches[i][j][1]*64+32])
				if path:
					closest_arr[i][j] = path
		for k in range(closest_arr.size()):
			if closest.size() > closest_arr[k][1].size():
				closest = closest_arr[k][1]
		enemy.torch_path_arr = closest
		emit_signal("enemy_turn")

func get_path_arr(pt1, pt2):
	return map.astar_grid.get_point_path(Vector2i(pt1[0], pt1[1])/64, Vector2i(pt2[0], pt2[1])/64)

func turn_on(pos):
	for i in range(map.torches.size()):
		if map.torches[i][0] == pos:
			map.status[i] = true
			print("On")
