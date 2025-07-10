extends KinematicBody2D
class_name EnemyBase

export var speed = 64
export var health = 3
var motion = Vector2.ZERO
var gravity = 1200
var hitted = false
var move_direction = -1
onready var ray_wall = $ray_wall
onready var anim = $anim
onready var texture = $texture

func _ready():
	if not ray_wall:
		push_error("Erro: Nó 'ray_wall' não encontrado no inimigo " + name)
	else:
		print("Nó 'ray_wall' encontrado no inimigo ", name)

func _physics_process(delta: float) -> void:
	if not ray_wall:
		push_error("ray_wall é null no inimigo: " + name)
		return
	
	apply_gravity(delta)
	motion.x = speed * move_direction
	
	if move_direction == 1:
		texture.flip_h = true
	else:
		texture.flip_h = false
	
	_set_animation()
	
	motion = move_and_slide(motion)

func apply_gravity(delta):
	motion.y += gravity * delta

func _on_anim_animation_finished(anim_name: String) -> void:
	if anim_name == "idle":
		if ray_wall:
			ray_wall.scale.x *= -1
			move_direction *= -1
			anim.play("run")
		else:
			push_error("ray_wall é null ao tentar mudar direção no inimigo: " + name)

func _set_animation():
	var anim_name = "run"
	
	if ray_wall and ray_wall.is_colliding():
		anim_name = "idle"
	elif motion.x != 0:
		anim_name = "run"
	
	if hitted:
		anim_name = "hit"
	
	if anim.assigned_animation != anim_name:
		anim.play(anim_name)

func _on_hitbox_body_entered(body: Node) -> void:
	hitted = true
	health -= 1
	body.velocity.y = body.jump_force / 2
	yield(get_tree().create_timer(0.2), "timeout")
	hitted = false
	if health < 1:
		queue_free()
		var hitbox_collision = get_node("hitbox/collision")
		if hitbox_collision:
			hitbox_collision.set_deferred("disabled", true)
		else:
			push_error("Nó 'hitbox/collision' não encontrado no inimigo: " + name)
