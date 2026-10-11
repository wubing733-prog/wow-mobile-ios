extends Node

# 自动化玩法验证：直接驱动战斗逻辑，检查伤害/击杀/技能冷却/拾取是否生效。

var _passed := 0
var _failed := 0

func _check(name: String, ok: bool, detail: String = "") -> void:
	if ok:
		_passed += 1
		print("PASS  ", name, "  ", detail)
	else:
		_failed += 1
		print("FAIL  ", name, "  ", detail)

func _ready() -> void:
	# 仅在带 --gametest 参数时运行，避免影响正常游玩
	if not ("--gametest" in OS.get_cmdline_user_args()):
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var main := get_node_or_null("/root/Main")
	var menu := main.get_node_or_null("Menu")
	if menu and menu.has_method("_start"):
		menu._start()

	var p := get_tree().get_first_node_in_group("player")
	_check("player exists", p != null)
	if p == null:
		_finish(); return

	# 1) 技能表
	_check("skills defined", p.SKILLS.size() == 3, "count=%d" % p.SKILLS.size())

	# 2) 敌人存在
	var enemies := get_tree().get_nodes_in_group("enemies")
	_check("enemies spawned", enemies.size() >= 3, "count=%d" % enemies.size())

	# 3) 直接造成伤害 -> 击杀计数
	var e: Node3D = enemies[0]
	var hp0: float = e.health
	e.take_damage(999.0)
	await get_tree().process_frame
	_check("enemy dies on lethal damage", e._dead == true, "hp %0.0f -> %0.0f" % [hp0, e.health])
	_check("kill counter incremented", p.kills >= 1, "kills=%d" % p.kills)

	# 4) 治疗
	p.health = 50.0
	p.heal(30.0)
	_check("heal works", abs(p.health - 80.0) < 0.01, "hp=%0.0f" % p.health)

	# 5) 技能冷却
	p._cds[1] = 0.0
	p._use_skill(1)
	_check("skill cooldown set", p._cds[1] > 0.0, "cd=%0.2f" % p._cds[1])

	# 6) 拾取回血
	var pickups := get_tree().get_nodes_in_group("pickups")
	_check("pickups spawned", pickups.size() >= 1, "count=%d" % pickups.size())

	# 7) 敌人重生计时
	await get_tree().create_timer(0.2).timeout
	_check("respawn timer armed", e._respawn_t > 0.0, "t=%0.1f" % e._respawn_t)

	_finish()

func _finish() -> void:
	print("RESULT passed=%d failed=%d" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)