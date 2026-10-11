extends CharacterBody3D

const SPEED := 12.0
const SPRINT := 24.0
const JUMP_VELOCITY := 9.0
const MOUSE_SENS := 0.0025
const GRAVITY := 24.0
const ATTACK_RANGE := 4.0
const ATTACK_CD := 0.8

# skills: [name, damage, range, cooldown, aoe_radius]
const SKILLS := [
	{"name": "斩击", "dmg": 22.0, "range": 4.0, "cd": 0.8, "aoe": 0.0},
	{"name": "旋风斩", "dmg": 18.0, "range": 0.0, "cd": 6.0, "aoe": 8.0},
	{"name": "冲锋", "dmg": 35.0, "range": 18.0, "cd": 10.0, "aoe": 0.0},
]

var pitch := -0.55
var health := 100.0
var max_health := 100.0
var kills := 0
var _cds := [0.0, 0.0, 0.0]
var touch_move := Vector2.ZERO

@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	add_to_group("player")
	cam.rotation.x = pitch
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		pitch = clamp(pitch - event.relative.y * MOUSE_SENS, -1.4, 1.4)
		cam.rotation.x = pitch
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_1:
			_use_skill(0)
		elif event.keycode == KEY_2:
			_use_skill(1)
		elif event.keycode == KEY_3:
			_use_skill(2)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event.button_index == MOUSE_BUTTON_LEFT:
			_use_skill(0)

func _physics_process(delta: float) -> void:
	for i in range(_cds.size()):
		_cds[i] = max(0.0, _cds[i] - delta)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input.y -= 1.0
	if Input.is_key_pressed(KEY_S): input.y += 1.0
	if Input.is_key_pressed(KEY_A): input.x -= 1.0
	if Input.is_key_pressed(KEY_D): input.x += 1.0
	input = input.normalized()
	if touch_move.length() > 0.05:
		input = touch_move

	var speed := SPRINT if Input.is_key_pressed(KEY_SHIFT) else SPEED
	var dir: Vector3 = transform.basis * Vector3(input.x, 0.0, input.y)
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	move_and_slide()

func _use_skill(idx: int) -> void:
	if idx < 0 or idx >= SKILLS.size(): return
	if _cds[idx] > 0.0: return
	var s: Dictionary = SKILLS[idx]
	_cds[idx] = s["cd"]
	var hit := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e): continue
		var d: float = e.global_position.distance_to(global_position)
		var in_range := false
		if s["aoe"] > 0.0:
			in_range = d <= s["aoe"]
		else:
			if d <= s["range"]:
				var fwd: Vector3 = -global_transform.basis.z
				var to: Vector3 = (e.global_position - global_position).normalized()
				in_range = fwd.dot(to) > 0.25
		if in_range and e.has_method("take_damage"):
			e.take_damage(s["dmg"])
			hit += 1
	if idx == 2 and hit > 0:
		pass

func take_damage(amount: float) -> void:
	health = max(0.0, health - amount)
	if health <= 0.0:
		health = max_health
		global_position = Vector3(0, 420, 0)
		velocity = Vector3.ZERO

func add_kill() -> void:
	kills += 1
func heal(amount: float) -> void:
	health = min(max_health, health + amount)