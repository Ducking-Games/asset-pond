@tool
extends EditorPlugin

const dam_editor_scene = preload("res://addons/duck_asset_manager/editor/dam_editor.tscn")
const dam_dock_scene = preload("res://addons/duck_asset_manager/editor/dam_dock.tscn")

var _dam_editor : Control
var _dam_dock : Control

func _enter_tree():
	if Engine.is_editor_hint():		
		_dam_editor = dam_editor_scene.instantiate()
		_dam_editor.name = "DAM"
		
		_dam_dock = dam_dock_scene.instantiate()
		add_control_to_dock(DOCK_SLOT_LEFT_BR, _dam_dock)
		#_dam_editor.set_editor_plugin(self)
		get_editor_interface().get_editor_main_screen().add_child(_dam_editor)
		_make_visible(false)
	#add_autoload_singleton(singleton_name, "")	


func _exit_tree():
	if _dam_editor:
		_dam_editor.queue_free()
	#remove_autoload_singleton(singleton_name)

func _get_plugin_name():
	return "DAM"

func _has_main_screen():
	return true

func _make_visible(visible):
	if _dam_editor:
		print(visible)
		_dam_editor.visible = visible

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

#func _build() -> bool:
	## Ignore errors in other files if we are just running the test scene
	#if InventorySettings.get_user_value("is_running_test_scene", true): return true
	#
	#var can_build: bool = true
	#var is_first_file: bool = true
	#for database_file in database_file_cache.values():
		#if database_file.errors.size() > 0:
			## Open the first file
			#if is_first_file:
				#get_editor_interface().edit_resource(load(database_file.path))
##				_inventory_editor.show_build_error_dialog()
				#is_first_file = false
			#push_error("You have %d error(s) in %s" % [database_file.errors.size(), database_file.path])
			#can_build = false
	#return can_build
