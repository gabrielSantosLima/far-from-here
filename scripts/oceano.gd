extends Node2D

## Mantém a grade de água animada cobrindo a câmera (oceano "infinito"),
## grudando na grade de tiles para o padrão não deslizar.

@export var tile_size := Vector2(342, 180)

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var c := cam.get_screen_center_position()
	position = Vector2(
		floorf(c.x / tile_size.x) * tile_size.x,
		floorf(c.y / tile_size.y) * tile_size.y
	)
