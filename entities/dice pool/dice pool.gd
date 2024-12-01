@tool
class_name DicePool extends Node3D


@export var dimensions: Vector3 = Vector3(40, 28, 40):
	set(dimensions_):
		dimensions = dimensions_
		
		if not is_node_ready():
			await self.ready
		
		%Planes.position.y = dimensions.y * 0.5
		$DiceKit.position.y = dimensions.y * 0.33
		
		for plane in %Planes.get_children():
			plane.dimensions = dimensions

var start_slots: = []


func _ready() -> void:
	init_slots()
	%DiceKit.init_dices()
	var options = []
	
	for dice in %DiceKit.get_children():
		if options.is_empty():
			if start_slots.is_empty():
				pass
			
			options = start_slots.pop_front()
		
		var slot = options.pop_back()
		dice.position = Vector3(slot.x, 0, slot.y) * dimensions
		dice._roll()
	
func init_slots() -> void:
	var slot = Vector2.ZERO
	start_slots.append([slot])
	start_slots.append(Global.dict.direction.linear2)
	start_slots.append(Global.dict.direction.diagonal)
