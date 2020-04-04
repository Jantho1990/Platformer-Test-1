extends Node

var current_screen = ''
var initial_screen = 'MainMenuScreen'
var screens_path = 'res://screens/'

func _ready():
	GlobalSignal.listen('change_screen', self, '_on_Change_screen')
	load_screen(initial_screen)

func _on_Change_screen(data):
	var screen_name = data.screen_name
	switch_screen(screen_name)

func load_screen(screen_name):
	load(screens_path + screen_name + '.tscn')

func switch_screen(screen_name):
	get_tree().change_scene(screens_path + screen_name + '.tscn')