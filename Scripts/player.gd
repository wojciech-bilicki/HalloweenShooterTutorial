extends Area2D

class_name Player

signal player_damaged(current_health: int)
signal player_died
signal spell_selected(spell_number: int)
signal spell_casted(spell_index: int, timeout: float)

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shooting_system = $ShootingSystem
@onready var health_system = $HealthSystem as HealthSystem
@onready var spell_system = $SpellSystem


@export var speed = 400
var direction = Vector2.ZERO

var animation_prefix

func _ready():
	animation_prefix = GameConfig.PlayerType.keys()[GameConfig.player_type].to_snake_case()
	animated_sprite_2d.play("%s_default" % animation_prefix)
	shooting_system.animation_prefix = animation_prefix
	health_system.died.connect(on_died)
	spell_system.spell_selected.connect(on_spell_selected)
	spell_system.spell_casted.connect(on_spell_casted)

func on_spell_casted(spell_index: int, timeout: float):
	spell_casted.emit(spell_index, timeout)

func on_spell_selected(spell_index: int):
	spell_selected.emit(spell_index)

func _process(delta):

	var next_position = position + direction * speed * delta
	if !is_withing_screen_bounds(next_position):
		return
	position = next_position



func _input(event):
	if Input.is_action_pressed("up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		direction = Vector2.RIGHT
	else:
		direction = Vector2.ZERO
	



func is_withing_screen_bounds(next_position: Vector2):
	var half_size = collision_shape_2d.shape.get_rect().size / 2
	
	var viewport_size = get_viewport_rect().size
	
	if next_position.y > half_size.y && next_position.y + half_size.y < viewport_size.y && next_position.x > half_size.x && next_position.x + half_size.x < viewport_size.x:
		return true
	
	return false
	
func get_health():
	return health_system.health
	
func _on_area_entered(area):
	health_system.damage(1)
	player_damaged.emit(get_health())
	area.queue_free()
	
	var blink_tween = get_tree().create_tween()
	blink_tween.tween_property(animated_sprite_2d, "modulate", Color.RED, .25)
	blink_tween.chain().tween_property(animated_sprite_2d, "modulate", Color.WHITE, .25)

func on_died():
	player_died.emit()
	queue_free()
