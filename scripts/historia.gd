extends Control

## Cutscene inicial: 4 quadros com fade entre eles, antes do menu principal.
## Cada quadro fica 5 s (o último 8 s) e depois vai para a tela inicial.

const QUADROS := [
	"res://parte_1_riquezas.png",
	"res://parte_2_dormiu.png",
	"res://parte_3_inimigos.png",
	"res://parte_4_vinganca.png",
]
const CENA_MENU := "res://scenes/TelaInicial.tscn"
const MUSICA := "res://historia.mp3"
const MUSICA_MENU := "res://FarFromHereTheme.mp3"

const FADE := 0.8
const DURACAO := 5.0
const DURACAO_FINAL := 8.0

@onready var _imagem: TextureRect = $Imagem

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.reset_combat()
		audio.play_music(MUSICA, true, 1.0)
	_imagem.modulate.a = 0.0
	_rodar()

func _rodar() -> void:
	for i in range(QUADROS.size()):
		var ultimo: bool = i == QUADROS.size() - 1
		var total: float = DURACAO_FINAL if ultimo else DURACAO
		_imagem.texture = load(QUADROS[i])
		var t := create_tween()
		t.tween_property(_imagem, "modulate:a", 1.0, FADE)
		t.tween_interval(maxf(total - FADE * 2.0, 0.0))
		t.tween_property(_imagem, "modulate:a", 0.0, FADE)
		await t.finished
	_ir_para_menu()

func _ir_para_menu() -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.play_music(MUSICA_MENU, true, 1.0)
	var transicao := get_node_or_null("/root/Transicao")
	if transicao == null:
		get_tree().change_scene_to_file(CENA_MENU)
		return
	transicao.transition_to(CENA_MENU, 0.8)
