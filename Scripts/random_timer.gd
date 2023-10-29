extends Timer

class_name RandomTimer

@export var min_time: float = 1
@export var max_time: float = 2

func _ready():
	setup()
	
func setup():
	var random_time = randf_range(min_time, max_time)
	wait_time = random_time
	start()
