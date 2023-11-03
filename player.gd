extends CharacterBody2D

var is_firing = false
var can_fire = false
var is_alive = true
var is_jumping = false
var is_big = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var player_direction = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var firing_timer = $Firing_Timer

func _ready():
	add_to_group("Player")
	death_timer.connect("timeout", Callable(self, "_on_DeathTimer_timeout"))
	firing_timer.connect("timeout", Callable(self, "_on_FiringTimer_timeout"))

func _physics_process(delta):
	if is_alive == false:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		
	if Global.current_state == Global.PlayerState.FLIP_FLOP and Input.is_action_just_pressed("fire"):
		fire()
	# Handle Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	update_animation(direction)
	move_and_slide()
func update_animation(direction):
	if is_firing or is_alive == false:
		return
	
	match Global.current_state:
		Global.PlayerState.SMALL, Global.PlayerState.BIG:
			if is_jumping:
				animated_sprite_2d.flip_h = (direction < 0)
				animated_sprite_2d.play("jump")
			elif direction != 0:
				animated_sprite_2d.flip_h = (direction < 0)
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("idle")
		Global.PlayerState.FLIP_FLOP:
			if is_jumping:
				animated_sprite_2d.flip_h = (direction < 0)
				animated_sprite_2d.play("fire_jump")
			elif direction != 0:
				animated_sprite_2d.flip_h = (direction < 0)
				animated_sprite_2d.play("fire_run")
			else:
				animated_sprite_2d.play("fire_idle")



func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy") and body.is_alive:
		match Global.current_state:
			Global.PlayerState.SMALL:
				die()
			Global.PlayerState.BIG:
				Global.current_state = Global.PlayerState.SMALL
			Global.PlayerState.FLIP_FLOP:
				Global.current_state = Global.PlayerState.BIG
func die():
	if is_alive == false:
		return
	is_alive = false
	animated_sprite_2d.play("ded")
	await death_bounce()
	Global.player_lives -= 1
	if Global.player_lives > 0:
		print("reloading world...")
		get_tree().reload_current_scene()
		is_alive = true
	else:
		get_tree().change_scene_to_file("res://gameover.tscn")
func death_bounce():
	var start_position = position
	var up_position = start_position + Vector2(0,-100)
	var down_position = start_position + Vector2(0,70)
	while position.y > up_position.y:
		position.y -= 4
		await get_tree().create_timer(0.001).timeout
	while position.y < down_position.y:
		position.y += 4
		await get_tree().create_timer(0.001).timeout
func death_timer_activate():
	get_tree().reload_current_scene()
	
func become_big():
	Global.current_state = Global.PlayerState.BIG
	self.scale = Vector2(1.5,1.5)
func become_small():
	Global.current_state = Global.PlayerState.SMALL
	self.scale = Vector2(1,1)
func power_up():
	Global.current_state = Global.PlayerState.FLIP_FLOP

func fire():
	is_firing = true
	var flip_flop = preload("res://flip_flop.tscn").instantiate()
	flip_flop.global_position = Vector2(self.global_position.x, self.global_position.y - 24)
	
	flip_flop.set("velocity", Vector2(500*player_direction, 0))
	get_parent().add_child(flip_flop)
	$AnimatedSprite2D.play("fire")
	firing_timer.start(0.5)
