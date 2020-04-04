extends KinematicBody2D

###
# CONSTANTS
###
const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = -550
const JUMP_FORGIVENESS = 0.08
const PATROL_RADIUS = {
	"maximum": 200,
	"minimum": 50
}
const SIGHT_RANGE = 100
const JUMP_THRESHOLD_RANGE = (SIGHT_RANGE / 2) + 10
const ATTACK_RANGE = 40
const MELEE_RANGE = 50
const MELEE_DAMAGE = 20

###
# CONFIGURABLE PROPERTIES
###

# Walk speed.
export(float) var walk_speed = 100.00

###
# PROPERTIES
###

# The direction
var direction = Vector2(1, 0)

var motion = Vector2(0, 0)

var patrol_points = []
var num_patrol_points = 2

# Don't check patrol points while active.
var check_patrol = false
var check_patrol_timer = Timer.new()

# Jumping
var is_jumping = false

# Attack cooldown.
var attack_cooldown_timer = Timer.new()
var can_attack = true

var sight_points
var sight_target

###
# ONREADY PROPERTIES
###

onready var state = $State

###
# METHODS
###

# Called when the node enters the scene tree for the first time.
func _ready():
	$MovementHandler.set_defaults({
		"down": funcref(self, "move_down"),
		"idle": funcref(self, "move_idle"),
		"left": funcref(self, "move_left"),
		"right": funcref(self, "move_right"),
		"up": funcref(self, "move_up")
	})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	motion.y += GRAVITY
	
	if state.current == "jump" and is_on_floor():
		is_jumping = false
		state.pop()
	
	if attack_cooldown_timer.is_stopped():
		can_attack = true
	
	look()
	
	match state.current:
		"idle":
			state_idle()
		"patrol":
			state_patrol()
		"jump":
			state_jump()
		"pursue":
			state_pursue()
		"attack":
			state_attack()
		_:
#			print("No state defined.")
			pass
	
	motion = move_and_slide(motion, UP)

###
# MOVEMENT METHODS
###

func move_down():
	pass
	
func move_idle():
	pass

func move_left():
	motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
	$Sprites.scale.x = 1
	direction.x = -1
#	playAnim('run', -1, 1.6)

func move_right():
	motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
	$Sprites.scale.x = -1
	direction.x = 1
#	playAnim('run', -1, 1.6)

func move_up():
#	motion.y = JUMP_HEIGHT
#	jump()
	pass

###
# STATE METHODS
###

func state_idle():
	motion.x = 0
	$Sprites/AnimationPlayer.play("idle")
	if math.randOneIn(100):
		state.swap("patrol")

func state_patrol():
	$Sprites/AnimationPlayer.play("walk")
	
	if patrol_points.size() == 0:
		set_new_patrol()
	
	face_patrol_point()
	
	# Reenable patrol check if timer is finished
	if not check_patrol and check_patrol_timer.is_stopped():
		enable_patrol_check()
		
#	print(patrol_points)
	if at_patrol_point():
#		print("Am I beyond patrol point? ", patrol_points[0], " ", at_patrol_point(), " ", position.x)
		advance_to_next_patrol_point()
#		face_patrol_point()
		disable_patrol_check() # Ensure entity doesn't get stuck at patrol point
		if math.randOneIn(5):
			print("IDLE")
			state.swap("idle")
	
	move()

func state_jump():
#	$Sprites/AnimationPlayer.play("jump")
	$Sprites/AnimationPlayer.play("walk")
	jump()
	move()

func state_pursue():
	$Sprites/AnimationPlayer.play("run")
	attack_move()

func state_attack():
	$Sprites/AnimationPlayer.play("attack")

###
# OTHER METHODS
###

# Attempt to attack
func attack_melee():
	print("MELEE ATTACK ATTEMPT")
	if abs((sight_target.position - position).x) <= MELEE_RANGE:
		apply_hit(sight_target)

# Hit target
func apply_hit(target):
	print("MELEE HIT")
	if target.has_method("hit"):
		target.hit(MELEE_DAMAGE, self)

# Attack speed
func attack_move():
	move()
	motion.x += 50 * sign(motion.x)
	if can_attack and abs((sight_target.position - position).x) <= ATTACK_RANGE:
		state.swap("attack")
	else:
		state.pop()

# Calm down
func stop_attack():
	state.pop() # Remove attack state and return to a lower state.
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.start(1)
	add_child(attack_cooldown_timer)
	can_attack = false

# Look at what's ahead.
func look():
	sight_points = get_sight_points()
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, sight_points.ahead, [self], collision_mask)
	
	if result:
#		print("LOOKING AT ", result)
		sight_target = result.collider
		if result.collider.get_class() == "TileMap":
			if (position - result.position).x <= JUMP_THRESHOLD_RANGE and state.current != "jump":
				state.push("jump")
		elif result.collider.name == "Player" and state.current != "attack":
			state.add("pursue")
	elif state.current == "pursue":
		state.pop()

# The point at farthest looking range.
func get_sight_points():
	return {
		"ahead": position + (Vector2(SIGHT_RANGE, 0) * direction),
		"above": position + (Vector2(JUMP_THRESHOLD_RANGE, 0) * direction) + Vector2(0, JUMP_HEIGHT)
	}

# Jump
func jump():
	if not is_jumping:
		is_jumping = true
		motion.y = JUMP_HEIGHT
		

# Initiate movement.
func move():
	match int(direction.x):
		-1:
			$MovementHandler.move("left")
		1:
			$MovementHandler.move("right")
		_:
			print("No direction ", direction)
			print(typeof(direction.x))

# Cycle to the next patrol point in sequence.
func advance_to_next_patrol_point():
	if patrol_points.size() > 1:
		var previous_point = patrol_points[0]
		patrol_points.pop_front()
		patrol_points.push_back(previous_point)

# Get direction of current patrol point.
func angle_to_patrol_point():
	return get_angle_to(patrol_points[0])

# Face direction of current patrol point.
func face_patrol_point():
	var rad = PI / 2
	var angle = get_angle_to(patrol_points[0])
	
	# Direction x
#	print(angle)
	if abs(angle) >= rad: # If true it means target to the left.
		direction.x = -1
	else: # Means target is to the right.
		direction.x = 1

# Check if at the patrol point.
func at_patrol_point():
	if not check_patrol:
		return false
	
	var point = patrol_points[0]
	var beyond_patrol_point = (abs(position.x - point.x) < 5)
#		match int(sign(point.x)):
#			-1: # left
#				beyond_patrol_point = (position.x <= point.x)
#			1:  # right
#				beyond_patrol_point = (position.x >= point.x)
	if beyond_patrol_point:
		return true
	return false

func disable_patrol_check():
	check_patrol_timer = Timer.new()
	check_patrol_timer.one_shot = true
	check_patrol_timer.start(0.25)
	add_child(check_patrol_timer)
	check_patrol = false

func enable_patrol_check():
	check_patrol = true
	remove_child(check_patrol_timer)

# Get a random patrol radius.
func random_patrol_radius():
	return math.rand(PATROL_RADIUS.minimum, PATROL_RADIUS.maximum)

# Create a new set of patrol points.
func make_patrol_points():
	var new_patrol_points = []
	for i in range(num_patrol_points):
		var valid
		while not valid:
			valid = true
			var radius = random_patrol_radius()
			var point = Vector2(
				position.x + math.randOneFrom([radius, -radius]),
				position.y
			)
			for new_patrol_point in new_patrol_points:
				if point == new_patrol_point:
					# Can't have two identical patrol points, break
					valid = false
					break
				if point.distance_to(new_patrol_point) < 20:
					valid = false
					break
			if valid:
				new_patrol_points.push_back(point)
		
	return new_patrol_points

func set_new_patrol():
	patrol_points = make_patrol_points()
	print(patrol_points, " ", position)