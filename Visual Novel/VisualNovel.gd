extends Node

@onready var text_timer = $TextTimer
@onready var dot_timer = $DotTimer
@onready var talk_timer = $TalkTimer
@onready var curr_story_node = $Story
@onready var dialogue_text = $DialogueTextLabel
@onready var screen = $Screen


var dialogue_file = "res://Assets/kitsune_game_dialogue.json"
var json_as_text = FileAccess.get_file_as_string(dialogue_file)
var dialogue_dict = JSON.parse_string(json_as_text)

var char_index = 0
var path_arr = [0]
var bb_num = 0
var talking = false
var onscreen_char_sprites = []

func _ready():
	makeStoryNodes()
	dialogue_text.text = curr_story_node.text
	curr_story_node.jumpToNode = str("Story/line0")
	newCurr(curr_story_node.jumpToNode)
	

func _process(delta):
	if Input.is_action_just_pressed("Continue"):
		if dialogue_text.visible_characters != dialogue_text.text.length():
			char_index = dialogue_text.text.length()
		else:
			newCurr(curr_story_node.jumpToNode)

func newCurr(path):
	curr_story_node = get_node(path)
				#path_arr.append(curr_story_node.name)  
	
	# set up dialogue stuff
	char_index = 0
	dialogue_text.text = curr_story_node.text
	dialogue_text.visible_characters = char_index
		# if the line is an internal line, changes the color of the text
	if "(" in dialogue_text.text:
		dialogue_text.text = str("[color=#a6ccff]", dialogue_text.text, "[/color]")
		
	# set up visual stuff
		# if the speaking character is not already oncreen, add them to the screen
	if curr_story_node.speakingChar not in onscreen_char_sprites:
		addNewCharacterSprite(curr_story_node.speakingChar)
		# goes through all the characters on screen and removes the ones that are leaving
	for onscreen_char in onscreen_char_sprites:
		if(onscreen_char) in curr_story_node.leavingChar:
			removeChar(onscreen_char)
		
	
	
	
	# do a special effect
	
	text_timer.start()
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

func addNewCharacterSprite(schar):
	if "???" in schar:
		schar = schar.substr(schar.find("("), schar.find(")"))
		onscreen_char_sprites.append(schar)
	else:
		onscreen_char_sprites.append(schar)
	var new_char_sprite = Sprite2D.new()
	new_char_sprite.texture = load(str("res://Sprites/", schar,".png"))
	new_char_sprite.scale *= 0.5
	add_child(new_char_sprite)
	print("add new char ", schar)

func removeChar(char_to_remove):
	pass
