extends DataStore

class_name UserStore

###
# Any data stored here will be saved to a user's local storage.
# It will also retrieve any locally-stored data on game load.
###

signal data_updated
signal data_loaded

var save_file_path = 'user://rabbit-trails/save-file.json' setget _private_set,_private_get

func _private_set(__throwaway__):
	print('Private property.')

func _private_get():
	print('Private property.')

func __init():
	get_data_from_file()
	connect('data_updated', self, '_on_Data_updated')

func set(key, value):
	.set(key, value)
	emit_signal('data_updated', { 'key': key, 'value': value })

func _on_Data_updated(added_data):
	save_data_to_file()

func save_data_to_file():
	var save_file = File.new()
	save_file.open(save_file_path, File.WRITE)
	save_file.store_line(to_json(_data))
	save_file.close()

func get_data_from_file():
	var save_file = File.new()
	if not save_file.file_exists(save_file_path): # No save file created yet.
		return
	
	save_file.open(save_file_path, File.READ)
	var saved_data = parse_json(save_file.get_line())
	save_file.close()
	_data = saved_data
	emit_signal('data_updated')