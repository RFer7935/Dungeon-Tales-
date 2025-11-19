extends Node

# Audio Players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Current music
var current_music: String = ""

func _ready():
	# Create Music Player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"
	
	# Create SFX Player
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	
	# Apply initial volumes
	apply_volume_settings()

func play_music(music_path: String, fade_duration: float = 1.0):
	# Don't restart if same music
	if current_music == music_path and music_player.playing:
		return
	
	# Fade out current music
	if music_player.playing:
		fade_out_music(fade_duration / 2.0)
		await get_tree().create_timer(fade_duration / 2.0).timeout
	
	# Load and play new music
	var stream = load(music_path) as AudioStream
	if stream:
		music_player.stream = stream
		music_player.volume_db = -80.0  # Start silent
		music_player.play()
		current_music = music_path
		
		# Fade in
		fade_in_music(fade_duration / 2.0)
	else:
		push_error("❌ Failed to load music: " + music_path)

func fade_in_music(duration: float):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, duration)

func fade_out_music(duration: float):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, duration)

func stop_music():
	music_player.stop()
	current_music = ""

func play_sfx(sfx_path: String, volume_db: float = 0.0):
	var stream = load(sfx_path) as AudioStream
	if stream:
		# For multiple SFX at once, create temporary player
		var temp_player = AudioStreamPlayer.new()
		add_child(temp_player)
		temp_player.bus = "SFX"
		temp_player.stream = stream
		temp_player.volume_db = volume_db
		temp_player.play()
		
		# Auto-delete when finished
		temp_player.finished.connect(func(): temp_player.queue_free())
	else:
		push_error("❌ Failed to load SFX: " + sfx_path)

func apply_volume_settings():
	set_master_volume(GameManager.master_volume)
	set_music_volume(GameManager.music_volume)
	set_sfx_volume(GameManager.sfx_volume)

func set_master_volume(volume: float):
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	GameManager.master_volume = volume

func set_music_volume(volume: float):
	var bus_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	GameManager.music_volume = volume

func set_sfx_volume(volume: float):
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	GameManager.sfx_volume = volume
