extends Node

# 简单存档：击杀数 / 玩家位置 / 血量。单机进度持久化。

const SAVE_PATH := "user://save.json"

func _ready() -> void:
	add_to_group("save")
	load_game()

func save_game() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p == null: return
	var d := {
		"kills": p.kills,
		"health": p.health,
		"pos": [p.global_position.x, p.global_position.y, p.global_position.z],
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))
		f.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null: return
	var txt := f.get_as_text()
	f.close()
	var d = JSON.parse_string(txt)
	if typeof(d) != TYPE_DICTIONARY: return
	var p := get_tree().get_first_node_in_group("player")
	if p == null: return
	p.kills = int(d.get("kills", 0))
	p.health = float(d.get("health", p.max_health))
	var pos = d.get("pos", null)
	if pos is Array and pos.size() == 3:
		p.global_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()