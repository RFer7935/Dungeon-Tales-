extends Control

# Stage data
const STAGE_INFO = {
	1: {"name": "Cheddar Funk", "desc": "Face the Cheddar Golem!"},
	2: {"name": "Luminescent Threads", "desc": "Meet Claire and learn harmony."},
	3: {"name": "Bubble Cacophony", "desc": "Mini-boss: Bubble Dragon!"},
	4: {"name": "Zippel's Symphony", "desc": "Chaotic magic with Joshua!"},
	5: {"name": "Rhythmic Synergy", "desc": "Team coordination medley."},
	6: {"name": "Pineapple Polemic", "desc": "Debate battle with Dovalovna!"},
	7: {"name": "Architectural Harmonies", "desc": "Explore the dungeon depths."},
	8: {"name": "Riddle of Cosmos", "desc": "Answer the Sphinx's riddles."},
	9: {"name": "Echoes of Arrogance", "desc": "Leuser's reflection."},
	10: {"name": "Atonement", "desc": "Final Boss - Face yourself!"},
}

@onready var stage_grid: GridContainer = $MarginContainer/VBoxContainer/StageGrid
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton
@onready var stage_info_panel: Panel = $StageInfoPanel
@onready var stage_title: Label = $StageInfoPanel/VBoxContainer/StageTitle
@onready var stage_description: RichTextLabel = $StageInfoPanel/VBoxContainer/StageDescription
@onready var best_score_label: Label = $StageInfoPanel/VBoxContainer/BestScoreLabel
@onready var play_button: Button = $StageInfoPanel/VBoxContainer/ButtonsContainer/PlayButton
@onready var close_button: Button = $StageInfoPanel/VBoxContainer/ButtonsContainer/CloseButton

var stage_button_scene = preload("res://scenes/ui/stage_button.tscn")
var selected_stage: int = -1

func _ready():
	theme = load("res://resources/themes/main_theme.tres")
	
	back_button.pressed.connect(_on_back_pressed)
	play_button.pressed.connect(_on_play_pressed)
	close_button.pressed.connect(_on_close_panel)
	
	stage_info_panel.visible = false
	
	create_stage_buttons()

func create_stage_buttons():
	# Clear existing
	for child in stage_grid.get_children():
		child.queue_free()
	
	# Create buttons for 10 stages
	for i in range(1, 11):
		var button = stage_button_scene.instantiate()
		stage_grid.add_child(button)
		
		var stage_name = STAGE_INFO[i].name
		var is_locked = i > GameManager.max_unlocked_stage
		var rank = ""
		
		if GameManager.stage_scores.has(i):
			rank = GameManager.stage_scores[i].rank
		
		button.setup(i, stage_name, is_locked, rank)
		button.pressed.connect(_on_stage_button_pressed.bind(i))

func _on_stage_button_pressed(stage_num: int):
	if stage_num > GameManager.max_unlocked_stage:
		return
	
	selected_stage = stage_num
	show_stage_info(stage_num)

func show_stage_info(stage_num: int):
	var info = STAGE_INFO[stage_num]
	
	stage_title.text = "Stage %d: %s" % [stage_num, info.name]
	stage_description.text = info.desc
	
	if GameManager.stage_scores.has(stage_num):
		var score_data = GameManager.stage_scores[stage_num]
		best_score_label.text = "Best: %d (Rank %s) - Combo x%d" % [
			score_data.score,
			score_data.rank,
			score_data.combo
		]
	else:
		best_score_label.text = "Not played yet"
	
	stage_info_panel.visible = true

func _on_play_pressed():
	if selected_stage == -1:
		return
	
	GameManager.current_stage = selected_stage
	var stage_scene = "res://scenes/stages/stage_%d.tscn" % selected_stage
	SceneManager.change_scene(stage_scene)

func _on_close_panel():
	stage_info_panel.visible = false
	selected_stage = -1

func _on_back_pressed():
	SceneManager.change_scene("res://scenes/menus/main_menu.tscn")
