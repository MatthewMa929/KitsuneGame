extends CharacterBody2D

@onready var player = $"../Player"

#Will not approach directly, only trying to snuff out the torches.

signal turn_off(pos)

enum {
	WAIT,
	CHASE,
	WANDER,
	LIGHT
}

var state = WAIT
var player_path_arr = []
var torch_path_arr = []
var can_chase = false
var spawn


func _ready():
	print(position)
	
func _physics_process(delta):
	pass
	#if player.position == position && can_chase && !player.on_script:
		#emit_signal("player_lost")
		#print("lost")
		#get_tree().reload_current_scene()
	#if player.position == position && !can_chase && !player.on_script:
		#emit_signal("player_won")
		#print("won")

func move():
	match state:
		WAIT:
			if check_chase():
				change_state(CHASE)
			elif check_light():
				change_state(LIGHT)
		CHASE:
			print(player_path_arr)
			if check_chase():
				position = player_path_arr[1]
			elif check_light():
				change_state(LIGHT)
			else:
				change_state(WAIT)
		LIGHT:
			if check_chase():
				change_state(CHASE)
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

func check_light():
	if torch_path_arr.size() > 0:
		return true

func check_chase():
	if player_path_arr.size() < 7 && can_chase && player_path_arr.size() > 1:
		return true
	return false

func change_state(pending_state):
	if pending_state == WAIT:
		state = WAIT
	elif pending_state == LIGHT:
		state = LIGHT
		move()
	elif pending_state == CHASE:
		state = CHASE
		move()

func _on_puzzle_enemy_turn():
	move()
