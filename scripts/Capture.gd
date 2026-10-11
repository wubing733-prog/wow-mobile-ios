extends Node

# 仅在带 --screenshot 参数时截图并退出，避免影响正常游玩。
func _ready() -> void:
	if not ("--screenshot" in OS.get_cmdline_user_args()):
		return
	await get_tree().process_frame
	var menu := get_node_or_null("/root/Main/Menu")
	if menu and menu.has_method("_start"):
		menu._start()
	await get_tree().create_timer(2.5).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png("res://docs/screenshot.png")
	print("saved screenshot ", img.get_width(), "x", img.get_height())
	get_tree().quit()