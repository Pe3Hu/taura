@tool
class_name PoolPlane extends StaticBody3D


const thickness = 0.01

@export var dicepool: DicePool:
	set(dicepool_):
		dicepool = dicepool_
		dimensions = dicepool.dimensions
@export var dimensions: Vector3 = Vector3(40, 28, 40):
	set(dimensions_):
		dimensions = dimensions_
		orientation = orientation
@export var orientation: Constants.ORIENTATION:
	set(orientation_):
		orientation = orientation_
		
		if not is_node_ready():
			await self.ready
		
		%CollisionShape3D.shape.size = dimensions
		position = Vector3.ZERO
		
		match orientation:
			Constants.ORIENTATION.X0:
				%CollisionShape3D.shape.size.x *= thickness
				position.x = dimensions.x * 0.5
			Constants.ORIENTATION.Y0:
				%CollisionShape3D.shape.size.y *= thickness
				position.y = dimensions.y * 0.5
			Constants.ORIENTATION.Z0:
				%CollisionShape3D.shape.size.z *= thickness
				position.z = dimensions.z * 0.5
			Constants.ORIENTATION.X1:
				%CollisionShape3D.shape.size.x *= thickness
				position.x = -dimensions.x * 0.5
			Constants.ORIENTATION.Y1:
				%CollisionShape3D.shape.size.y *= thickness
				position.y = -dimensions.y * 0.5
			Constants.ORIENTATION.Z1:
				%CollisionShape3D.shape.size.z *= thickness
				position.z = -dimensions.z * 0.5
