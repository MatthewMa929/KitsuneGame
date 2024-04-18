extends CharacterBody2D

@onready var move_timer = $MoveTimer

const SPEED = 64.0
var can_move = true  # Control variable to manage turns
var curr_pos = [15, 8]

signal turn_end

func _ready():
	pass

func _physics_process(delta):
	if can_move:
		if Input.is_action_pressed("Up"):
			curr_pos[1] += -1
		elif Input.is_action_pressed("Down"):
			curr_pos[1] += 1
		elif Input.is_action_pressed("Left"):
			curr_pos[0] += -1
		elif Input.is_action_pressed("Right"):
			curr_pos[0] += 1
		if Input.is_action_pressed("Turn"):
			can_move = false
			emit_signal("turn_end")
			move_timer.start()
	
	position = Vector2(curr_pos[0]*64, curr_pos[1]*64)
	
	if Input.is_action_just_released("Turn"):
		print(curr_pos)
		can_move = true


func _on_move_timer_timeout():
	can_move = true
