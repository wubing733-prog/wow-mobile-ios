extends CharacterBody3D

@export var max_health := 100.0
@export var move_speed := 4.0
@export var aggro_range := 22.0
@export var attack_range := 2.5
@export var attack_damage := 8.0
@export var attack_interval := 1.5
@export var respawn_seconds := 8.0

var health := 0.0
var _target: Node3D = null
var _cd := 0.0
var _dead := false
var _spawn := Vector3.ZERO
var _respawn_t := 0.0

func _ready() -> void:
	health = max_health
	_spawn = global_position
	add_to_group("enemies")
	_target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if _dead:
		_respawn_t -= delta
		if _respawn_t <= 0.0:
			_respawn()
		return
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = 0.0

	_cd = max(0.0, _cd - delta)
	if _target and is_instance_valid(_target):
		var to: Vector3 = _target.global_position - global_position
		var dist := to.length()
		if dist < aggro_range and dist > attack_range:
			var dir: Vector3 = Vector3(to.x, 0, to.z).normalized()
			velocity.x = dir.x * move_speed
			velocity.z = dir.z * move_speed
			look_at(Vector3(_target.global_position.x, global_position.y, _target.global_position.z), Vector3.UP)
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			if dist <= attack_range and _cd <= 0.0:
				_cd = attack_interval
				if _target.has_method("take_damage"):
					_target.take_damage(attack_damage)
	move_and_slide()

func take_damage(amount: float) -> void:
	if _dead: return
	health -= amount
	if health <= 0.0:
		_dead = true
		_respawn_t = respawn_seconds
		visible = false
		set_physics_process(true)
		var am := get_tree().get_first_node_in_group("audio")
		if am: am.play("levelup", -10.0)
		var p := get_tree().get_first_node_in_group("player")
		if p and p.has_method("add_kill"):
			p.add_kill()

func _respawn() -> void:
	_dead = false
	health = max_health
	global_position = _spawn
	visible = true