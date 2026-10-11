extends MeshInstance3D

func _ready() -> void:
	# Build a static trimesh collider for the imported terrain mesh.
	create_trimesh_collision()