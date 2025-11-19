extends Node

# Transition overlay
var transition_scene: PackedScene = null
var current_transition: CanvasLayer = null

# Loading flag
var is_transitioning: bool = false

func _ready():
	# Preload transition scene (akan kita buat nanti)
	# transition_scene = preload("res://scenes/ui/transition.tscn")
	pass

func change_scene(scene_path: String, transition_duration: float = 0.5):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Fade out
	if transition_scene:
		current_transition = transition_scene.instantiate()
		get_tree().root.add_child(current_transition)
		await current_transition.fade_in(transition_duration / 2.0)
	else:
		# Simple fade without custom transition scene
		await simple_fade_out(transition_duration / 2.0)
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	
	# Wait a frame for new scene to load
	await get_tree().process_frame
	
	# Fade in
	if transition_scene and current_transition:
		await current_transition.fade_out(transition_duration / 2.0)
		current_transition.queue_free()
	else:
		await simple_fade_in(transition_duration / 2.0)
	
	is_transitioning = false

func reload_scene():
	var current_scene_path = get_tree().current_scene.scene_file_path
	change_scene(current_scene_path)

func simple_fade_out(duration: float):
	# Create simple black overlay
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.color.a = 0.0
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(overlay)
	
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, duration)
	await tween.finished
	
	overlay.queue_free()

func simple_fade_in(duration: float):
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(overlay)
	
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, duration)
	await tween.finished
	
	overlay.queue_free()
