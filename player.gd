extends CharacterBody2D

var is_alive = true
var is_jumping = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	add_to_group("Player")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# Handle Jump.
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
	if is_jumping:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("jump")
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	elif is_alive == false:
		animated_sprite_2d.play("ded")
	else:
		animated_sprite_2d.play("idle")



func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy") and body.is_alive:
		is_alive = false
		get_tree().reload_current_scene()
