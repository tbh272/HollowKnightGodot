extends CharacterBody2D

# Enum for movement states (extensible for more like ATTACK)
enum State {
	IDLE,
	RUN,
	JUMP_RISE,
	JUMP_FALL,
	DASH,
	WALL_SLIDE,
	WALL_JUMP
}

# Reference to AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $Sprite

# Exportable variables for tweaking
@export var move_speed: float = 400.0
@export var jump_velocity: float = -800.0
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.6
@export var wall_slide_speed: float = 100.0
@export var wall_jump_velocity: Vector2 = Vector2(500.0, -500.0)
@export var gravity: float = 2000.0

@export var wall_coyote_time: float = 0.15   # grace after leaving wall
@export var jump_buffer_time: float = 0.15   # grace after pressing jump early

var wall_coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Internal variables
var current_state: State = State.IDLE
var is_dashing: bool = false
var dash_timer: float = 0.0
var is_wall_sliding: bool = false
var facing_direction: float = 1.0

func _ready() -> void:
	# Connect signals for animation events
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("Idle")  # Start with idle

func _physics_process(delta: float) -> void:
	# Update wall coyote timer
	if is_on_wall() and not is_on_floor():
		wall_coyote_timer = wall_coyote_time
	else:
		wall_coyote_timer = max(wall_coyote_timer - delta, 0.0)

	# Update jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	# Apply gravity when not on floor or wall sliding
	if not is_on_floor() and not is_wall_sliding:
		velocity.y += gravity * delta

	# Handle movement states (dash overrides others)
	if is_dashing:
		_handle_dash(delta)
	else:
		_handle_movement()
		_handle_jump()
		_handle_dash_input()
		_handle_wall_slide()
		_handle_wall_jump()

	# Move the character
	move_and_slide()

	# Update state based on current conditions
	_update_state()

	# Play animation based on state
	_update_animation()

	# Flip sprite based on facing direction
	_flip_sprite()

func _handle_movement() -> void:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity.x = input_direction.x * move_speed
	if input_direction.x != 0:
		facing_direction = sign(input_direction.x)

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _handle_dash_input() -> void:
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		velocity.x = facing_direction * dash_speed
		velocity.y = 0

func _handle_dash(delta: float) -> void:
	dash_timer -= delta
	if dash_timer <= 0:
		is_dashing = false
		velocity.x = 0

func _handle_wall_slide() -> void:
	is_wall_sliding = false
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		is_wall_sliding = true
		velocity.y = min(velocity.y, wall_slide_speed)

func _handle_wall_jump() -> void:
	if jump_buffer_timer > 0.0 and wall_coyote_timer > 0.0:
		var wall_normal = get_wall_normal()

		# Safety check if wall_normal = ZERO (just left wall)
		if wall_normal == Vector2.ZERO:
			wall_normal.x = -facing_direction

		# Always push away from wall
		velocity.x = wall_jump_velocity.x * wall_normal.x
		velocity.y = wall_jump_velocity.y

		# Flip facing
		facing_direction = sign(velocity.x)

		# Clear timers so we don’t double-trigger
		jump_buffer_timer = 0.0
		wall_coyote_timer = 0.0
		is_wall_sliding = false

# Update the current state based on conditions
func _update_state() -> void:
	if is_dashing:
		current_state = State.DASH
	elif is_wall_sliding:
		current_state = State.WALL_SLIDE
	elif is_on_wall() and velocity.y < 0:  # Brief wall jump state
		current_state = State.WALL_JUMP
	elif not is_on_floor():
		if velocity.y < 0:
			current_state = State.JUMP_RISE
		else:
			current_state = State.JUMP_FALL
	else:
		if abs(velocity.x) > 0:
			current_state = State.RUN
		else:
			current_state = State.IDLE

# Play animation based on current state
func _update_animation() -> void:
	match current_state:
		State.IDLE:
			if animated_sprite.animation != "Idle":
				animated_sprite.play("Idle")
		State.RUN:
			if animated_sprite.animation != "Run":
				animated_sprite.play("Run")
		State.JUMP_RISE:
			if animated_sprite.animation != "Jump":
				animated_sprite.play("Jump")
		State.JUMP_FALL:
			if animated_sprite.animation != "Fall":
				animated_sprite.play("Fall")
		State.DASH:
			if animated_sprite.animation != "Dash":
				animated_sprite.play("Dash")
		State.WALL_SLIDE:
			if animated_sprite.animation != "Wall_Slide":
				animated_sprite.play("Wall_Slide")
		State.WALL_JUMP:
			if animated_sprite.animation != "Wall_Jump":
				animated_sprite.play("Wall_Jump")

# Flip the sprite horizontally
func _flip_sprite() -> void:
	if facing_direction != 0:
		animated_sprite.flip_h = facing_direction > 0

# Handle animation finished signal for one-shot animations
func _on_animation_finished() -> void:
	match current_state:
		State.DASH:
			# Reset to idle or run after dash
			_update_state()  # Re-evaluate state
		State.WALL_JUMP:
			# Transition to fall or other air state
			_update_state()
		# Add more for future states, e.g., attack finish
