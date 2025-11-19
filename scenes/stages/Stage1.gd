extends Node2D

@onready var rhythm_controller: RhythmController = $RhythmController
@onready var note_spawner: Node2D = $GameplayLayer/NoteSpawner
@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var enemy_sprite: Sprite2D = $BattleLayer/EnemySprite
@onready var player_sprite: Sprite2D = $BattleLayer/PlayerSprite
@onready var enemy_hp_bar: ProgressBar = $BattleLayer/EnemyHealthBar

@onready var score_label: Label = $UILayer/TopUI/ScoreLabel
@onready var combo_label: Label = $UILayer/TopUI/ComboLabel
@onready var accuracy_label: Label = $UILayer/TopUI/AccuracyLabel
@onready var judgement_label: Label = $UILayer/JudgementLabel

var stage_data: StageData
var enemy_hp: int = 100

var lane_keys = [KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K]

func _ready():
	load_stage_data()
	setup_game()
	
	await get_tree().create_timer(2.0).timeout
	start_game()

func load_stage_data():
	stage_data = StageData.new()
	stage_data.stage_number = 1
	stage_data.stage_name = "Cheddar Funk"
	stage_data.bpm = 120.0
	stage_data.enemy_max_hp = 100
	
	# Generate test beatmap
	stage_data.beatmap = generate_test_beatmap()
	
	# Load music (jika ada)
	# stage_data.music_file = load("res://assets/audio/music/stage1.ogg")
	
	enemy_hp = stage_data.enemy_max_hp
	enemy_hp_bar.max_value = enemy_hp
	enemy_hp_bar.value = enemy_hp

func generate_test_beatmap() -> Array[Dictionary]:
	var beatmap: Array[Dictionary] = []
	var beat_duration = 60.0 / 120.0  # 120 BPM
	
	# 60 seconds of notes (120 beats)
	for i in range(120):
		beatmap.append({
			"time": i * beat_duration,
			"lane": i % 5,
			"type": "TAP"
		})
	
	return beatmap

func setup_game():
	rhythm_controller.initialize(stage_data, note_spawner, music_player)
	
	rhythm_controller.note_judged.connect(_on_note_judged)
	rhythm_controller.combo_broken.connect(_on_combo_broken)
	rhythm_controller.song_finished.connect(_on_song_finished)
	
	update_ui()

func start_game():
	rhythm_controller.start_song()
	print("🎮 Stage 1 started!")

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
	
	for i in range(lane_keys.size()):
		if event.keycode == lane_keys[i]:
			on_lane_input(i)
			break

func on_lane_input(lane: int):
	var accuracy = rhythm_controller.judge_input(lane)
	
	if accuracy != "MISS":
		attack_enemy(10)

func attack_enemy(damage: int):
	enemy_hp -= damage
	enemy_hp = max(0, enemy_hp)
	enemy_hp_bar.value = enemy_hp
	
	# Flash effect
	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)
	
	# Player attack animation
	var attack_tween = create_tween()
	attack_tween.tween_property(player_sprite, "position:x", player_sprite.position.x + 50, 0.1)
	attack_tween.tween_property(player_sprite, "position:x", player_sprite.position.x, 0.1)
	
	if enemy_hp <= 0:
		on_enemy_defeated()

func on_enemy_defeated():
	print("💀 Enemy defeated!")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(enemy_sprite, "modulate:a", 0.0, 1.0)
	tween.tween_property(enemy_sprite, "scale", Vector2(3, 3), 1.0)

func _on_note_judged(accuracy: String, combo: int):
	show_judgement(accuracy)
	update_ui()

func _on_combo_broken():
	combo_label.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	combo_label.modulate = Color.WHITE

func _on_song_finished():
	print("🏁 Song finished!")
	await get_tree().create_timer(1.0).timeout
	show_results()

func show_judgement(accuracy: String):
	judgement_label.text = accuracy
	judgement_label.visible = true
	
	match accuracy:
		"PERFECT": judgement_label.add_theme_color_override("font_color", Color.GOLD)
		"GREAT": judgement_label.add_theme_color_override("font_color", Color.GREEN)
		"GOOD": judgement_label.add_theme_color_override("font_color", Color.CYAN)
		"OK": judgement_label.add_theme_color_override("font_color", Color.ORANGE)
		"MISS": judgement_label.add_theme_color_override("font_color", Color.RED)
	
	judgement_label.scale = Vector2(2, 2)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(judgement_label, "scale", Vector2.ONE, 0.3)
	tween.tween_property(judgement_label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	
	await tween.finished
	judgement_label.visible = false
	judgement_label.modulate.a = 1.0

func update_ui():
	score_label.text = "Score: %d" % rhythm_controller.score
	combo_label.text = "Combo: %dx" % rhythm_controller.combo
	accuracy_label.text = "Accuracy: %.1f%%" % rhythm_controller.get_accuracy()

func show_results():
	var rank = rhythm_controller.get_rank()
	
	GameManager.save_stage_score(
		1,
		rhythm_controller.score,
		rank,
		rhythm_controller.max_combo
	)
	GameManager.unlock_stage(2)
	GameManager.add_party_member("Claire")
	
	print("📊 Results:")
	print("  Score: %d" % rhythm_controller.score)
	print("  Rank: %s" % rank)
	print("  Max Combo: %d" % rhythm_controller.max_combo)
	
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://scenes/menus/stage_select.tscn")
