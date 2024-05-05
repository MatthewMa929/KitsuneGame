extends Node

class_name StoryNode

@export_multiline var text:String
@export var type:String
@export var jumpToNode:String
@export var speakingChar:String
@export var leavingChar:String
@export var specialEffect:String
@export var background:String

@onready var visual_novel = $".."


func fill_node(i, dialogue_dict_entry):
	if str(dialogue_dict_entry["id"]) == "lose":
		name = str("lose_line",i-119)
		if i - 119 < 7:
			jumpToNode = str("Story/lose_line", i-118)
	elif str(dialogue_dict_entry["id"]) == "endlose":
		name = "endlose"
		#print(visual_novel.old_story_node.jumpToNode)
		jumpToNode = visual_novel.old_story_node.jumpToNode
		visual_novel.getNode(str("Story/loseline", i - 120)).jumpToNode = "endlose"
	else:
		name = str("line", i)
		jumpToNode = str("Story/line", i+1)
	speakingChar = dialogue_dict_entry["Character name"]
	leavingChar = dialogue_dict_entry["Leaving"]
	text = dialogue_dict_entry["Dialogue"]
	specialEffect = dialogue_dict_entry["Special effects"]
	background = dialogue_dict_entry["Background"]
	
	
