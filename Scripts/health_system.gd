extends Node

class_name HealthSystem

signal died
signal damaged

@export var health = 20

func damage(damage_taken: int):
	health -= damage_taken
	
	damaged.emit()
	
	if health <= 0:
		died.emit()
	
