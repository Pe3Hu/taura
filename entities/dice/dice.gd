@tool
class_name Dice extends RigidBody3D


signal roll_finished(value)


@export var dicekit: DiceKit:
	set(dicekit_):
		dicekit = dicekit_
		
		if not is_node_ready():
			await self.ready
		
		for face in %Faces.get_children():
			face.mesh = face.mesh.duplicate()
@export var dimension: float = 2:
	set(dimension_):
		dimension = dimension_
		
		if not is_node_ready():
			await self.ready
		
		%Cube.mesh.size = Vector3.ONE * dimension * 0.99
		%CollisionShape3D.shape.size = %Cube.mesh.size
		
		for face in %Faces.get_children():
			face.dimension = dimension
@export var aspect: Constants.ASPECT:
	set(aspect_):
		aspect = aspect_
		
		if not is_node_ready():
			await self.ready
		
		match aspect:
			Constants.ASPECT.FIRE:
				%Cube.mesh.material.albedo_color = Color.from_hsv(0.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.STORM:
				%Cube.mesh.material.albedo_color = Color.from_hsv(180.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.ICE:
				%Cube.mesh.material.albedo_color = Color.from_hsv(220.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.ABYSS:
				%Cube.mesh.material.albedo_color = Color.from_hsv(30.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.DEATH:
				%Cube.mesh.material.albedo_color = Color.from_hsv(300.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.NATURE:
				%Cube.mesh.material.albedo_color = Color.from_hsv(120.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.LIGHT:
				%Cube.mesh.material.albedo_color = Color.from_hsv(60.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.CHAOS:
				%Cube.mesh.material.albedo_color = Color.from_hsv(270.0 / 360.0, 0.9, 0.9)
			Constants.ASPECT.DARK:
				%Cube.mesh.material.albedo_color = Color.from_hsv(0.0 / 360.0, 0.0, 0.4)
		
		if is_node_ready():
			update_face_values()


var start_position: Vector3
var roll_strength = 30
var is_rolling = false
var bottom_face: DiceFace


func _ready() -> void:
	position = start_position
	%Cube.mesh = BoxMesh.new()
	%Cube.mesh.material = StandardMaterial3D.new()
	dimension = dimension
	aspect = aspect
	
func update_face_values() -> void:
	var indexs = [0, 1, 2, 5, 4, 3]
	
	for _i in %Faces.get_child_count():
		var face = %Faces.get_child(_i)
		var value = Global.dict.dice.title[aspect].values[indexs[_i]]
		face.value = value
	
func _roll() -> void:
	#print(Global.dict.dice.title[aspect])
	#
	#for _i in %Faces.get_child_count():
		#var face = %Faces.get_child(_i)
		#print(face.value)
	
	#reset state
	sleeping = false
	freeze = false
	transform.origin = start_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	#random rotation
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis
	
	#random throw impulse
	var throw_vector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throw_vector * roll_strength / 2
	apply_central_impulse(throw_vector * roll_strength)
	is_rolling = true
	
func get_opposite_face_value() -> int:
	var opposite_index = (%Faces.get_child_count() / 2 + bottom_face.get_index()) % %Faces.get_child_count()
	var opposite_face = %Faces.get_child(opposite_index)
	return opposite_face.value
	
func get_current_value() -> Variant:
	for face in %Faces.get_children():
		if face.get_node("%RayCast3D").is_colliding():
			return get_opposite_face_value()
	
	return null
	
func correct_flip() -> void:
	var opposite_index = (%Faces.get_child_count() / 2 + bottom_face.get_index()) % %Faces.get_child_count()
	
	match opposite_index:
		0:
			rotation.y = -PI / 2
		1:
			pass
		2:
			pass
		3:
			rotation.y = PI / 2
		4:
			rotation.y = PI
		5:
			rotation.y = PI
	
func _on_sleeping_state_changed() -> void:
	if sleeping:
		var landed_on_side = false
		
		for face in %Faces.get_children():
			if face.get_node("%RayCast3D").is_colliding():
				bottom_face = face
				is_rolling = false
				landed_on_side = true
				roll_finished.emit(get_opposite_face_value())
		
		if !landed_on_side:
			_roll()
	
func _on_roll_finished(_value: Variant) -> void:
	dicekit.dice_stoppage.emit(self)
	#print([face.value, get_index()])
