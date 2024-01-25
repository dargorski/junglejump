extends CharacterBody2D
signal life_changed
signal died
@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300

enum STATE {IDLE, RUN, JUMP, HURT, DEAD}
var state = STATE.IDLE

var life = 3: set = set_life

func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(STATE.DEAD)

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
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(STATE.IDLE)
		STATE.JUMP:
			$AnimationPlayer.play("jump_up")
		STATE.DEAD:
			died.emit()
			hide()

func get_input():
	if state == STATE.HURT:
		return
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

func hurt():
	if state != STATE.HURT:
		change_state(STATE.HURT)

func reset(_position):
	position = _position
	life = 3
	show()
	change_state(STATE.IDLE)
