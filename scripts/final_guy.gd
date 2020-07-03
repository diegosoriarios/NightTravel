extends Spatial

onready var player = get_parent().get_parent().find_node("Player")
onready var movement = get_parent()
var stand = true

func _ready():
	pass # Replace with function body.

func _process(delta):
	if \
	(Input.is_action_just_pressed("move_backwards") or \
	Input.is_action_just_pressed("move_forward") or \
	Input.is_action_just_pressed("move_left") or \
	Input.is_action_just_pressed("move_right")) and \
	stand:
		movement.find_node("Animation").play("move")
		$AnimationPlayer.play("standtosit")
		stand = false
