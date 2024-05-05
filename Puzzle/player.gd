extends CharacterBody2D

@onready var move_timer = $MoveTimer

var can_move = true  # Control variable to manage turns
var curr_pos = [15.5, 8.5]
var curr_posi = Vector2i(15.5*64, 8.5*64)
var move_queue = [0, 0]
var lantern_pos = curr_pos
var has_lantern = true
var on_script = true

signal turn_end(curr_pos)

func _ready():
	position = curr_posi
	print(position)

func _physics_process(delta):
	move_queue = [0, 0]
	if !on_script:
		if can_move:
			if Input.is_action_pressed("Up"):
				move_queue[1] += -1
			elif Input.is_action_pressed("Down"):
				move_queue[1] += 1
			elif Input.is_action_pressed("Left"):
				move_queue[0] += -1
			elif Input.is_action_pressed("Right"):
				move_queue[0] += 1
			if Input.is_action_pressed("Turn"):
				can_move = false
				var pending_pos = [curr_pos[0]+move_queue[0], curr_pos[1]+move_queue[1]]
				emit_signal("turn_end", pending_pos)
				move_timer.start()
		
		if Input.is_action_just_released("Turn"):
			print(curr_pos)
			can_move = true
		
		if Input.is_action_just_pressed("P_Lantern"):
			if lantern_pos == curr_pos:
				has_lantern = not has_lantern
				print("has_lantern: " + str(has_lantern))
		
		if has_lantern:
			lantern_pos = curr_pos

func _on_move_timer_timeout():
	can_move = true

