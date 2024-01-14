@tool
extends Resource
class_name AssetManifest

const config_file: String = "res://asset_pond.cfg"
const backup_config_file: String = "res://asset_pond.cfg.bak"

var assets: Array[AssetConfig]

func new() -> Error:
	var asset: AssetConfig = AssetConfig.new()
	asset.name = get_available_name()
	assets.append(asset)
	return save()

func clear() -> void:
	assets = []

func get_assets() -> Array[AssetConfig]:
	return assets

func build() -> ConfigFile:
	var current: ConfigFile = ConfigFile.new()
	for asset in assets:
		current = asset.prepare(current)
	return current

func save(backup: bool = false) -> Error:
	var conf_to_save: ConfigFile = build()
	var filepath: String = backup_config_file if backup else config_file
	return conf_to_save.save(filepath)

func get_available_name() -> String:
	var name: String = "New Asset"
	var output: String
	var increment: int = 0
	while get_by_name(name) != null:
		name = "New Asset %d" % [increment]
		increment += 1

	return name

func get_by_name(name: String) -> AssetConfig:
	for asset in assets:
		if asset.name == name:
			return asset
	return null

func load_from_disk(backup: bool = false) -> void:
	var filepath: String = backup_config_file if backup else config_file
	assets = load_file(filepath)
	
func load_file(file_path: String) -> Array[AssetConfig]:
	var conf: ConfigFile = ConfigFile.new()
	var err: Error = conf.load(file_path)
	if err != OK:
		push_error("Failed to load config file [%s]: %d (%s)" % [file_path, err, error_string(err)])
		return []
	
	return load_from(conf)
	
func load_from(conf: ConfigFile) -> Array[AssetConfig]:
	var assets: Array[AssetConfig] = []

	for section in conf.get_sections():
		var asset: AssetConfig = AssetConfig.new()
		asset.load_from(conf, section)
		assets.append(asset)

	return assets
