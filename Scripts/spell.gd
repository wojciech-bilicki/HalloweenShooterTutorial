extends Area2D

class_name Spell 
var speed = 300

var config

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

var damage 
var effect_duration
var type 

@onready var textures = [
	preload("res://Assets/Spells/ice-effect.png"),
	preload("res://Assets/Spells/fire-effect.png"),
	preload("res://Assets/Spells/poison-effect.png")
] 

@onready var collision_shapes = [
	preload("res://Resources/CollisionShapes/Spells/ice.tres"),
	preload("res://Resources/CollisionShapes/Spells/fire.tres"),
	preload("res://Resources/CollisionShapes/Spells/poison.tres")
]


func _ready():
	sprite_2d.texture = config.texture
	collision_shape_2d.shape = config.collision_shape
	damage = config.damage
	effect_duration = config.effect_duration
	type = config.type

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

