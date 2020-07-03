extends KinematicBody

var camera_angle = 0
var mouse_sensitivity = 0.3
var camera_change = Vector2()

var velocity = Vector3()
var direction = Vector3()

#fly variables
const FLY_SPEED = 20
const FLY_ACCEL = 4
var flying = false

#walk variables
var gravity = -9.8 * 3
const MAX_SPEED = 1
const MAX_RUNNING_SPEED = 1
const ACCEL = .5
const DEACCEL = 10

#jumping
var jump_height = 15
var in_air = 0
var has_contact = false

#slope variables
const MAX_SLOPE_ANGLE = 35

#stair variables
const MAX_STAIR_SLOPE = 20
const STAIR_JUMP_HEIGHT = 6

export (PackedScene) var next_scene

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _physics_process(delta):
	aim()
	walk(delta)
	

func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			if $UI/Description.text != "":
				if $UI/Description.text == "Restroom" or $UI/Description.text == "Sit":
					$Animation.play("FadeIn")
				elif $UI/Description.text == "Leave":
					pass
		
func walk(delta):
	# reset the direction of the player
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	# check input and change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backwards"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	direction.y = 0
	direction = direction.normalized()
	
	velocity.y += gravity * delta

	if (has_contact and !is_on_floor()):
		move_and_collide(Vector3(0, -1, 0))
	
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	
	# where would the player go at max speed
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	# calculate a portion of the distance to go
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	if has_contact and Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
		has_contact = false
	
	# move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
func aim():
	if camera_change.length() > 0:
		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))

		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()
		if $Head/Camera/RayCast.is_colliding():
			var collider = $Head/Camera/RayCast.get_collider()
			if collider.name != "RigidBody":
				$UI/Description.text = collider.name
		else:
			$UI/Description.text = ""

func change_scene():
	get_tree().change_scene_to(next_scene)
