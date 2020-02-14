extends KinematicBody2D
class_name Character

### Special effects
var dust_effect # Will be added back once fall damage has been implemented
### ---

### Sync
puppetsync var r_position = Vector2(0, 0)
puppetsync var r_animation = ""
puppetsync var r_flip_horizontal = false

var p_position = Vector2(0, 0)
var p_jumping = false
### ---

onready var c_sprite = $Sprite
onready var c_anim = $Sprite/Animation
onready var c_body = $Sprite/Body
onready var c_head = $Sprite/Head
onready var c_name = $Name

onready var c_controller = $Client/Controller

# Has information about the local player
var pinfo

### Physics
export (int) var fps = 24

export (float) var mass = 64
export (float) var gravity_scale = 1

export (float) var run_speed = 68
export (float) var walk_speed = 68
export (float) var jump_speed = 20

export (float) var backward_scale = 0.8

var velocity = Vector2(0, 0)
### ---

func _setup(t_pinfo):
	pinfo = t_pinfo
	set_name(str(pinfo.id))

	set_network_master(1)
	$Client.set_network_master(pinfo.id)

func _ready():
	c_name.text = pinfo.name

	if $Client.is_network_master():
		game_camera.target = self

func _process(delta):
	if is_network_master():
		pass
	else:
		# TODO: Implement position interpolation
		position = r_position

func _physics_process(delta):
	if is_network_master():
		_process_input(delta)
		_process_animation(delta)

		velocity.y += (game_map.gravity * mass * gravity_scale) * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))

	_sync(delta)

### Event processing

func _animate(animation):
	if c_anim.has_animation(animation):
		c_anim.play(animation)

func _process_input(_delta):
	velocity.x = 0

	# Walk
	var _xvel = 0

	if c_controller.r_move_right:
		_xvel = walk_speed * (backward_scale if r_flip_horizontal else 1)
		velocity.x += _xvel

	if c_controller.r_move_left:
		_xvel = walk_speed * (1 if r_flip_horizontal else backward_scale)
		velocity.x -= _xvel

	# Jump
	if c_controller.r_jumping && !c_controller.r_crouching && is_on_floor():
		velocity.y = -(game_map.gravity * jump_speed)

func _process_animation(_delta):
	if is_on_floor():
		if c_controller.r_move_left or c_controller.r_move_right:
			_animate("walk")
		else:
			if c_controller.r_crouching:
				_animate("crouch")
			else:
				_animate("idle")

		if c_controller.r_jumping:
			_animate("jump")

var timer = 0
func _sync(delta):
	timer += delta
	if timer > 1.0 / fps:
		timer -= 1.0 / fps
	else:
		return

	if is_network_master():
		var flip_horizontal = false

		if c_controller.r_mouse_position_relative.x < 0:
			flip_horizontal = true

		if r_flip_horizontal != flip_horizontal:
			rset("r_flip_horizontal", flip_horizontal)

		if r_animation != c_anim.current_animation:
			rset("r_animation", c_anim.current_animation)

		rset_unreliable("r_position", position)
	else:
		_animate(r_animation)
		p_position = position

	if r_flip_horizontal:
		c_sprite.scale.x = -abs(c_sprite.scale.x)
	else:
		c_sprite.scale.x = abs(c_sprite.scale.x)

### ---
