extends Area2D

class_name Projectile
@onready var sprite_2d = $Sprite2D

const FRANKIE_PROJECTILE = preload("res://Assets/Player/frankie_projectile.png")
const HUNTER_PROJECTILE = preload("res://Assets/Player/hunter_projectile.png")
const WITCH_PROJECTILE = preload("res://Assets/Player/witch_projectile.png")
const WOLFIE_PROJECTILE = preload("res://Assets/Player/wolfie_projectile.png")

var speed = 500
var projectile_prefix

func _ready():
	print_debug(projectile_prefix)
	match projectile_prefix:
		"frankie":
			sprite_2d.texture = FRANKIE_PROJECTILE
		"wolfie":
			sprite_2d.texture = WOLFIE_PROJECTILE
		"hunter":
			sprite_2d.texture = HUNTER_PROJECTILE
		"witch":
			sprite_2d.texture = WITCH_PROJECTILE

func _process(delta):
	position += Vector2.RIGHT * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

