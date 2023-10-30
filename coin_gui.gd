extends CanvasLayer

func _process(delta):
	$coins.text = "Coins: " + str(Global.total_coins)
	$lives.text = "\nLives: " + str(Global.player_lives)
