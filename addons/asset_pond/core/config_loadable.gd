@tool
extends Control

class_name ConfigLoadable

var config: AssetManifest = AssetManifest.new()
var config_lock: Mutex = Mutex.new()

func _load_config():
	config_lock.lock()
	Logs._dminor("Loading DAM config from disk...")
	config.load_from_disk()
	if config.assets.size() == 0:
		Logs._error("No assets loaded. Config empty or load errored. Check pushed errors.", 0)
		return
	call_deferred("_build_tree")
	config_lock.unlock()

func _save_config() -> void:
	config_lock.lock()
	DDLog.info("Saving godotons config...")
	var save_err: Error = config.save()
	if save_err != OK:
		DDLog.info("Failed to save config", save_err)
		return
	call_deferred("_build_tree")
	config_lock.unlock()
