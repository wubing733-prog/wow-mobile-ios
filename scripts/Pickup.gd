extends Area3D

@export var heal_amount := 35.0
@export var spin_speed := 2.0

func _ready() -> void:
	add_to_group("pickups")
	body_entered.connect(_on_body)

func _process(delta: float) -> void:
	rotate_y(spin_speed * delta)

func _on_body(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("heal"):
		var am := get_tree().get_first_node_in_group("audio")
		if am: am.play("lootcoinsmall", -4.0)
		body.heal(heal_amount)
		queue_free()