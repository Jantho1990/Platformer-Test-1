extends Node2D

###
# Exported Properties
###

# Whether we should modify the parent directly or just process to get the results.
# This way, we allow simple default usage by just adding the module, while still
# allowing for custom implementation from the parent.
export(bool) var modify_parent = true

export(float) var min_speed = 0.0
export(float) var max_speed = 100.0
export(float) var acceleration = 2.0
export(Vector2) var direction = Vector2(0, 0)


###
# Properties
###

# The direction of movement for this unit.
var motion = Vector2(0, 0)

onready var Parent = get_parent()

func _physics_process(delta):
    position = Parent.position

    if modify_parent:
        process_result_modify_parent()
    else:
        process_result()

func process_result_modify_parent():
    pass

func process_result():
    pass

func move_left():
	motion.x = max(motion.x - acceleration, -max_speed)
	direction.x = -1

func move_right():
	motion.x = min(motion.x + acceleration, max_speed)
	direction.x = 1