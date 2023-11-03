extends Node

var total_coins = 0
var player_lives = 3
enum PlayerState { SMALL, BIG, FLIP_FLOP}
var current_state = PlayerState.SMALL

func spawn_beer_bottle(pos):
	var BeerBottleScene = preload("res://beer.tscn")
	var beer_bottle = BeerBottleScene.instantiate()
	beer_bottle.global_position = pos
	get_tree().root.add_child(beer_bottle)

func spawn_flip_flop_power_up(pos):
	var FlipFlopPowerUpScene = preload("res://flip_flop_power_up.tscn")
	var flip_flop_power_up = FlipFlopPowerUpScene.instantiate()
	flip_flop_power_up.global_position = pos
	get_tree().root.add_child(flip_flop_power_up)
