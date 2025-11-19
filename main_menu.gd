extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	# Apply theme
	theme = load("res://resources/themes/main_theme.tres")
	
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Animate entrance
	animate_entrance()
	
	# Play menu music (jika ada)
	# AudioManager.play_music("res://assets/audio/music/menu_theme.ogg")

func animate_entrance():
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func _on_start_pressed():
	print("Start pressed")
	# AudioManager.play_sfx("res://assets/audio/sfx/button_click.wav")
	SceneManager.change_scene("res://scenes/menus/stage_select.tscn")

func _on_settings_pressed():
	print("Settings pressed")
	# AudioManager.play_sfx("res://assets/audio/sfx/button_click.wav")
	# SceneManager.change_scene("res://scenes/menus/settings.tscn")
	push_warning("Settings not implemented yet")

func _on_quit_pressed():
	print("Quit pressed")
	# AudioManager.play_sfx("res://assets/audio/sfx/button_click.wav")
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
