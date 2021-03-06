extends Node2D

export (int) var fps = 24

### Input
var flip_horizontal = false
puppetsync var r_flip_horizontal = false

puppetsync var r_move_left = false
puppetsync var r_move_right = false
puppetsync var r_crouching = false
puppetsync var r_jumping = false
### ---

func _physics_process(delta):
	_sync(delta)

func _unhandled_input(event):
	if !is_network_master():
		return

	if Input.is_action_just_pressed("move_left"):
		rset_id(1, "r_move_left", true)
	if Input.is_action_just_released("move_left"):
		rset_id(1, "r_move_left", false)

	if Input.is_action_just_pressed("move_right"):
		rset_id(1, "r_move_right", true)
	if Input.is_action_just_released("move_right"):
		rset_id(1, "r_move_right", false)

	# Crouch
	if Input.is_action_just_pressed("crouch"):
		rset_id(1, "r_crouching", true)
	if Input.is_action_just_released("crouch"):
		rset_id(1, "r_crouching", false)

	# Jump
	if Input.is_action_just_pressed("jump"):
		rset_id(1, "r_jumping", true)
	if Input.is_action_just_released("jump"):
		rset_id(1, "r_jumping", false)

	if event is InputEventMouseMotion:
		flip_horizontal = get_global_mouse_position().x < get_parent().global_position.x

		if r_flip_horizontal != flip_horizontal:
			rset("r_flip_horizontal", flip_horizontal)

var timer = 0
func _sync(delta):
	timer += delta
	if timer > 1.0 / fps:
		timer -= 1.0 / fps
	else:
		return
