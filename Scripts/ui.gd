extends CanvasLayer

class_name UI

@onready var health_container = %HealthContainer
@onready var wave_counter = $MarginContainer/WaveCounter
@onready var boss_health_bar = $MarginContainer/BossHealthBar
@onready var boss_name = $MarginContainer/BossName
@onready var label = %Label
@onready var game_over_container = $MarginContainer/GameOverContainer


const LIFE_FULL_UI = preload("res://Assets/UIElements/LifeFullUI.png")
const LIFE_HALF_UI = preload("res://Assets/UIElements/LifeHalfUI.png")

func set_initial_health(health: int):
	var full_health_textures = health / 2
	
	for i in full_health_textures:
		var texture_rect = TextureRect.new()
		texture_rect.texture = LIFE_FULL_UI
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		health_container.add_child(texture_rect)
		
	var half_life_texture = health % 2
	
	if half_life_texture != 0:
		var half_life_texture_rect = TextureRect.new()
		half_life_texture_rect.texture = LIFE_HALF_UI
		half_life_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		health_container.add_child(half_life_texture_rect)

func decrease_health(current_health):
	var health_textures = health_container.get_children()
	if current_health % 2 == 0:
		health_textures.pop_back().queue_free()
	else:
		health_textures.back().texture = LIFE_HALF_UI

func on_wave_started(current_wave, total_waves):
	wave_counter.text = "Wave %d of %d" % [current_wave, total_waves]

func change_boss_health_bar_value(new_value: int):
	boss_health_bar.value = new_value
	
func on_vlad_died():
	game_over_container.show()
	
func init_boss_health_bar(max_health: int):
	boss_name.visible = true
	boss_health_bar.visible = true
	boss_health_bar.max_value = max_health
	boss_health_bar.value = max_health
	wave_counter.text = "Boss fight"
	
func on_player_died():
	label.text = "You lost!!!"
	game_over_container.show()
	
func _on_button_pressed():
	get_tree().reload_current_scene()
