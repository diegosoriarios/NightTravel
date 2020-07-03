extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	for light in $Lights.get_children():
		light.transform.origin.z += .1
		if light.transform.origin.z > 5:
			light.transform.origin.z = -5
