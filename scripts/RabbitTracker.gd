extends Node

var rabbits_alive = 0
var rabbits_captured = 0
var rabbits_dead = 0

var all_rabbits_added = false # While false, will not keep track of whether all rabbits are captured or dead.

func add_rabbit():
	rabbits_alive += 1
	GlobalSignal.dispatch("rabbit_added", { "alive": rabbits_alive, "captured": rabbits_captured, "dead": rabbits_dead })

func kill_rabbit():
	rabbits_alive -= 1
	rabbits_dead += 1
	GlobalSignal.dispatch("rabbit_died", { "alive": rabbits_alive, "captured": rabbits_captured, "dead": rabbits_dead })

func capture_rabbit():
	rabbits_alive -= 1
	rabbits_captured += 1
	GlobalSignal.dispatch("rabbit_captured", { "alive": rabbits_alive, "captured": rabbits_captured, "dead": rabbits_dead })

func set_rabbits(prop = null, value = 0):
	match prop:
		'rabbits_alive':
			rabbits_alive = value
		'rabbits_captured':
			rabbits_captured = value
		'rabbits_dead':
			rabbits_dead = value
		_:
			rabbits_alive = value
			rabbits_captured = value
			rabbits_dead = value
	GlobalSignal.dispatch("rabbits_set", {
		'prop': prop,
		"value": value,
		"alive": rabbits_alive,
		"captured": rabbits_captured,
		"dead": rabbits_dead
	})

func reset(prop = null):
	match prop:
		'rabbits_alive':
			rabbits_alive = 0
		'rabbits_captured':
			rabbits_captured = 0
		'rabbits_dead':
			rabbits_dead = 0
		_:
			rabbits_alive = 0
			rabbits_captured = 0
			rabbits_dead = 0
	GlobalSignal.dispatch("rabbits_reset")