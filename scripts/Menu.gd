extends CanvasLayer

# 简易开始菜单 + 暂停。移动端可点，桌面端按 ESC 暂停。

var panel: Control
var started := false

func _ready() -> void:
	layer = 20
	panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.07, 0.10, 0.88)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg)
	var title := Label.new()
	title.text = "影牙城堡  ·  WoW Mobile"
	title.add_theme_font_size_override("font_size", 42)
	title.position = Vector2(360, 200)
	panel.add_child(title)
	var sub := Label.new()
	sub.text = "单机垂直切片  |  数据来自 WoW 12.1.0.69404"
	sub.add_theme_font_size_override("font_size", 18)
	sub.position = Vector2(360, 260)
	panel.add_child(sub)
	var btn := Button.new()
	btn.text = "开始游戏"
	btn.add_theme_font_size_override("font_size", 26)
	btn.position = Vector2(360, 330)
	btn.size = Vector2(240, 60)
	btn.pressed.connect(_start)
	panel.add_child(btn)
	var hint := Label.new()
	hint.text = "WASD 移动 · 左键/1 攻击 · 2 旋风斩 · 3 冲锋 · Shift 疾跑 · ESC 暂停"
	hint.add_theme_font_size_override("font_size", 16)
	hint.position = Vector2(360, 410)
	panel.add_child(hint)
	add_child(panel)
	get_tree().paused = true

func _start() -> void:
	started = true
	panel.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not started: return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		panel.visible = not panel.visible
		get_tree().paused = panel.visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if panel.visible else Input.MOUSE_MODE_CAPTURED