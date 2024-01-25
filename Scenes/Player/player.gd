extends CharacterBody2D
@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300

enum STATE {IDLE, RUN, JUMP, HURT, DEAD}
var state = STATE.IDLE

func _ready():
	change_state(STATE.IDLE)
	
func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	move_and_slide()
	
	if state == STATE.JUMP and is_on_floor():
		change_state(STATE.IDLE)
	if state == STATE.JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
	
func change_state(new_state: STATE):
	state = new_state
	match state:
		STATE.IDLE:
			$AnimationPlayer.play("idle")
		STATE.RUN:
			$AnimationPlayer.play("run")
		STATE.HURT:
			$AnimationPlayer.play("hurt")
		STATE.JUMP:
			$AnimationPlayer.play("jump_up")
		STATE.DEAD:
			hide()

func get_input():
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	
	if jump and is_on_floor():
		change_state(STATE.JUMP)
		velocity.y = jump_speed
		
	if state == STATE.IDLE and velocity.x != 0:
		change_state(STATE.RUN)
	if state == STATE.RUN and velocity.x == 0:
		change_state(STATE.IDLE)
	if state in [STATE.IDLE, STATE.RUN] and !is_on_floor():
		change_state(STATE.JUMP)

func reset(_position):
	position = _position
	show()
	change_state(STATE.IDLE)
