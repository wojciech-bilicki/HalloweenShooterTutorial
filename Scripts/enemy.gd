extends Area2D

class_name Enemy

signal  killed

var sounds = [
	preload("res://Assets/sounds/hit1.mp3"),
	preload("res://Assets/sounds/hit2.mp3"),
	preload("res://Assets/sounds/hit3.mp3"),
	preload("res://Assets/sounds/hit4.mp3"),
	preload("res://Assets/sounds/hit5.mp3"),
]

@onready var shooting_system = $ShootingSystem
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var timer = $ShootingSystem/Timer
@onready var audio_stream_player = $AudioStreamPlayer
@onready var health_system = $HealthSystem
@onready var progress_bar = $ProgressBar
@onready var spell_effector = $SpellEffector as SpellEffector


@export var speed = 250

var movement_points

var default_animation_name
var shooting_animation_name
var current_movement_point

func init(config, enemy_movement_points):
	default_animation_name = "%s_default" % config.enemy_name
	shooting_animation_name = "%s_shoot" % config.enemy_name
	speed = config.speed
	animated_sprite_2d.play(default_animation_name)
	movement_points = enemy_movement_points
	collision_shape_2d.shape = config.enemy_collision_shape
	health_system.health = config.health
	health_system.damaged.connect(on_damaged)
	health_system.died.connect(on_died)
	progress_bar.max_value = config.health
	progress_bar.value = config.health
	
	var random_point = movement_points.pick_random()
	current_movement_point = random_point.position
	
	shooting_system.shot.connect(on_shot)
	shooting_system.projectile_texture = config.projectile_texture
	shooting_system.projectile_collision_shape = config.projectile_collision_shape
	audio_stream_player.stream = sounds.pick_random()
	audio_stream_player.finished.connect(on_sound_finished)

func _process(delta):
	global_position = global_position.move_toward(current_movement_point, delta * speed)
	
	if global_position.distance_squared_to(current_movement_point) < .1:
		current_movement_point = movement_points.pick_random().global_position
	
func on_shot():
	animated_sprite_2d.play(shooting_animation_name)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "die":
		killed.emit()
		if !audio_stream_player.playing:
			queue_free()
	
	if animated_sprite_2d.animation == shooting_animation_name:
		animated_sprite_2d.play(default_animation_name)

func _on_area_entered(area):
	if area is Projectile:
		health_system.damage(1)
		area.queue_free()
	
	if area is Spell:
		
		area.queue_free()
		var spell_type = (area as Spell).type
		var damage = (area as Spell).damage
		health_system.damage(damage)
		var effect_duration = (area as Spell).effect_duration
		
		spell_effector.on_spell_hit(spell_type, effect_duration)
	
	if area is Enemy && spell_effector.is_burning:
		area.health_system.damage(1)
	

func on_damaged():
	if spell_effector.is_poisoned == false:
		audio_stream_player.play()
	progress_bar.value = health_system.health

func on_sound_finished():
	if health_system.health <= 0:
		queue_free()	

func on_died():
	set_collision_layer_value(2, false)
	shooting_system.stop()
	set_process(false)
	animated_sprite_2d.play("die")
	killed.emit()
	audio_stream_player.play()
