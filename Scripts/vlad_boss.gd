extends Area2D

signal vlad_damaged(current_health: int)
signal vlad_died

var sounds = [
	preload("res://Assets/sounds/hit1.mp3"),
	preload("res://Assets/sounds/hit2.mp3"),
	preload("res://Assets/sounds/hit3.mp3"),
	preload("res://Assets/sounds/hit4.mp3"),
	preload("res://Assets/sounds/hit5.mp3"),
]

enum Phase {
	ONE,
	TWO
}

enum Action {
	SPAWN_DEVIL,
	HOMING_SHOT,
	SPRAY_SHOT
}

var phase = Phase.ONE

@onready var health_system = $HealthSystem
@onready var shooting_point = $ShootingPoint
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var action_timer = $ActionTimer
@onready var audio_stream_player = $AudioStreamPlayer
@onready var spell_effector = $SpellEffector

const HOMING_BAT = preload("res://Scenes/homing_bat.tscn")
const ENEMY_PROJECTILE = preload("res://Scenes/enemy_projectile.tscn")
const RING = preload("res://Assets/Enemies/EnemyProjectiles/ring.png")
const ENEMY = preload("res://Scenes/enemy.tscn")
const DEVIL_ENEMY_CONFIG = preload("res://Resources/devil_enemy_config.tres")

const CHANCE_TO_BLOCK = 0.3
const CHANCE_TO_TELEPORT = 0.4

var is_blocking = false

var speed = 300
var movement_points 
var current_movement_point
var spray_shot_count = 3

var bat_speed = 350
var bat_homing_time = 2

var min_projectile_degree = -15

func init():
	var random_point = movement_points.pick_random()
	current_movement_point = random_point.position
	health_system.damaged.connect(on_damaged)
	health_system.died.connect(on_died)
	action_timer.setup()
	audio_stream_player.finished.connect(on_sound_finished)
	
func on_sound_finished():
	if get_health() == 0:
		queue_free()

func on_died():
	audio_stream_player.stream = sounds.pick_random()
	audio_stream_player.play()
	vlad_died.emit()
	
func on_damaged():
	
	vlad_damaged.emit(get_health())
	
	if health_system.health == 10:
		trigger_second_phase()
	
	if spell_effector.is_poisoned == false:
		audio_stream_player.stream = sounds.pick_random()
		audio_stream_player.play()

func trigger_second_phase():
	phase = Phase.TWO
	action_timer.min_time = 1
	action_timer.max_time = 2
	spray_shot_count = 5
	min_projectile_degree = -30
	bat_speed = 425
	bat_homing_time = 1.5
	

func get_health():
	return health_system.health

func _process(delta):
	global_position = global_position.move_toward(current_movement_point, delta * speed)
	
	if global_position.distance_squared_to(current_movement_point) < .1:
		current_movement_point = movement_points.pick_random().global_position
		
		if phase == Phase.TWO:
			var random = randf_range(0, 1)
			if random < CHANCE_TO_BLOCK && !is_blocking:
				start_blocking()
			elif  random >= CHANCE_TO_BLOCK && is_blocking:
				stop_blocking()
			
			random = randf_range(0, 1)
			if random < CHANCE_TO_TELEPORT && !is_blocking:
				is_blocking = true
				teleport()
				
func start_blocking():
	animated_sprite_2d.play("blocking")
	is_blocking = true

func stop_blocking():
	animated_sprite_2d.play("default")
	is_blocking = false

func teleport():
	current_movement_point == null
	animated_sprite_2d.play("teleport")	

func _on_area_entered(area):
	
	if is_blocking:
		return
		
	if area is Projectile:
		var blink_tween = get_tree().create_tween()
		blink_tween.tween_property(animated_sprite_2d, "modulate", Color.RED, .25)
		blink_tween.chain().tween_property(animated_sprite_2d, "modulate", Color.WHITE, .25)
		health_system.damage(1)
	
	if area is Spell:
		
		area.queue_free()
		var spell_type = (area as Spell).type
		var damage = (area as Spell).damage
		health_system.damage(damage)
		var effect_duration = (area as Spell).effect_duration
		
		spell_effector.on_spell_hit(spell_type, effect_duration)


func _on_action_timer_timeout():
	var random_action = pick_action()
	
	match random_action:
		Action.SPAWN_DEVIL:
			var devil = ENEMY.instantiate()
			get_tree().root.add_child(devil)
			devil.init(DEVIL_ENEMY_CONFIG, movement_points)
			devil.global_position = movement_points.pick_random().global_position
		Action.HOMING_SHOT:
			animated_sprite_2d.play("shooting")
			var homing_bat = HOMING_BAT.instantiate()
			homing_bat.speed = bat_speed
			homing_bat.max_homing_time = bat_homing_time
			homing_bat.global_position = shooting_point.global_position
			get_tree().root.add_child(homing_bat)
		Action.SPRAY_SHOT:
			animated_sprite_2d.play("shooting")
			for i in spray_shot_count:
				var projectile = ENEMY_PROJECTILE.instantiate()
				projectile.global_position = shooting_point.global_position
				get_tree().root.add_child(projectile)
				projectile.rotation_degrees = min_projectile_degree + 15 * i
				projectile.set_vlad_pattern()
				projectile.set_projectile_texture(RING)
				
func pick_action():
	var random_number = randi_range(0, 100)
	if random_number < 15:
		return Action.SPAWN_DEVIL
	if random_number < 50:
		return Action.HOMING_SHOT
	return Action.SPRAY_SHOT


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "shooting":
		if is_blocking:
			animated_sprite_2d.play("blocking")
		else:
			animated_sprite_2d.play("default")
	
	if animated_sprite_2d.animation == "teleport":
		is_blocking = false
		animated_sprite_2d.play("default")
		var random_teleport_point = movement_points.pick_random().global_position
		global_position = random_teleport_point
		current_movement_point = movement_points.pick_random().global_position
