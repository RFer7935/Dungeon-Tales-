extends Node

# Game State
enum GameState { MENU, STAGE_SELECT, GAMEPLAY, PAUSED, STORY, RESULTS }
var current_state: GameState = GameState.MENU

# Player Progress
var current_stage: int = 1
var max_unlocked_stage: int = 1
var stage_scores: Dictionary = {} # {stage_number: {score, rank, combo}}

# Party Members (unlocked progressively)
var party_members: Array[String] = ["Leuser"]

# Settings
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# Save file path
const SAVE_PATH = "user://dungeon_tales_save.dat"

func _ready():
	load_game_data()

func unlock_stage(stage_number: int):
	if stage_number > max_unlocked_stage:
		max_unlocked_stage = stage_number
		save_game_data()
		print("✅ Stage %d unlocked!" % stage_number)

func save_stage_score(stage_number: int, score: int, rank: String, combo: int):
	# Save or update best score
	if not stage_scores.has(stage_number) or stage_scores[stage_number].score < score:
		stage_scores[stage_number] = {
			"score": score,
			"rank": rank,
			"combo": combo
		}
		save_game_data()
		print("✅ New best score for Stage %d: %d (%s)" % [stage_number, score, rank])

func add_party_member(member_name: String):
	if member_name not in party_members:
		party_members.append(member_name)
		save_game_data()
		print("✅ %s joined the party!" % member_name)

func save_game_data():
	var save_data = {
		"max_unlocked_stage": max_unlocked_stage,
		"stage_scores": stage_scores,
		"party_members": party_members,
		"settings": {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume
		}
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("💾 Game saved!")
	else:
		push_error("❌ Failed to save game!")

func load_game_data():
	if not FileAccess.file_exists(SAVE_PATH):
		print("ℹ️ No save file found, using defaults")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		max_unlocked_stage = save_data.get("max_unlocked_stage", 1)
		stage_scores = save_data.get("stage_scores", {})
		party_members = save_data.get("party_members", ["Leuser"])
		
		var settings = save_data.get("settings", {})
		master_volume = settings.get("master_volume", 1.0)
		music_volume = settings.get("music_volume", 1.0)
		sfx_volume = settings.get("sfx_volume", 1.0)
		
		print("✅ Game loaded!")
	else:
		push_error("❌ Failed to load game!")

func reset_progress():
	max_unlocked_stage = 1
	stage_scores.clear()
	party_members = ["Leuser"]
	save_game_data()
	print("🔄 Progress reset!")
