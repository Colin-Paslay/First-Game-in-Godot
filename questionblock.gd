extends Area2D

enum State { UNBUMPED,  BUMPED}
var state: int = State.UNBUMPED
var original_position: Vector2

func _ready():
	original_position

func _on_body_entered(body):
	if body.is_in_group("Player") and state == State.UNBUMPED:
		bump_block()

func bump_block():
	state = State.BUMPED
	$Sprite2D.frame = 1
	
	match Global.current_state:
		Global.PlayerState.SMALL:
			Global.spawn_beer_bottle(self.global_position + Vector2(0, -28))
		Global.PlayerState.BIG, Global.PlayerState.FLIP_FLOP:
			Global.spawn_flip_flop_power_up(self.global_position + Vector2(0, -32))
	
	bump_upwards()
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	return_to_original_position()

func bump_upwards():
	position.y -= 10

func return_to_original_position():
	position = original_position
