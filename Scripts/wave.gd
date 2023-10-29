extends Node

class_name Wave

@export_group("Enemy configs")
@export var devil_config: Resource
@export var mummy_config: Resource
@export var skeleton_config: Resource
@export_group("")

@export_group("Enemy counts")
@export var devils_count = 2
@export var mummy_count = 3
@export var skeleton_count = 3
@export_group("")

@export var time_between_enemy_spawns: float = 2.5
