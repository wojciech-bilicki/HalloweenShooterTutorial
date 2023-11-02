extends Node

@onready var player = $"../Player" as Player
@onready var ui = $"../UI"
@onready var wave_spawner = $"../WaveSpawner" as WaveSpawner
@onready var enemy_movement_points = $"../EnemyMovementPoints"


const VLAD_BOSS = preload("res://Scenes/vlad_boss.tscn")

func _ready():
	ui.set_initial_health(player.get_health())
	player.player_damaged.connect(on_player_damaged)
	player.spell_selected.connect(ui.on_spell_selected)
	player.spell_casted.connect(ui.start_spell_timeout)
	wave_spawner.starting_wave.connect(ui.on_wave_started)
	wave_spawner.waves_finished.connect(on_waves_finished)
	player.player_died.connect(ui.on_player_died)
	
func on_waves_finished():
	var vlad_boss = VLAD_BOSS.instantiate()
	get_tree().root.add_child(vlad_boss)
	
	vlad_boss.global_position = Vector2(1116, 310)
	vlad_boss.movement_points = enemy_movement_points.get_children()
	vlad_boss.init()
	vlad_boss.vlad_damaged.connect(ui.change_boss_health_bar_value)
	vlad_boss.vlad_died.connect(ui.on_vlad_died)
	ui.init_boss_health_bar(vlad_boss.get_health())


func on_player_damaged(current_health: int):
	ui.decrease_health(current_health) 
