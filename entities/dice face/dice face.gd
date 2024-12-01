@tool
class_name DiceFace extends MeshInstance3D


@export var dice: Dice:
	set(dice_):
		dice = dice_
		dimension = dice.dimension
@export var dimension: float = 0.5:
	set(dimension_):
		dimension = dimension_
		orientation = orientation
@export var value: int = 0:
	set(value_):
		value = value_
		mesh.material.albedo_texture = load("res://entities/dice face/faces/" +  str(value) + ".png")
@export var orientation: Constants.ORIENTATION = Constants.ORIENTATION.X0:
	set(orientation_):
		orientation = orientation_
		mesh.size = Vector2(dimension, dimension)
		mesh.center_offset = Vector3.ZERO
		rotation = Vector3.ZERO
		
		match orientation:
			Constants.ORIENTATION.X0:
				mesh.center_offset.x = dimension * 0.5
				mesh.orientation = 0
			Constants.ORIENTATION.Y0:
				mesh.center_offset.y = dimension * 0.5
				mesh.orientation = 1
			Constants.ORIENTATION.Z0:
				mesh.center_offset.z = dimension * 0.5
				mesh.orientation = 2
			Constants.ORIENTATION.X1:
				mesh.center_offset.x = dimension * 0.5
				mesh.orientation = 0
				rotation.y = PI
			Constants.ORIENTATION.Y1:
				mesh.center_offset.y = dimension * 0.5
				mesh.orientation = 1
				rotation.x = PI
			Constants.ORIENTATION.Z1:
				mesh.center_offset.z = dimension * 0.5
				mesh.orientation = 2
				rotation.y = PI
		
		%RayCast3D.target_position = mesh.center_offset * 1.05


func _ready() -> void:
	mesh = PlaneMesh.new()
	mesh.material = StandardMaterial3D.new()
	mesh.material.transparency = 1
	dimension = dimension
	orientation = orientation
	value = value
	%RayCast3D.add_exception(owner)
