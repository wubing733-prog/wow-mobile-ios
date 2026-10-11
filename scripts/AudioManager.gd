extends Node

# 音效管理器：预加载并播放游戏音效（来自 WoW 客户端 sound/ 目录）。

var _streams := {}
var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for k in ["swing", "whoosh", "levelup", "lootcoinsmall", "magicclick"]:
		var p := "res://assets/audio/%s.ogg" % k
		if ResourceLoader.exists(p):
			_streams[k] = load(p)
	for i in range(6):
		var ap := AudioStreamPlayer.new()
		ap.bus = "Master"
		add_child(ap)
		_players.append(ap)

func play(name: String, volume_db: float = 0.0) -> void:
	if not _streams.has(name): return
	for ap in _players:
		if not ap.playing:
			ap.stream = _streams[name]
			ap.volume_db = volume_db
			ap.play()
			return
	# 全部忙则复用第一个
	if _players.size() > 0:
		_players[0].stream = _streams[name]
		_players[0].volume_db = volume_db
		_players[0].play()