@tool
extends ConfigLoadable

@onready var remove_icon: Texture2D = preload("res://addons/asset_pond/remove.png")
@onready var folder_icon: Texture2D = preload("res://addons/asset_pond/folder.png")
@onready var tree : Tree = $VBoxContainer/Tree
@onready var add = $VBoxContainer/HBoxContainer/Add

var file_explorer: EditorFileDialog
var active_asset_id: int
# Called when the node enters the scene tree for the first time.
func _ready():
	_load_config()
	
	file_explorer = EditorFileDialog.new()
	file_explorer.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	file_explorer.dir_selected.connect(_tree_edited)
	file_explorer.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_explorer.size = Vector2(1980, 1024)
	add_child(file_explorer)
	tree.item_edited.connect(_tree_edited)
	tree.button_clicked.connect(_tree_clicked)
	tree.item_collapsed.connect(_tree_collapsed)

func clear() -> void:
	config.clear()
	call_deferred("_build_tree")

func new_asset() -> void:
		config.new()
		call_deferred("_build_tree")

func _build_tree() -> void:
	tree.clear()
	var root:= tree.create_item()
	root.set_text(0, "Asset Folders")
	var tree_index: int = 0
	
	for asset in config.assets:
		var asset_root: TreeItem = asset.tree_branch(tree, root, tree_index, remove_icon, folder_icon)
		tree_index += 1

func _tree_edited(path: String = "") -> void:
	var root_item: Array[TreeItem] = tree.get_root().get_children()
	var assets: Array[AssetConfig]
	for i in range(root_item.size()):
		var item = root_item[i]
		var asset: AssetConfig = AssetConfig.new()
		asset.name = item.get_text(0).replace(" ", "_").replace("'", "_")
		asset.hidden = item.collapsed
		for child in item.get_children():
			var child_label: String = child.get_text(0)
			match child_label:
				"Directory":
					asset.directory = child.get_text(1)
					if path and active_asset_id == i:
						asset.directory = path
				"Inc Subfolders?":
					asset.include_subfolder = child.is_checked(1)
				"Extension Filter":
					asset.extension_filter = child.get_text(1)
		assets.append(asset)
	config.assets = assets
	_save_config()
	call_deferred("_build_tree")
	
func _tree_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int):
	DDLog.info("ActionID: %d" %id)
	var idx: int = item.get_meta("index", -1) as int
	if idx == -1:
		push_error("Index %d is out of bounds, max: %d" % [idx, config.assets.size()])
		DDLog.error("Index %d is out of bounds, max: %d" % [idx, config.assets.size()], ERR_DOES_NOT_EXIST)
		return

	match id:
		AssetConfig.TREE_BUTTONS.FOLDER_SELECT:
			for child in item.get_children():
				var child_label: String = child.get_text(0)
				match child_label:
					"Directory":
						file_explorer.current_dir = child.get_text(1)
			print(idx)
			active_asset_id = idx
			file_explorer.visible = true
		AssetConfig.TREE_BUTTONS.DELETE_ONE:
			var asset: AssetConfig = config.assets[idx]
			DDLog.info("Removing %s from configuration" % [ asset.name ])
			config.assets.remove_at(idx)
			_save_config()

func _tree_collapsed(item: TreeItem) -> void:
	var item_name: String = item.get_meta("name", "")
	var item_index: int = item.get_meta("index", -1)
	if item_name == "" or item_index == -1:
		return
	var asset: AssetConfig = config.assets[item_index]
	print(asset.hidden)
	asset.hidden = item.collapsed
	_save_config()

func ls(target: String):
	var dir = DirAccess.open(target)
	if dir:
		pass
	else:
		print("ERROR")

func get_dir(root):
	var dir = DirAccess.open("C:/Users/Josh/")

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name:
			if dir.current_is_dir():
				var new_item = tree.create_item(root)
				new_item.set_text(0, file_name)
			else:
				var new_item = tree.create_item(root)
				new_item.set_text(0, file_name)
			file_name = dir.get_next()
	else:
		print("Error")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
