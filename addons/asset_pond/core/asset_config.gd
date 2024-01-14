@tool

extends Resource
class_name AssetConfig

## Databse of assets and their metadata.

enum TREE_BUTTONS { APPLY_ALL = 1000, APPLY_ONE, DELETE_ONE, UOA_ONE, PAUSE_ONE, FOLDER_SELECT }

@export var directory : String
@export var name: String
@export var include_subfolder: bool = true
@export var extension_filter: String
@export var hidden: bool

func prepare(conf: ConfigFile) -> ConfigFile:
	conf.set_value(name, "name", name)
	conf.set_value(name, "directory", directory)
	conf.set_value(name, "include_subfolder", include_subfolder)
	conf.set_value(name, "extension_filter", extension_filter)
	conf.set_value(name, "hidden", hidden)
	return conf

func load_from(conf: ConfigFile, section: String) -> void:
	name = section
	directory = conf.get_value(section, "directory", "/")
	include_subfolder = conf.get_value(section, "include_subfolder", true)
	extension_filter = conf.get_value(section, "extension_filter", "")
	hidden = conf.get_value(section, "hidden", true)

func tree_branch(tree: Tree, root: TreeItem, tree_index: int, remove_icon: Texture2D, folder_icon: Texture2D):
	var asset_root := tree.create_item()
	asset_root.set_text(0, name)
	asset_root.set_collapsed_recursive(hidden)
	asset_root.set_meta("index", tree_index)
	asset_root.set_meta("name", name)
	asset_root.add_button(1, folder_icon, TREE_BUTTONS.FOLDER_SELECT, false, "Select A folder")	
	asset_root.add_button(1, remove_icon, TREE_BUTTONS.DELETE_ONE, false, "Delete this folder from management")
	asset_root.set_editable(0, true)
	
	var asset_directory_item = tree.create_item(asset_root)
	asset_directory_item.set_text(0, "Directory")
	asset_directory_item.set_editable(1, true)
	asset_directory_item.set_text(1, directory)
	asset_directory_item.set_text_overrun_behavior(1, TextServer.OVERRUN_TRIM_ELLIPSIS)
	if not directory or not is_valid_directory_path(directory):
		var color = Color.RED
		color.a = .4
		asset_directory_item.set_custom_bg_color(1, color)

	var include_subfolders_item = tree.create_item(asset_root)
	include_subfolders_item.set_text(0, "Inc Subfolders?")
	include_subfolders_item.set_editable(1, true)
	include_subfolders_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	include_subfolders_item.set_checked(1, include_subfolder)
	include_subfolders_item.set_meta("index", tree_index)
	
	var extension_filter_item = tree.create_item(asset_root)
	extension_filter_item.set_text(0, "Extension Filter")
	extension_filter_item.set_text(1, "jpg,jpeg,png,svg,obj,wav,mp3")
	extension_filter_item.set_editable(1, true)
	
func is_valid_directory_path(path: String) -> bool:
	var linux_pattern = "^(/[^/ ]*)+/?$"  # Regular expression for Uvar windows_pattern = "^([a-zA-Z]:)?([\\\\/][a-zA-Z0-9._-]+)+[\\\\/]?$"
	var windows_pattern = "^([a-zA-Z]:)?([\\\\/][a-zA-Z0-9._ -]+)+[\\\\/]?$"
	# Use the following pattern for Windows paths: "^([a-zA-Z]:)?(\\\\[a-zA-Z0-9._-]+)+\\\\?$"
	var reg = RegEx.new()
	reg.compile(linux_pattern)
	if reg.search(path) != null:
		return true
	reg.compile(windows_pattern)
	return reg.search(path) != null
