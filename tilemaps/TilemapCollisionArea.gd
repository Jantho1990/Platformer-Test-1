extends Area2D

# Hard dependency on being a child of a tilemap that generates a container for collision areas
onready var tile_map = get_parent().get_parent()

class_name TilemapCollisionArea

var tile_color = Color(1, 1, 0, 0.25)

func _physics_process(delta):
	update()

func _draw():
	if 'show_collision_areas' in tile_map and tile_map.show_collision_areas:
		draw_rect(Rect2(Vector2(-32, -32), Vector2(64, 64)), tile_color, true)