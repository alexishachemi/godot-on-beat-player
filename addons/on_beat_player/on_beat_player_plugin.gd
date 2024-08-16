@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"OnBeatPlayer",
		"AudioStreamPlayer",
		preload("res://addons/on_beat_player/on_beat_player.gd"),
		preload("res://addons/on_beat_player/assets/OnBeatPlayer.png")
	)
	add_custom_type(
		"OnBeatSong",
		"Resource",
		preload("res://addons/on_beat_player/on_beat_song.gd"),
		preload("res://addons/on_beat_player/assets/OnBeatSong.png")
	)

func _exit_tree():
	remove_custom_type("OnBeatPlayer")
	remove_custom_type("OnBeatSong")
