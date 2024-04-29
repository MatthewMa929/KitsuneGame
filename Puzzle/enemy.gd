extends CharacterBody2D

@onready var player = $"../Player"

#Will not approach directly, only trying to snuff out the torches.

signal turn_off(pos)
signal player_won
signal player_lost

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
var can_chase = false


func _ready():
	print(position)
	
func _physics_process(delta):
	if player.position == position && state == CHASE:
		emit_signal("player_lost")
		print("lost")
		#get_tree().reload_current_scene()
	if player.position == position && state != CHASE:
		emit_signal("player_won")
		print("won")

func move():
	match state:
		WAIT:
			if check_chase():
				change_state(CHASE)
			elif check_light():
				change_state(LIGHT)
		CHASE:
			if check_chase():
				position = player_path_arr[1]
			elif check_light():
				change_state(LIGHT)
			else:
				change_state(WAIT)
		LIGHT:
			if torch_path_arr.size() > 2 and typeof(torch_path_arr[1]) != TYPE_INT:
				#print(torch_path_arr)
				position = torch_path_arr[1]
			elif typeof(torch_path_arr[1]) == TYPE_INT:
				change_state(WAIT)
			else: #Turn the torch off
				var coords = Vector2i(torch_path_arr[1][0], torch_path_arr[1][1])
				emit_signal("turn_off", coords)
				change_state(WAIT)
				#move()
		RUN:
			check_chase()

func check_light():
	if torch_path_arr.size() > 0:
		return true

func check_chase():
	if player_path_arr.size() < 7 && can_chase && player_path_arr.size() > 1:
		print(player_path_arr)
		return true
	return false

func change_state(pending_state):
	if pending_state == WAIT:
		state = WAIT
	if pending_state == LIGHT:
		state = LIGHT
		move()
	if pending_state == CHASE:
		state = CHASE
		move()

func _on_puzzle_enemy_turn():
	move()
