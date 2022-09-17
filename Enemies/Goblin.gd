extends KinematicBody2D


export(int) var BASE_SPEED = 300
export(int) var movement_range = 500

var velocity = Vector2.ZERO
var direction = 1

export(int) var HEALTH = 6
export(int) var JUMP_HEIGHT_INDICATOR  = 6
export(float) var JUMP_TIME_TO_PEAK
export(float) var JUMP_TIME_TO_DESCENT

var JUMP_HEIGHT: float = JUMP_HEIGHT_INDICATOR * (258/6)

onready var JUMP_VELOCITY: float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * -1.0
onready var JUMP_GRAVITY: float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK)) * -1.0
onready var FALL_GRAVITY: float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT)) * -1.0

func _physics_process(delta: float) -> void:
	apply_fall_gravity(delta)
	
	velocity = Vector2(direction, 0) * BASE_SPEED
	velocity = move_and_slide(velocity)
	
func apply_fall_gravity(delta: float) -> void:
	velocity.y += get_gravity() * delta

func get_gravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
