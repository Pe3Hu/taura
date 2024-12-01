class_name World extends Node




func _ready() -> void:
	#datas.filter(func (a): return true)
	#datas.sort_custom(func(a, b): return a > b)
	#210 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	#await get_tree().physics_frame
	pass


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
	
