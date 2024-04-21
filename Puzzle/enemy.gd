extends CharacterBody2D

@onready var player = $"../Player"

signal turn_off(pos)

enum {
	WAIT,
	CHASE,
	WANDER,
	LIGHT,
	RUN
}

var state = WAIT
var player_path_arr = []
var torch_path_arr = []


func _ready():
	print(position)
	
func _physics_process(delta):
	pass

func move():
	match state:
		WAIT:
			if torch_path_arr.size() < 5 and torch_path_arr.size() > 0:
				state = LIGHT
				move()
			if player_path_arr.size() < 7:
				print("CHASE")
				state = CHASE
		CHASE:
			if torch_path_arr.size() < 5 and torch_path_arr.size() > 0:
				state = LIGHT
				move()
			elif player_path_arr.size() > 7:
				print("WAIT")
				state = WAIT
			else:
				position = player_path_arr[1]
		WANDER:
			pass
		LIGHT:
			if torch_path_arr.size() > 2:
				print(torch_path_arr)
				position = torch_path_arr[1]
			else: #Turn the torch off
				var coords = Vector2i(torch_path_arr[1][0], torch_path_arr[1][1])
				emit_signal("turn_off", coords)
				state = WAIT
				#move()
		RUN:
			pass


func _on_puzzle_enemy_turn():
	move()
