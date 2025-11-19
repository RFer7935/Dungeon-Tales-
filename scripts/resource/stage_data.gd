extends Resource
class_name StageData

@export var stage_number: int = 1
@export var stage_name: String = "Stage 1"
@export var bpm: float = 120.0
@export var offset: float = 0.0

@export var music_file: AudioStream

@export var enemy_name: String = "Enemy"
@export var enemy_max_hp: int = 100

# Beatmap: array of dictionaries
# Each note: {time: float, lane: int, type: String}
@export var beatmap: Array[Dictionary] = []
