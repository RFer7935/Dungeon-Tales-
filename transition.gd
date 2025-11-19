extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready():
	# Start transparent
	color_rect.color.a = 0.0
	# Block input during transition
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

func fade_in(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_out(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished
