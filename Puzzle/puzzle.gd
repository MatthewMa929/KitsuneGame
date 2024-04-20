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
	if next_cell == Vector2i(0, 0):
		print("No go")
		return false
	print("can go")
	return true

func _on_player_turn_end(curr_pos):
	if is_moveable(curr_pos):
		player.position = Vector2(curr_pos[0]*64, curr_pos[1]*64)
		player.curr_pos = curr_pos
		enemy.player_path_arr = get_path_arr(enemy.position, player.position)
		print(enemy.player_path_arr)
		emit_signal("enemy_turn")

func get_path_arr(pt1, pt2):
	return map.astar_grid.get_point_path(Vector2i(pt1[0], pt1[1])/64, Vector2i(pt2[0], pt2[1])/64)
