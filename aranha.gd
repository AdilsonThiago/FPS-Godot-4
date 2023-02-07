extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var alvo = null
var axys = Vector3.ZERO

func _physics_process(delta):
	if is_on_floor():
		if not alvo == null:
			axys = position.direction_to(alvo.position)
			axys.y = 0
			look_at(position + axys, Vector3.UP)
			velocity = axys
		velocity.y = 0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
	pass

func _on_area_3d_body_entered(body):
	if body.is_in_group("jogador"):
		alvo = body
	pass
