@tool
class_name DiceKit extends Node3D


signal dice_stoppage(dice)

@onready var dice_scene = preload("res://entities/dice/dice.tscn")

@export var dicepool: DicePool
@export var aspects: Array[Constants.ASPECT]

var values: Dictionary
var prediction: Prediction = Prediction.new()

const stand_gap = 1.25


func init_dices() -> void:
	for aspect in aspects:
		var dice = dice_scene.instantiate().duplicate()
		add_child(dice)
		dice.aspect = aspect
		dice.dicekit = self
	
		prediction.change_total_aspect(aspect, 1)
	
	prediction.reset()
	#prediction.add_ban(1)
	#prediction.add_ban(3)
	#prediction.add_ban(7)
	#prediction.calc_failure_probability()
	
	#prediction.calc_repetitions_probability()
	#prediction.sim_rolls()
	
	#prediction.roll_dices()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var flag = true
		
		for dice in get_children():
			if dice.is_rolling:
				flag = false
				break
		
		if flag:
			for dice in get_children():
				dice._roll()
	
func _on_dice_stoppage(_dice: Variant) -> void:
	if check_all_dices_sleeping():
		values = {}
		
		for dice in get_children():
			var value = dice.get_current_value()
			
			if !values.has(value):
				values[value] = []
			
			values[value].append(dice)
		
		var keys = values.keys()
		keys.sort()
		var dimension = _dice.dimension
		var y = -position.y + dimension * 0.5
		
		for _i in keys.size():
			var value = keys[_i]
			var z = (-keys.size() / 2 + _i) * dimension * stand_gap
			var x_shift = 0
			print([value, values[value].size()])
			
			if values[value].size() % 2 == 0:
				x_shift = 0.5
			
			for _j in values[value].size():
				var dice = values[value][_j]
				dice.rotation.y = 0
				var x = (-values[value].size() / 2 + _j + x_shift) * dimension * stand_gap
				
				dice.position = Vector3(x, y, z)
				dice.correct_flip()
	
func check_all_dices_sleeping() -> bool:
	for dice in get_children():
		if !dice.sleeping:
			return false
	
	return true
