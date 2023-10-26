extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Collectable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_interaction_body_entered(body):
	if body.is_in_group("Player"):
		queue_free()
