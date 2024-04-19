extends Node

#This will manage the turns of the player and the enemy. Will change the Player script to only move after this script has given permission.

signal enemy_turn

@onready var TileMapA = $Map/LevelA/TileMap
@onready var player = $Map/Player
@onready var enemy = $Map/Enemy

func is_moveable(pos):
	var coords = Vector2i(pos[0], pos[1])
	var next_cell = TileMapA.get_cell_atlas_coords(0, coords)
	if next_cell == Vector2i(0, 0):
		print("No go")
		return false
	print("can go")
	return true


func _on_player_turn_end(curr_pos):
	if is_moveable(curr_pos):
		player.position = Vector2(curr_pos[0]*64, curr_pos[1]*64)
		player.curr_pos = curr_pos
		emit_signal("enemy_turn")
