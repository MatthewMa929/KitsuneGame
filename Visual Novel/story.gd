extends Node

class_name StoryNode

@export_multiline var text:String
@export var type:String
@export var jumpToNode:String
@export var speakingChar:String
@export var leavingChar:String
@export var specialEffect:String


func fill_node(i, dialogue_dict_entry):
	name = str("line", i)
	speakingChar = dialogue_dict_entry["Character name"]
	leavingChar = dialogue_dict_entry["Leaving"]
	text = dialogue_dict_entry["Dialogue"]
	jumpToNode = str("Story/line", i+1)
	specialEffect = dialogue_dict_entry["Special effects"]
	
