extends SceneTree

var _ticks := 0
var _ativo := false

func _init() -> void:
	change_scene_to_file("res://scenes/Fase1.tscn")
	physics_frame.connect(_on_physics)

func _on_physics() -> void:
	if not _ativo:
		if Mapa.jogador != null:
			_ativo = true
		return
	_ticks += 1
	Mapa.jogador.global_position = Vector2(2400, 1650)
	Mapa.jogador.rotation = 0.0
	Mapa.jogador.speed = 0.0

	if _ticks == 360:
		var boss := get_first_node_in_group("boss")
		boss.take_damage(5)
		print("boss hp=", boss.hp, " canhoes=", boss._cannons, " enraged=", boss._enraged,
			" tempo=", get_root().get_node("Audio")._tempo)
	if _ticks == 700:
		print("t700 hp=", Mapa.jogador.hp, " burn=", Mapa.jogador._burn_time)
		var img := get_root().get_texture().get_image()
		if img != null and img.get_width() > 0:
			img.save_png("res://fogo_preview.png")
	if _ticks >= 740:
		quit()
