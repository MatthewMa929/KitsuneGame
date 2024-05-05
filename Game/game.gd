extends Node

@onready var puzzle = $Puzzle
@onready var visual_novel = $VisualNovel

func _on_visual_novel_switch_to_puzzle():
	puzzle.map.new_puzzle()
	puzzle.visible = true
	visual_novel.visible = false
	puzzle.player.on_script = false
	visual_novel.old_story_node = visual_novel.curr_story_node

func _process(delta):
	if Input.is_action_just_pressed("Skip"):
		_on_visual_novel_switch_to_puzzle()


func _on_puzzle_player_lost():
	print('on_enemy_player_lost')
	visual_novel.visible = false
	puzzle.player.on_script = false
	puzzle.reset_map()


func _on_puzzle_player_won():
	print('on_enemy_player_won')
	visual_novel.visible = true
	puzzle.player.on_script = true
