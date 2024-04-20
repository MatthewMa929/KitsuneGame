extends CharacterBody2D

@onready var player = $"../Player"

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
	pass
	
func _physics_process(delta):
	pass

func move():
	match state:
		WAIT:
			if player_path_arr.size() < 6:
				print("CHASE")
				state = CHASE
		CHASE:
			if torch_path_arr.size() > 3:
				pass
				#position = torch_path_arr[1]
			elif player_path_arr.size() > 6:
				print("WAIT")
				state = WAIT
			else:
				position = player_path_arr[1]
		WANDER:
			pass
		LIGHT:
			pass
		RUN:
			pass


func _on_puzzle_enemy_turn():
	move()
