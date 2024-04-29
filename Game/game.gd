extends Node

@onready var puzzle = $Puzzle
@onready var visual_novel = $VisualNovel

func _on_visual_novel_switch_to_puzzle():
	puzzle.visible = true
	visual_novel.visible = false

func _process(delta):
	if Input.is_action_just_pressed("Skip"):
		_on_visual_novel_switch_to_puzzle()
