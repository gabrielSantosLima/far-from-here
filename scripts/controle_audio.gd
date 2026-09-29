extends HBoxContainer

## Controle de áudio simples: botão com ícone de som (ligado/desligado) + slider.
## Acessa o autoload via /root para não depender do identificador global.

const ICON_ON := "res://assets/ui/som_on.png"
const ICON_OFF := "res://assets/ui/som_off.png"

@onready var _slider: HSlider = $Volume
@onready var _botao: Button = $Mudo

func _ready() -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		_slider.value = audio.get_volume()
		_atualizar_botao(audio.is_muted())
	else:
		_atualizar_botao(false)
	_slider.value_changed.connect(_on_volume)
	_botao.pressed.connect(_on_mudo)

func _on_volume(v: float) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.set_volume(v)

func _on_mudo() -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.toggle_mute()
		_atualizar_botao(audio.is_muted())

func _atualizar_botao(mudo: bool) -> void:
	_botao.icon = load(ICON_OFF if mudo else ICON_ON)
	_botao.tooltip_text = "Som desligado (M)" if mudo else "Som ligado (M)"
