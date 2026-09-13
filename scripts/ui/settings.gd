extends Control

#region Child References
@export var CameraBobbing: HBoxContainer
@onready var camera_bobbing = CameraBobbing.get_node("CheckBox")

@export var MasterVolume: HBoxContainer
@onready var master_volume_slider = MasterVolume.get_node("HSlider")
@onready var master_volume_text = MasterVolume.get_node("LineEdit")
#endregion

var player_config: SettingsConfig

func _ready() -> void:
	# Check to see if this player already has a config to load, otherwise make a new one
	if !ResourceLoader.exists("user://player_config.tres"):
		player_config = SettingsConfig.new()
		ResourceSaver.save(player_config, "user://player_config.tres")
	else:
		player_config = ResourceLoader.load("user://player_config.tres")
	
	# Sync the settings menu to the config file
	master_volume_slider.value = player_config.master_volume
	master_volume_text.text = str(player_config.master_volume)
	camera_bobbing.button_pressed = player_config.enable_camera_bobbing
	
	master_volume_slider.drag_ended.connect(master_volume_slider_changed)
	master_volume_text.text_submitted.connect(master_volume_text_changed)
	camera_bobbing.toggled.connect(camera_bobbing_changed)
	
func master_volume_slider_changed(_changed) -> void:
	player_config.master_volume = master_volume_slider.value
	master_volume_text.text = str(master_volume_slider.value)
	ResourceSaver.save(player_config, "user://player_config.tres")

func master_volume_text_changed(new_text) -> void:
	player_config.master_volume = int(new_text)
	master_volume_slider.value = int(new_text)
	ResourceSaver.save(player_config, "user://player_config.tres")
	
func camera_bobbing_changed(toggled_on) -> void:
	if toggled_on: player_config.enable_camera_bobbing = true
	else: player_config.enable_camera_bobbing = false
	ResourceSaver.save(player_config, "user://player_config.tres")
