extends Node

class_name StoryNode

@export_multiline var text:String
@export var type:String
@export var jumpToNode:String
@export var speakingChar:String

func fill_node(i, dialogue_dict_entry):
	name = str("line", i)
	speakingChar = dialogue_dict_entry["Character name"]
	text = dialogue_dict_entry["Dialogue"]
	jumpToNode = str("Story/line", i+1)
	
