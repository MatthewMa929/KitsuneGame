extends Node

@onready var text_timer = $TextTimer
@onready var dot_timer = $DotTimer
@onready var talk_timer = $TalkTimer
@onready var curr = $Story
@onready var body = $Screen/BodyContainer/BodyText

var char_index = 0
var path_arr = [0]
var bb_num = 0
var talking = false

func _ready():
	body.text = curr.text

func _process(delta):
	if Input.is_action_just_pressed("Continue"):
		newCurr(curr.jumpToNode)

func newCurr(path):
	curr = get_node(path)
	path_arr.append(curr.name)  
	char_index = 0
	text_timer.start()
	body.text = curr.text
	print(curr.text)
	body.visible_characters = char_index
	print(body.visible_characters)
	bb_num = 0
	
func _on_text_timer_timeout():
	if char_index+1 < body.text.length():
		if body.text[char_index] == '[':
			var bb_count = 0
			while body.text[char_index+bb_count] != ']':
				bb_count += 1
			bb_num += bb_count + 1
			char_index += bb_count
		if body.text[char_index] == '“':
			talking = true
		elif body.text[char_index] == '.':
			text_timer.stop()
			if talking == false:
				dot_timer.start()
			else:
				talk_timer.start()
		elif body.text[char_index] == '”':
			talking = false
			text_timer.stop()
			dot_timer.start()
		char_index += 1
		body.visible_characters = char_index-bb_num
	else:
		char_index += 1
		body.visible_characters = body.text.length()

func _on_dot_timer_timeout():
	text_timer.start()
	
func _on_talk_timer_timeout():
	text_timer.start()
