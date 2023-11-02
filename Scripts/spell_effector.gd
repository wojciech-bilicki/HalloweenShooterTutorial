extends Node

class_name SpellEffector

@onready var health_system = $"../HealthSystem"
@onready var animated_sprite_2d = $"../AnimatedSprite2D"

@onready var spell_timer = $SpellTimer

var poison_damage_tick = 0.25
var poison_damage_tick_timer = 0

var current_spell_effect

var is_burning = false
var is_poisoned = false 

var color_tween

func _process(delta):
	if current_spell_effect == Enums.SpellType.POISON:
		poison_damage_tick_timer += delta
		if poison_damage_tick_timer >= poison_damage_tick :
			poison_damage_tick_timer = 0
			if health_system.health > 0:
				health_system.damage(.25)

func _ready():
	spell_timer.timeout.connect(on_timer_timeout)

func on_spell_hit(spell_type: Enums.SpellType, effect_duration: float):
	if !spell_timer.is_stopped():
		spell_timer.stop()
		reset_spell_effects()
		
	current_spell_effect = spell_type
	run_color_tween(current_spell_effect, effect_duration)
	
	if spell_type == Enums.SpellType.ICE:
		get_parent().speed = get_parent().speed / 2
		
	if spell_type == Enums.SpellType.POISON:
		is_poisoned = true
	
	if spell_type == Enums.SpellType.FIRE:
		is_burning = true
	
	spell_timer.wait_time = effect_duration
	spell_timer.start()

func on_timer_timeout():
	reset_spell_effects()

func reset_spell_effects():
	if current_spell_effect == Enums.SpellType.ICE:
		get_parent().speed = get_parent().speed * 2
	
	if current_spell_effect == Enums.SpellType.FIRE:
		is_burning = false
	
	if current_spell_effect == Enums.SpellType.POISON:
		is_poisoned = false
	
	poison_damage_tick_timer = 0
	current_spell_effect = null
	
	print(color_tween)
	
	if color_tween != null:
		color_tween.kill()
		color_tween = null


func run_color_tween(current_spell_effect: Enums.SpellType, effect_duration: float):
	
	var color 
	match current_spell_effect:
		Enums.SpellType.FIRE:
			color = Color.ORANGE_RED
		Enums.SpellType.ICE:
			color = Color.AQUA
		Enums.SpellType.POISON:
			color = Color.DARK_GREEN
		
	color_tween = get_tree().create_tween()
	color_tween.tween_property(animated_sprite_2d, "modulate", color, .25)
	color_tween.chain().tween_property(animated_sprite_2d, "modulate", Color.WHITE, .25)
	color_tween.set_loops(effect_duration / .5)
