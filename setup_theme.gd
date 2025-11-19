@tool
extends EditorScript

func _run():
	print("🎨 Creating Dungeon Tales Theme...")
	
	var theme = Theme.new()
	
	# === FONTS ===
	var body_font_path = "res://assets/fonts/Roboto-Black.ttf"
	var title_font_path = "res://assets/fonts/Bangers-Regular.ttf"
	
	var body_font: Font = null
	var title_font: Font = null
	
	# Load fonts
	if FileAccess.file_exists(body_font_path):
		body_font = load(body_font_path)
		print("✅ Body font loaded")
	else:
		print("⚠️ Body font not found, using default")
		body_font = SystemFont.new()
	
	if FileAccess.file_exists(title_font_path):
		title_font = load(title_font_path)
		print("✅ Title font loaded")
	else:
		title_font = body_font
	
	# === DEFAULT SETTINGS ===
	theme.default_font = body_font
	theme.default_font_size = 16
	
	# === LABEL ===
	theme.set_font("font", "Label", body_font)
	theme.set_font_size("font_size", "Label", 16)
	theme.set_color("font_color", "Label", Color("#EEEEEE"))
	theme.set_color("font_shadow_color", "Label", Color("#00000080"))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 2)
	
	# === BUTTON ===
	theme.set_font("font", "Button", body_font)
	theme.set_font_size("font_size", "Button", 18)
	theme.set_color("font_color", "Button", Color("#FFFFFF"))
	theme.set_color("font_hover_color", "Button", Color("#FFD700"))
	theme.set_color("font_pressed_color", "Button", Color("#FFA000"))
	
	# Button Normal
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#6A1B9A")
	btn_normal.set_border_width_all(3)
	btn_normal.border_width_bottom = 5
	btn_normal.border_color = Color("#9C27B0")
	btn_normal.set_corner_radius_all(8)
	btn_normal.shadow_color = Color("#00000080")
	btn_normal.shadow_size = 4
	btn_normal.shadow_offset = Vector2(2, 4)
	theme.set_stylebox("normal", "Button", btn_normal)
	
	# Button Hover
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color("#7B1FA2")
	btn_hover.border_color = Color("#CE93D8")
	btn_hover.shadow_size = 6
	theme.set_stylebox("hover", "Button", btn_hover)
	
	# Button Pressed
	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = Color("#4A148C")
	btn_pressed.border_width_bottom = 2
	btn_pressed.shadow_size = 2
	theme.set_stylebox("pressed", "Button", btn_pressed)
	
	# Button Disabled
	var btn_disabled = btn_normal.duplicate()
	btn_disabled.bg_color = Color("#45545480")
	theme.set_stylebox("disabled", "Button", btn_disabled)
	
	# === PANEL ===
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#212121E6")
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color("#455A64")
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color("#000000CC")
	panel_style.shadow_size = 8
	panel_style.shadow_offset = Vector2(0, 4)
	theme.set_stylebox("panel", "Panel", panel_style)
	
	# === PROGRESS BAR ===
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = Color("#37474F")
	progress_bg.set_border_width_all(1)
	progress_bg.border_color = Color("#000000")
	progress_bg.set_corner_radius_all(4)
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color("#CDDC39")
	progress_fill.set_corner_radius_all(4)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)
	
	# === SAVE ===
	var save_path = "res://resources/themes/main_theme.tres"
	var error = ResourceSaver.save(theme, save_path)
	
	if error == OK:
		print("🎉 Theme created at: ", save_path)
	else:
		print("❌ Error: ", error)
