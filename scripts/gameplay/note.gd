extends Area2D
class_name RhythmNote

enum NoteType { TAP, HOLD, SPECIAL }

var note_type: NoteType = NoteType.TAP
var lane: int = 0
var hit_time: float = 0.0
var speed: float = 400.0
var was_hit: bool = false

signal note_hit(accuracy: String)
signal note_missed

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.texture = load("res://icon.svg")
	sprite.scale = Vector2(0.5, 0.5)
	setup_visual()

func setup_visual():
	# Create simple circle sprite if no sprite exists
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	
	# Color by type
	match note_type:
		NoteType.TAP:
			modulate = Color.WHITE
		NoteType.HOLD:
			modulate = Color.YELLOW
		NoteType.SPECIAL:
			modulate = Color.RED
			scale = Vector2(1.5, 1.5)

func _process(delta):
	# Move down
	position.y += speed * delta
	
	# Auto-miss if too far down
	if position.y > 750 and not was_hit:
		note_missed.emit()
		queue_free()

func try_hit(current_time: float) -> String:
	if was_hit:
		return "MISS"
	
	var time_diff = abs(current_time - hit_time)
	var accuracy = calculate_accuracy(time_diff)
	
	if accuracy != "MISS":
		was_hit = true
		play_hit_effect()
		note_hit.emit(accuracy)
		queue_free()
	
	return accuracy

func calculate_accuracy(time_diff: float) -> String:
	if time_diff <= 0.05:
		return "PERFECT"
	elif time_diff <= 0.1:
		return "GREAT"
	elif time_diff <= 0.15:
		return "GOOD"
	elif time_diff <= 0.2:
		return "OK"
	else:
		return "MISS"

func play_hit_effect():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", scale * 1.5, 0.2)
