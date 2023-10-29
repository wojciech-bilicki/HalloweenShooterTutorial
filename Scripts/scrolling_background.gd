extends Node2D

class_name ScrollingBg

@export var bg_image: Texture

@export var speed = -150

var children

func _ready():
	children = get_children()
	
	for i in children.size():
		children[i].texture = bg_image
	
	for i in children.size() - 1:
		children[i + 1].global_position.x = children[i].global_position.x + children[i].texture.get_width() * children[i].scale.x

func _process(delta):
	for child in children:
		child.global_position.x += speed * delta
		
		if child.global_position.x < -child.texture.get_width() * child.scale.x:
			child.global_position.x = children.back().global_position.x + child.texture.get_width() * child.scale.x
			children.pop_front()
			children.push_back(child)
	
