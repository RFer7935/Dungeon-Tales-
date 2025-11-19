extends Node
class_name RhythmController

signal note_judged(accuracy: String, combo: int)
signal combo_broken
signal song_finished

var stage_data: StageData
var music_player: AudioStreamPlayer

var song_position: float = 0.0
var is_playing: bool = false

var beatmap: Array[Dictionary] = []
var current_note_index: int = 0
var spawn_offset: float = 2.0  # Spawn 2 seconds early

var note_scene: PackedScene = preload("res://scenes/gameplay/note.tscn")
var note_spawn_parent: Node2D

# Scoring
var score: int = 0
var combo: int = 0
var max_combo: int = 0
var judgement_counts: Dictionary = {
	"PERFECT": 0,
	"GREAT": 0,
	"GOOD": 0,
	"OK": 0,
	"MISS": 0
}

func initialize(data: StageData, spawn_parent: Node2D, audio_player: AudioStreamPlayer):
	stage_data = data
	note_spawn_parent = spawn_parent
	music_player = audio_player
	beatmap = data.beatmap.duplicate()
	
	music_player.stream = data.music_file

func start_song():
	current_note_index = 0
	song_position = 0.0
	is_playing = true
	music_player.play()
	set_process(true)

func _process(delta):
	if not is_playing:
		return
	
	# Update song position
	song_position = music_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency()
	
	# Spawn notes
	spawn_notes()
	
	# Check end
	if not music_player.playing and current_note_index >= beatmap.size():
		finish_song()

func spawn_notes():
	while current_note_index < beatmap.size():
		var note_data = beatmap[current_note_index]
		var note_time = note_data.time
		
		if song_position >= note_time - spawn_offset:
			spawn_note(note_data)
			current_note_index += 1
		else:
			break

func spawn_note(note_data: Dictionary):
	var note = note_scene.instantiate() as RhythmNote
	note_spawn_parent.add_child(note)
	
	note.lane = note_data.get("lane", 0)
	note.hit_time = note_data.time
	
	var note_type_str = note_data.get("type", "TAP")
	match note_type_str:
		"TAP": note.note_type = RhythmNote.NoteType.TAP
		"HOLD": note.note_type = RhythmNote.NoteType.HOLD
		"SPECIAL": note.note_type = RhythmNote.NoteType.SPECIAL
	
	# Position by lane (5 lanes)
	var lane_positions = [300, 450, 600, 750, 900]
	note.position = Vector2(lane_positions[note.lane], 0)
	
	note.note_hit.connect(_on_note_hit)
	note.note_missed.connect(_on_note_missed)

func judge_input(lane: int) -> String:
	var closest_note: RhythmNote = null
	var closest_diff: float = INF
	
	for note in note_spawn_parent.get_children():
		if note is RhythmNote and note.lane == lane and not note.was_hit:
			var diff = abs(song_position - note.hit_time)
			if diff < closest_diff and diff <= 0.2:
				closest_note = note
				closest_diff = diff
	
	if closest_note:
		return closest_note.try_hit(song_position)
	
	return "MISS"

func _on_note_hit(accuracy: String):
	add_score(accuracy)
	add_combo()
	judgement_counts[accuracy] += 1
	note_judged.emit(accuracy, combo)

func _on_note_missed():
	break_combo()
	judgement_counts["MISS"] += 1
	note_judged.emit("MISS", 0)

func add_score(accuracy: String):
	var points = 0
	match accuracy:
		"PERFECT": points = 100
		"GREAT": points = 75
		"GOOD": points = 50
		"OK": points = 25
	
	var multiplier = 1.0 + (combo * 0.01)
	score += int(points * multiplier)

func add_combo():
	combo += 1
	if combo > max_combo:
		max_combo = combo

func break_combo():
	combo = 0
	combo_broken.emit()

func finish_song():
	is_playing = false
	set_process(false)
	song_finished.emit()

func get_rank() -> String:
	var total = beatmap.size()
	if total == 0:
		return "D"
	
	var perfect_ratio = float(judgement_counts["PERFECT"]) / total
	
	if perfect_ratio >= 0.95:
		return "S"
	elif perfect_ratio >= 0.85:
		return "A"
	elif perfect_ratio >= 0.70:
		return "B"
	elif perfect_ratio >= 0.50:
		return "C"
	else:
		return "D"

func get_accuracy() -> float:
	var total = beatmap.size()
	if total == 0:
		return 0.0
	
	var weighted = (
		judgement_counts["PERFECT"] * 1.0 +
		judgement_counts["GREAT"] * 0.75 +
		judgement_counts["GOOD"] * 0.5 +
		judgement_counts["OK"] * 0.25
	)
	
	return (weighted / total) * 100.0
