extends CanvasLayer

# 触屏控制：左半屏虚拟摇杆移动，右侧按钮攻击/技能。桌面端鼠标键盘照常可用。

var move_vec := Vector2.ZERO
var _move_touch := -1
var _move_origin := Vector2.ZERO
var _attack_pressed := false

var _stick_base: Control
var _stick_knob: Control
var _btn_attack: Button
var _btn_skill1: Button
var _btn_skill2: Button

func _ready() -> void:
	layer = 10
	_stick_base = _mk_circle(Vector2(150, 520), 90, Color(1, 1, 1, 0.12))
	_stick_knob = _mk_circle(Vector2(150, 520), 34, Color(1, 1, 1, 0.30))
	_btn_attack = _mk_button(Vector2(1080, 560), 70, "攻击")
	_btn_skill1 = _mk_button(Vector2(940, 600), 55, "旋风")
	_btn_skill2 = _mk_button(Vector2(1080, 440), 55, "冲锋")
	_btn_attack.pressed.connect(func(): _attack_pressed = true)
	_btn_skill1.pressed.connect(func(): _fire(1))
	_btn_skill2.pressed.connect(func(): _fire(2))

func _mk_circle(pos: Vector2, r: float, col: Color) -> Control:
	var c := Control.new()
	c.position = pos - Vector2(r, r)
	c.size = Vector2(r * 2, r * 2)
	var cr := ColorRect.new()
	cr.color = col
	cr.size = Vector2(r * 2, r * 2)
	c.add_child(cr)
	add_child(c)
	return c

func _mk_button(pos: Vector2, r: float, text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos - Vector2(r, r)
	b.size = Vector2(r * 2, r * 2)
	b.add_theme_font_size_override("font_size", 18)
	add_child(b)
	return b

func _fire(idx: int) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("_use_skill"):
		p._use_skill(idx)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		if t.pressed and t.position.x < 640 and _move_touch < 0:
			_move_touch = t.index
			_move_origin = t.position
		elif not t.pressed and t.index == _move_touch:
			_move_touch = -1
			move_vec = Vector2.ZERO
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == _move_touch:
			var v := (d.position - _move_origin) / 80.0
			move_vec = v.limit_length(1.0)
			if _stick_knob:
				_stick_knob.position = _move_origin + move_vec * 60.0 - _stick_knob.size * 0.5

func _process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p == null: return
	p.touch_move = move_vec
	if _attack_pressed:
		_attack_pressed = false
		p._use_skill(0)