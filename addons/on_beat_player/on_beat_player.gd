@tool
class_name OnBeatPlayer
extends Node

class Transition:
	var crossfade_time: float
	var song: OnBeatSong
	var from_start: bool
	func _init(c: float, s: OnBeatSong, fs: bool):
		crossfade_time = c
		song = s
		from_start = fs

signal beat
signal pre_beat
signal finished(StringName)
signal transitioned(StringName)

@export var paused: bool = false : set = _set_paused
@export_range(0.1, 60) var default_crossfade_time: float = 2.0
@export_range(-80, 24) var volume_db: float = 0.0 : set = _set_volume_db
@export var pre_beat_offset: float
@export var son: OnBeatSong
@export var songs: Array[OnBeatSong]

@onready var primary_player: AudioStreamPlayer = _new_player()
var secondary_player: AudioStreamPlayer
var current_song: OnBeatSong
var transition_queue: Array[Transition]
var transitioning: bool = false
var pre_beat_flag: bool = false

func play(song_name: StringName, from_start: bool = true) -> bool:
	var new_song := _get_song(song_name)
	if not new_song:
		return false
	paused = false
	current_song = new_song
	if from_start:
		current_song.start()
	primary_player.stream = current_song.stream
	primary_player.volume_db = volume_db
	primary_player.play(current_song.playback_time)
	return true

func _set_paused(is_paused: bool):
	if is_paused == paused:
		return
	paused = is_paused
	if primary_player:
		primary_player.stream_paused = is_paused
	if current_song:
		if paused:
			current_song.pause()
		else:
			current_song.resume()

func transition_to(
	song_name: StringName,
	crossfade_time: float = 0.0,
	from_start: bool = true
) -> bool:
	var song := _get_song(song_name)
	if not song:
		return false
	crossfade_time = default_crossfade_time if crossfade_time < 0 else crossfade_time
	transition_queue.append(Transition.new(crossfade_time, song, from_start))
	return true

func _transition():
	if transitioning or transition_queue.is_empty():
		return
	transitioning = true
	var transition: Transition = transition_queue.pop_front()
	paused = false
	await beat
	current_song.pause()
	current_song = transition.song
	if transition.from_start:
		current_song.start()
	else:
		current_song.beats -= 1
		current_song.resume()
	secondary_player = primary_player
	primary_player = _new_player()
	primary_player.volume_db = -50
	primary_player.stream = current_song.stream
	primary_player.play(current_song.playback_time)
	var tween := get_tree().create_tween()
	tween.tween_property(secondary_player, "volume_db", -50, transition.crossfade_time)
	tween.parallel().tween_property(primary_player, "volume_db", volume_db, transition.crossfade_time / 2)
	tween.tween_callback(_on_transition_finished)

func _on_transition_finished():
	secondary_player.stop()
	secondary_player.queue_free()
	secondary_player = null
	transitioning = false
	transitioned.emit(current_song.name)

func _process(_delta):
	if Engine.is_editor_hint() or not current_song or paused:
		return
	if current_song.update():
		beat.emit()
		pre_beat_flag = false
	if pre_beat_offset > 0.0 and not pre_beat_flag \
		and current_song.get_time_before_beat() < pre_beat_offset:
		pre_beat_flag = true
		pre_beat.emit()
	_transition()

func _get_song(song_name: StringName) -> OnBeatSong:
	for song in songs:
		if song.name == song_name:
			return song
	return null

func _new_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.volume_db = volume_db
	player.finished.connect(_on_player_finished)
	add_child(player)
	return player

func _set_volume_db(db: float):
	volume_db = db
	if transitioning:
		primary_player.volume_db = volume_db

func _on_player_finished():
	finished.emit(current_song.name)
