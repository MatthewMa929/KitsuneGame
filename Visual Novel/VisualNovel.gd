extends Control

@onready var background = $Background
@onready var text_timer = $TextTimer
@onready var dot_timer = $DotTimer
@onready var talk_timer = $TalkTimer
@onready var curr_story_node = $Story
@onready var dialogue_text = $DialogueTextLabel
@onready var dialogue_bg = $DialogueMeshBox
@onready var char_name_text = $CharNameTextLabel
@onready var char_name_bg = $CharNameMeshBox
@onready var screen = $Screen
@onready var spec_effects = $SpecialEffects
var old_story_node

signal switch_to_puzzle

var dialogue_file = "res://Assets/kitsune_game_dialogue.json"
var json_as_text = FileAccess.get_file_as_string(dialogue_file)
var dialogue_dict = JSON.parse_string(json_as_text)


var char_index = 0
var bb_num = 0
var talking = false
var onscreen_char_sprites = []
var prev_speaker = ""

func _ready():
	var screen_size = get_viewport().size
	background.position = Vector2(screen_size.x/2, screen_size.y/2)
	makeStoryNodes()
	dialogue_text.text = curr_story_node.text
	curr_story_node.jumpToNode = str("Story/line0")
	newCurr(curr_story_node.jumpToNode)
	

func _process(delta):
	if Input.is_action_just_pressed("Continue"):
		# shows full message
		if dialogue_text.visible_characters != dialogue_text.text.length():
			char_index = dialogue_text.text.length()
		else:
			newCurr(curr_story_node.jumpToNode)

func newCurr(path):
	curr_story_node = get_node(path)

# set up dialogue stuff
	char_index = 0
	dialogue_text.text = curr_story_node.text
	dialogue_text.visible_characters = char_index
	# if the line is an internal line, changes the color of the text
	if dialogue_text.text != "" and dialogue_text.text[0] =="(":
		dialogue_text.text = str("[color=#a6ccff]", dialogue_text.text, "[/color]")

# set up visual stuff
	# put name on screen
	if curr_story_node.speakingChar == "":
		char_name_bg.visible = false
		char_name_text.text = ""
	else:
		char_name_bg.visible = true
		char_name_text.text = curr_story_node.speakingChar
	#put text box on screen
	if curr_story_node.text == "":
		dialogue_bg.visible = false
	else:
		dialogue_bg.visible = true

	# if the speaking character is not already oncreen, add them to the screen
	if curr_story_node.speakingChar not in onscreen_char_sprites:
		if curr_story_node.speakingChar != "":
			addNewCharacterSprite(curr_story_node.speakingChar)
	setSpeakingChar(curr_story_node.speakingChar)
	# goes through all the characters on screen and removes the ones that are leaving
	removeChar(curr_story_node.leavingChar)

# do a special effect
	if curr_story_node.specialEffect == "text to puzzle":
		emit_signal("switch_to_puzzle")
	
	#doSpecialEffect(curr_story_node.specialEffect)
	
	if curr_story_node.specialEffect == "":
		loadBackground(curr_story_node.background)
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
	# is there a better way to do this? yes, but i will most likely never figure that out
	if "???" in schar:
		if "(" in schar:
			var len_schar = schar.find(")") - schar.find("(")
			schar = schar.substr(schar.find("(") + 1, len_schar-1)
			onscreen_char_sprites.append(schar)
		else:
			return
	else:
		onscreen_char_sprites.append(schar)
	drawNewSprite(schar)

func drawNewSprite(schar):
	var screen_size = get_viewport().size
	var new_char_sprite = Sprite2D.new()
	new_char_sprite.texture = load(str("res://Sprites/", schar,".png"))
	new_char_sprite.scale *= 0.5
	new_char_sprite.name = schar
	var x_pos = screen_size.x/2
	if onscreen_char_sprites.size() == 1:
		x_pos = screen_size.x/5+50
	elif onscreen_char_sprites.size() == 2:
		x_pos = screen_size.x /5*4-50
	new_char_sprite.position = Vector2(x_pos, screen_size.y - (new_char_sprite.texture.get_height()/4))
	new_char_sprite.z_as_relative = 0
	add_child(new_char_sprite)

# Shrinks the previous speaker and grows the current speaker
func setSpeakingChar(speaking_char):
	if prev_speaker != "":
		var prev = get_node(prev_speaker)
		# If there is no current speaker, grows the prev speaker
		# so it remains the same size
		if speaking_char == "":
			prev.scale *= 1.1
		prev.scale /= 1.1
	if speaking_char != "":
		var speaking = get_node(speaking_char)
		speaking.scale *= 1.1
		prev_speaker = speaking_char

	

func removeChar(to_remove):
	for onscreen_char in onscreen_char_sprites:
		if onscreen_char in to_remove or to_remove == "all":
			remove_child(get_node(onscreen_char))
			onscreen_char_sprites.erase(onscreen_char)


func doSpecialEffect(sfx):
	if sfx == "blink":
		spec_effects.play("fade in")
		if spec_effects.animation_changed:
			if not curr_story_node.background.is_empty():
				loadBackground(curr_story_node.background)
		spec_effects.play("fade out")
	if sfx == "fade to black":
		spec_effects.play("fade in")
	if sfx == "fade from black":
		spec_effects.play("fade out")

func loadBackground(bg):
	if not bg.is_empty():
		background.texture = load(str("res://Assets/Background_",bg,".png"))
