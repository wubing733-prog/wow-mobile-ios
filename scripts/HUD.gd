extends CanvasLayer

var player: Node = null
var label: Label = null
var enemy_label: Label = null
var skill_label: Label = null
var quest_label: Label = null

func _ready() -> void:
	label = _mk(24, 20, 20)
	enemy_label = _mk(24, 52, 16)
	skill_label = _mk(24, 82, 16)
	quest_label = _mk(24, 112, 16)
	var crosshair := Control.new()
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	var dot := ColorRect.new()
	dot.color = Color(1, 1, 1, 0.85)
	dot.size = Vector2(4, 4)
	dot.position = Vector2(-2, -2)
	crosshair.add_child(dot)
	add_child(crosshair)

func _mk(x: float, y: float, size: int) -> Label:
	var l := Label.new()
	l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", size)
	add_child(l)
	return l

func _process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player == null or not is_instance_valid(player):
		label.text = "HP --"
		enemy_label.text = ""
		skill_label.text = ""
		return
	label.text = "HP %d / %d    击杀 %d" % [int(player.health), int(player.max_health), player.kills]
	var nearest: Node3D = null
	var best := 1e9
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e) or e._dead: continue
		var d: float = e.global_position.distance_to(player.global_position)
		if d < best:
			best = d
			nearest = e
	if nearest != null:
		enemy_label.text = "最近敌人 %.1f m   HP %d" % [best, int(nearest.health)]
	else:
		enemy_label.text = "无敌人"
	var parts: Array[String] = []
	for i in range(player.SKILLS.size()):
		var s: Dictionary = player.SKILLS[i]
		var cd: float = player._cds[i]
		parts.append("[%d] %s %s" % [i + 1, s["name"], ("就绪" if cd <= 0.0 else "%.1fs" % cd)])
	skill_label.text = "   ".join(parts)
	var alive := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and not e._dead: alive += 1
	if alive == 0:
		quest_label.text = "目标完成！影牙城堡已肃清  (击杀 %d)" % player.kills
	else:
		quest_label.text = "目标: 清剿影牙城堡守卫  (剩余 %d)   击杀 %d" % [alive, player.kills]