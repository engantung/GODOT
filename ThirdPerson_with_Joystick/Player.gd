extends KinematicBody

const MAX_SPEED = 5
const JUMP_SPEED = 7
const RUN_SPEED = 10
const RUN_ACCEL = 11
const ACCEL = 9
const GRAVITY = 50

onready var camera = $CameraPivot/Camera
onready var joystick = get_parent().get_node("CanvasLayer/Joystick/Sprite/TouchScreenButton")


var vel = Vector3()
var dir = Vector3()


var is_sprinting = false


const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var rotation_helper

var MOUSE_SENSITIVITY = 0.5

func _ready():
	rotation_helper = $CameraPivot
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()
	input_movement_vector.y = -joystick.get_value().y #joystick input gonkee's
	input_movement_vector.x = joystick.get_value().x #joystick input gonkee's

	if Input.is_action_pressed("ui_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement_vector.x += 1
		
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	else:
		is_sprinting = false

		
	input_movement_vector = input_movement_vector.normalized()
	

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------


	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y = delta * -GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= RUN_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = RUN_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z

	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventScreenDrag :
		#touch_mode = true
		if event.index == joystick.ongoing_drag: # joystick screendrag gonkee's 
			return
	#if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -45, 45)
		rotation_helper.rotation_degrees = camera_rot
