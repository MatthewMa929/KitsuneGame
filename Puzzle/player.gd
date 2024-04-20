extends CharacterBody2D

@onready var move_timer = $MoveTimer

var can_move = true  # Control variable to manage turns
var curr_pos = [15.5, 8.5]
var move_queue = [0, 0]

signal turn_end(curr_pos)

func _ready():
	position = Vector2(curr_pos[0]*64, curr_pos[1]*64)
	print(position)

func _physics_process(delta):
	move_queue = [0, 0]
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
		#print(curr_pos)
		can_move = true


func _on_move_timer_timeout():
	can_move = true
