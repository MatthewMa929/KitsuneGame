extends Node

@onready var text_timer = $TextTimer
@onready var dot_timer = $DotTimer
@onready var talk_timer = $TalkTimer
@onready var curr_story_node = $Story
@onready var dialogue_text = $DialogueTextLabel


var file = "res://Assets/kitsune_game_dialogue.json"
var json_as_text = FileAccess.get_file_as_string(file)
var dialogue_dict = JSON.parse_string(json_as_text)

var char_index = 0
var path_arr = [0]
var bb_num = 0
var talking = false

func _ready():
	#if dialogue_dict:
		#print(dialogue_dict)
	makeStoryNodes()
	dialogue_text.text = curr_story_node.text
	curr_story_node.jumpToNode = str("Story/line0")
	

func _process(delta):
	if Input.is_action_just_pressed("Continue"):
		newCurr(curr_story_node.jumpToNode)

func newCurr(path):
	curr_story_node = get_node(path)
	path_arr.append(curr_story_node.name)  
	char_index = 0
	text_timer.start()
	dialogue_text.text = curr_story_node.text
	print(curr_story_node.text)
	dialogue_text.visible_characters = char_index
	print(dialogue_text.visible_characters)
	bb_num = 0


func _on_text_timer_timeout():
	if char_index+1 < dialogue_text.text.length():
		if dialogue_text.text[char_index] == '[':
			var bb_count = 0
			while dialogue_text.text[char_index+bb_count] != ']':
				bb_count += 1
			bb_num += bb_count + 1
			char_index += bb_count
		if dialogue_text.text[char_index] == '“':
			talking = true
		elif dialogue_text.text[char_index] == '.':
			text_timer.stop()
			if talking == false:
				dot_timer.start()
			else:
				talk_timer.start()
		elif dialogue_text.text[char_index] == '”':
			talking = false
			text_timer.stop()
			dot_timer.start()
		char_index += 1
		dialogue_text.visible_characters = char_index-bb_num
	else:
		char_index += 1
		dialogue_text.visible_characters = dialogue_text.text.length()

func _on_dot_timer_timeout():
	text_timer.start()
	
func _on_talk_timer_timeout():
	text_timer.start()

func makeStoryNodes():
	for i in range(0, dialogue_dict.size() - 1):
		var story_node = StoryNode.new()
		story_node.fill_node(i, dialogue_dict[i])
		curr_story_node.add_child(story_node)
