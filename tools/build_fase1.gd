extends SceneTree

## Gera res://scenes/Fase1.tscn: oceano, jogador, 3 inimigos, boss e minimapa.
## Executar: godot --headless --path <projeto> --script res://tools/build_fase1.gd

const OCEAN_DIR := "res://assets/ambiente/oceano_tileavel/WaterAnimations/ocean%02d.png"
const SHIPS_DIR := "res://assets/navios/PNG/Default size/Ships/"
const FRAMES_PATH := "res://assets/ambiente/oceano_tileavel/oceano_spriteframes.tres"
const SCENE_PATH := "res://scenes/Fase1.tscn"

const TILE := Vector2(342, 180)
const GRID := 3
const MAP := Rect2(0, 0, 4800, 3200)

const SCRIPT_OCEANO := "res://scripts/oceano.gd"
const SCRIPT_JOGADOR := "res://scripts/jogador.gd"
const SCRIPT_INIMIGO := "res://scripts/inimigo.gd"
const SCRIPT_MINIMAPA := "res://scripts/minimapa.gd"

func _init() -> void:
	var frames := _build_frames()
	ResourceSaver.save(frames, FRAMES_PATH)
	print("SpriteFrames salvo: ", FRAMES_PATH)

	var root := Node2D.new()
	root.name = "Fase1"

	_build_ocean(root, frames)
	_build_boats(root)
	_build_hud(root)

	var scene := PackedScene.new()
	var err := scene.pack(root)
	if err != OK:
		push_error("Falha ao empacotar cena: %s" % err)
		quit(1)
		return
	err = ResourceSaver.save(scene, SCENE_PATH)
	if err != OK:
		push_error("Falha ao salvar cena: %s" % err)
		quit(1)
		return
	print("Cena salva: ", SCENE_PATH)
	quit(0)

func _build_ocean(root: Node2D, frames: SpriteFrames) -> void:
	var ocean := Node2D.new()
	ocean.name = "Oceano"
	ocean.set_script(load(SCRIPT_OCEANO))
	root.add_child(ocean)
	ocean.owner = root
	for cx in range(-GRID, GRID + 1):
		for cy in range(-GRID, GRID + 1):
			var tile := AnimatedSprite2D.new()
			tile.name = "Agua_%d_%d" % [cx + GRID, cy + GRID]
			tile.sprite_frames = frames
			tile.animation = "default"
			tile.autoplay = "default"
			tile.scale = Vector2(1.06, 1.06)
			tile.position = Vector2(cx * TILE.x, cy * TILE.y)
			ocean.add_child(tile)
			tile.owner = root

func _build_boats(root: Node2D) -> void:
	var player := _make_boat(root, "BarcoJogador", "ship (1).png",
		Vector2(2400, 2500), 0.0, 1.0, Color.WHITE, SCRIPT_JOGADOR)
	var cam := Camera2D.new()
	cam.name = "Camera2D"
	cam.position = Vector2.ZERO
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	cam.limit_left = int(MAP.position.x)
	cam.limit_top = int(MAP.position.y)
	cam.limit_right = int(MAP.end.x)
	cam.limit_bottom = int(MAP.end.y)
	player.add_child(cam)
	cam.owner = root

	_make_boat(root, "Inimigo1", "ship (2).png", Vector2(2400, 1000), PI, 1.0, Color(0.8, 1, 1), SCRIPT_INIMIGO)
	_make_boat(root, "Inimigo2", "ship (10).png", Vector2(1900, 1200), PI, 1.0, Color(0.8, 1, 1), SCRIPT_INIMIGO)
	_make_boat(root, "Inimigo3", "ship (5).png", Vector2(2900, 1200), PI, 1.0, Color(0.8, 1, 1), SCRIPT_INIMIGO)

	var boss := _make_boat(root, "Boss", "ship (3).png", Vector2(2400, 450), PI, 2.0, Color(1, 0.85, 0.85), SCRIPT_INIMIGO)
	boss.set("is_boss", true)
	boss.set("detect_radius", 1400.0)
	boss.set("give_up_radius", 2400.0)
	boss.set("max_hp", 10)
	boss.set("hit_radius", 80.0)

	var mira := Node2D.new()
	mira.name = "Mira"
	mira.set_script(load("res://scripts/mira.gd"))
	root.add_child(mira)
	mira.owner = root

func _build_hud(root: Node2D) -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	root.add_child(layer)
	layer.owner = root
	var minimap := Control.new()
	minimap.name = "Minimapa"
	minimap.set_script(load(SCRIPT_MINIMAPA))
	minimap.anchor_left = 1.0
	minimap.anchor_right = 1.0
	minimap.anchor_top = 0.0
	minimap.anchor_bottom = 0.0
	minimap.offset_left = -240.0
	minimap.offset_right = -20.0
	minimap.offset_top = 20.0
	minimap.offset_bottom = 180.0
	layer.add_child(minimap)
	minimap.owner = root

	var audio_ctrl := (load("res://scenes/ControleAudio.tscn") as PackedScene).instantiate()
	audio_ctrl.name = "ControleAudio"
	layer.add_child(audio_ctrl)
	audio_ctrl.owner = root
	audio_ctrl.offset_left = 24.0
	audio_ctrl.offset_top = 656.0
	audio_ctrl.offset_right = 324.0
	audio_ctrl.offset_bottom = 700.0

	# barra de vida do jogador (sempre visível, canto superior esquerdo)
	_add_barra(layer, root, "BarraJogador", "jogador",
		Color(0.35, 0.8, 0.35), "VIDA", false, 0.0, 24.0, 34.0, 264.0, 58.0)

	# barra de energia do jogador (logo abaixo da vida)
	_add_barra(layer, root, "BarraEnergia", "jogador",
		Color(0.95, 0.8, 0.2), "ENERGIA", false, 0.0, 24.0, 84.0, 264.0, 108.0,
		"res://scripts/barra_energia.gd")

	# barra de vida do chefe (topo, só durante o combate)
	_add_barra(layer, root, "BarraChefe", "boss",
		Color(0.85, 0.15, 0.15), "CHEFE", true, 0.5, -220.0, 34.0, 220.0, 60.0)

func _add_barra(layer: CanvasLayer, root: Node2D, node_name: String, grupo: String,
		cor: Color, rotulo: String, apenas_combate: bool,
		ancora_x: float, esq: float, topo: float, dir: float, base: float,
		script_path := "res://scripts/barra_vida.gd") -> void:
	var barra := Control.new()
	barra.name = node_name
	barra.set_script(load(script_path))
	barra.anchor_left = ancora_x
	barra.anchor_right = ancora_x
	barra.anchor_top = 0.0
	barra.anchor_bottom = 0.0
	barra.offset_left = esq
	barra.offset_top = topo
	barra.offset_right = dir
	barra.offset_bottom = base
	barra.set("grupo", grupo)
	barra.set("cor", cor)
	barra.set("rotulo", rotulo)
	barra.set("apenas_em_combate", apenas_combate)
	barra.visible = not apenas_combate
	layer.add_child(barra)
	barra.owner = root

func _make_boat(root: Node2D, node_name: String, file: String, pos: Vector2,
		rot: float, scl: float, tint: Color, script_path: String) -> Node2D:
	var boat := Node2D.new()
	boat.name = node_name
	boat.position = pos
	boat.rotation = rot
	boat.set_script(load(script_path))
	root.add_child(boat)
	boat.owner = root
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = load(SHIPS_DIR + file) as Texture2D
	sprite.scale = Vector2(scl, scl)
	sprite.modulate = tint
	boat.add_child(sprite)
	sprite.owner = root
	return boat

func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 10.0)
	frames.set_animation_loop("default", true)
	for i in range(1, 22):
		var path := OCEAN_DIR % i
		var tex := load(path) as Texture2D
		if tex == null:
			push_error("Textura nao encontrada: " + path)
			continue
		frames.add_frame("default", tex)
	return frames
