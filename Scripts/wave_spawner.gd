extends Area2D

class_name WaveSpawner

enum  EnemyType {
	DEVIL,
	MUMMY, 
	SKELETON
}


signal waves_finished
signal starting_wave(wave_index: int, total_waves)

const ENEMY = preload("res://Scenes/enemy.tscn")

@export var enemy_movement_points: Array[Node2D]

@onready var wave_spawn_timer = $WaveSpawnTimer
@onready var collision_shape_2d = $CollisionShape2D

@export var time_between_waves = 3

var enemy_types = [EnemyType.DEVIL, EnemyType.MUMMY, EnemyType.SKELETON]

var waves = []
var current_wave
var enemy_count
var initial_waves_count

func _ready():
	var children = get_children()
	
	for child in children:
		if is_instance_of(child, Wave):
			waves.append(child)
	
	initial_waves_count = waves.size()
	wave_spawn_timer.timeout.connect(on_spawn_timeout)
	initiate_next_wave()	

func on_spawn_timeout():
	var enemy_to_spawn = enemy_types.pick_random()
	var shape_rect = collision_shape_2d.shape.get_rect()
	var spawn_point = Vector2(randi_range(shape_rect.position.x, shape_rect.end.x), randi_range(shape_rect.position.y, shape_rect.end.y))
	
	match enemy_to_spawn:
		EnemyType.DEVIL:
			if current_wave.devils_count >= 1:
				current_wave.devils_count -= 1
				spawn(spawn_point, enemy_to_spawn, current_wave.devil_config)
			if current_wave.devils_count == 0:
				enemy_types.erase(EnemyType.DEVIL)
				
		EnemyType.MUMMY:
			if current_wave.mummy_count >= 1:
				current_wave.mummy_count -= 1
				spawn(spawn_point, enemy_to_spawn, current_wave.mummy_config)
			if current_wave.mummy_count == 0:
				enemy_types.erase(EnemyType.MUMMY)
		EnemyType.SKELETON:
			if current_wave.skeleton_count >= 1:
				current_wave.skeleton_count -= 1
				spawn(spawn_point, enemy_to_spawn, current_wave.skeleton_config)
			if current_wave.skeleton_count == 0:
				enemy_types.erase(EnemyType.SKELETON)
				
	if current_wave.skeleton_count == 0 && current_wave.mummy_count == 0 && current_wave.devils_count == 0:
		wave_spawn_timer.stop()
				
func spawn(spawn_point: Vector2, enemy_type: EnemyType, enemy_config):
	var enemy = ENEMY.instantiate()
	add_child(enemy)
	enemy.killed.connect(on_enemy_killed)
	enemy.init(enemy_config, enemy_movement_points)
	enemy.position = spawn_point
	
func on_enemy_killed():
	enemy_count -= 1
	if enemy_count == 0:
		progress_to_next_wave()

func progress_to_next_wave():
	if waves.size() == 0:
		waves_finished.emit()
		wave_spawn_timer.stop()
	else:
		initiate_next_wave()
	
func initiate_next_wave():
	enemy_types = [EnemyType.DEVIL, EnemyType.MUMMY, EnemyType.SKELETON]
	current_wave = waves.pop_front() as Wave
	starting_wave.emit(initial_waves_count - waves.size(), initial_waves_count)
	enemy_count = current_wave.devils_count + current_wave.skeleton_count + current_wave.mummy_count
	wave_spawn_timer.wait_time = current_wave.time_between_enemy_spawns
	
	wave_spawn_timer.start()
 
