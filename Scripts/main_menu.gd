extends CanvasLayer

class_name MainMenu

@onready var pointer = $Pointer

@onready var selector_positions = [
	$SelectorPositions/FrankiePosition,
	$SelectorPositions/WolfiePosition,
	$SelectorPositions/WitchPosition,
	$SelectorPositions/HunterPosition
]

var current_index = 0

func _ready():
	pointer.position = selector_positions[0].position

func _input(event):
	if Input.is_action_just_pressed("up"):
		if current_index == 0:
			return
		current_index -= 1
		
		var tween = get_tree().create_tween()
		tween.tween_property(pointer, "position", selector_positions[current_index].position, .5)
	
	elif  Input.is_action_just_pressed("down"):
		if current_index == selector_positions.size() - 1:
			return
		current_index += 1
		
		var tween = get_tree().create_tween()
		tween.tween_property(pointer, "position", selector_positions[current_index].position, .5)
	
	elif Input.is_action_just_pressed("accept"):
		GameConfig.player_type = GameConfig.PlayerType.values()[current_index]
		get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")
