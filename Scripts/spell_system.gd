extends Node2D

class_name SpellSystem

signal spell_selected(spell_index: int)
signal spell_casted(spell_index: int, timeout: float)

const SPELL_SCENE = preload("res://Scenes/spell.tscn")


const SPELL_CONFIGS = [
	preload("res://Resources/Spells/ice.tres"),
	preload("res://Resources/Spells/fire.tres"),
	preload("res://Resources/Spells/poison.tres")
]

var timers = {
	"ice": {
		"time": 0,
		"can_cast": true
	},
	"fire": {
		"time": 0,
		"can_cast": true
	},
	"poison": {
		"time": 0,
		"can_cast": true
	},
}

var current_spell_type = Enums.SpellType.ICE

# Called when the node enters the scene tree for the first time.
func _ready():
	var player  = get_parent() as Player
	player.spell_selected.connect(on_spell_selected)
	
func _input(event):
	if Input.is_action_just_pressed("select_spell_1"):
		spell_selected.emit(1)
	elif Input.is_action_just_pressed("select_spell_2"):
		spell_selected.emit(2)
	elif Input.is_action_just_pressed("select_spell_3"):
		spell_selected.emit(3)

	if Input.is_action_just_pressed("cast_spell"):
		on_spell_casted()


func _process(delta):
	var i = 0
	for timer_key in timers:
		if timers[timer_key]["can_cast"] == false:
			timers[timer_key]["time"] += delta
			if timers[timer_key]["time"] >= SPELL_CONFIGS[i].refresh_time:
				timers[timer_key]["can_cast"] = true
				timers[timer_key]["time"] = 0	
		i += 1

func on_spell_selected(spell_index: int):
	current_spell_type = Enums.SpellType.values()[spell_index - 1]
	
	
func on_spell_casted():
	
	var current_spell_key = get_current_spell_key()
	if timers[current_spell_key]["can_cast"] == false:
		return
	
	var spell = SPELL_SCENE.instantiate()
	spell.global_position = global_position
	spell.config = SPELL_CONFIGS[current_spell_type]
	get_tree().root.add_child(spell)
	start_timer(current_spell_type)
	spell_casted.emit(current_spell_type, SPELL_CONFIGS[current_spell_type].refresh_time)
	
func start_timer(current_spell_type: Enums.SpellType):
	match current_spell_type:
		Enums.SpellType.FIRE:
			timers["fire"]["can_cast"] = false
		Enums.SpellType.ICE:
			timers["ice"]["can_cast"] = false
		Enums.SpellType.POISON:
			timers["poison"]["can_cast"] = false

func get_current_spell_key():
	return 	Enums.SpellType.keys()[current_spell_type].to_snake_case()
