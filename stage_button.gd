extends Button

@onready var stage_number_label: Label = $VBoxContainer/StageNumberLabel
@onready var stage_name_label: Label = $VBoxContainer/StageNameLabel
@onready var rank_label: Label = $VBoxContainer/RankLabel
@onready var locked_label: Label = $VBoxContainer/LockedLabel

var stage_number: int = 0
var is_locked: bool = false

func _ready():
	# Apply hover effect
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(num: int, stage_name: String, locked: bool = false, rank: String = ""):
	stage_number = num
	stage_number_label.text = str(num)
	stage_name_label.text = stage_name
	is_locked = locked
	
	if locked:
		# Locked state
		disabled = true
		modulate = Color(0.5, 0.5, 0.5, 1.0)
		locked_label.visible = true
		rank_label.visible = false
		stage_number_label.visible = false
	else:
		# Unlocked state
		disabled = false
		modulate = Color.WHITE
		locked_label.visible = false
		stage_number_label.visible = true
		
		# Show rank if exists
		if rank != "":
			set_rank(rank)
		else:
			rank_label.visible = false

func set_rank(rank: String):
	rank_label.text = rank
	rank_label.visible = true
	
	# Color by rank
	match rank:
		"S":
			rank_label.add_theme_color_override("font_color", Color("#FFD700")) # Gold
		"A":
			rank_label.add_theme_color_override("font_color", Color("#C0C0C0")) # Silver
		"B":
			rank_label.add_theme_color_override("font_color", Color("#CD7F32")) # Bronze
		"C":
			rank_label.add_theme_color_override("font_color", Color("#87CEEB")) # Sky Blue
		"D":
			rank_label.add_theme_color_override("font_color", Color("#808080")) # Gray
		_:
			rank_label.add_theme_color_override("font_color", Color.WHITE)

func _on_mouse_entered():
	if not disabled:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)

func _on_mouse_exited():
	if not disabled:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
