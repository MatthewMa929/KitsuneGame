extends CharacterBody2D

enum {
	WAIT,
	CHASE,
	LIGHT,
	RUN
}

var state = WAIT

func _ready():
	pass
	
func _physics_process(delta):
	match state:
		WAIT:
			pass
		CHASE:
			pass
		LIGHT:
			pass
		RUN:
			pass

func _on_player_turn_end():
	pass
