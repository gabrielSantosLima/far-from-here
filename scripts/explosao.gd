extends Sprite2D

## Efeito de explosão: cresce e some sozinho.

func _ready() -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", scale * 2.0, 0.35).set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "modulate:a", 0.0, 0.35)
	t.chain().tween_callback(queue_free)
