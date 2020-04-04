extends Node

class_name DataStore

###
# Base class for anything that needs to store data in a dynamically accessible manner.
###

var _data = {} setget _private_set,_private_get

func _private_set(_throwaway):
	print("Do not try to manipulate the private data object.")

func _private_get():
	print("Do not try to manipulate the private data object.")

# Set a value in the data store.
func set(key, value):
	match typeof(value):
		_:
			_data[key] = value

# Get data from data store.
# If retrieving from a multidimensional dictionary, use "." to get deeper levels.
func get(key):
	# Should we add an event here to say data is being accessed?
	if key.find('.') == -1:
		return _data[key]
		
	var keys = key.split('.')
	var ret = _data
	for _key in keys:
		if not ret.has(_key):
			print("Key not found in global data: ", _key)
			return
		ret = ret[_key]
	# Should we add an event here to say data was retrieved?
	return ret

func has(key):
	# Should we add an event here to say data is being accessed?
	if key.find('.') == -1:
		return _data.has(key)
		
	var keys = key.split('.')
	var ret = _data
	for _key in keys:
		if not ret.has(_key):
			return false
		ret = ret[_key]
	# Should we add an event here to say data was retrieved?
	# If we make it here, then the data was found, so return true.
	return true