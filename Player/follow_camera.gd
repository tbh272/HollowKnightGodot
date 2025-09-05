extends Node2D

@onready var camera: Camera2D = $"."
@export var player: CharacterBody2D = get_parent() # Adjust path to your player
@onready var camera_target : Node2D = player.get_node("CameraTarget")

# Exportable variables for tweaking
@export var base_zoom: Vector2 = Vector2(0.95, 0.95)
@export var zoom_speed: float = 2.0
@export var offset_base: Vector2 = Vector2(0, -50)
@export var transition_speed: float = 5.0

# Room transition variables
var target_limits: Dictionary = {}
var is_transitioning: bool = false

func _ready() -> void:
	camera.zoom = base_zoom
	camera.offset = offset_base
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0

func _physics_process(delta: float) -> void:
	# Follow the camera target (player's focus point)
	global_position = camera_target.global_position

	# Handle room transitions
	if is_transitioning:
		_update_camera_limits(delta)

	# Dynamic zoom (example: adjust based on player velocity or area)
	var target_zoom = base_zoom
	if player.velocity.length() > 400: # Zoom out slightly when moving fast (e.g., dashing)
		target_zoom = base_zoom * 0.9
	camera.zoom = camera.zoom.lerp(target_zoom, zoom_speed * delta)

func _update_camera_limits(delta: float) -> void:
	# Smoothly interpolate camera limits for room transitions
	camera.limit_left = lerp(camera.limit_left, float(target_limits["left"]), transition_speed * delta)
	camera.limit_right = lerp(camera.limit_right, float(target_limits["right"]), transition_speed * delta)
	camera.limit_top = lerp(camera.limit_top, float(target_limits["top"]), transition_speed * delta)
	camera.limit_bottom = lerp(camera.limit_bottom, float(target_limits["bottom"]), transition_speed * delta)
	
	# Stop transitioning when close enough
	if abs(camera.limit_left - target_limits["left"]) < 1.0:
		is_transitioning = false

# Call this when entering a new room (e.g., via Area2D body_entered signal)
func set_room_limits(left: float, right: float, top: float, bottom: float) -> void:
	target_limits = {
		"left": left,
		"right": right,
		"top": top,
		"bottom": bottom
	}
	is_transitioning = true
