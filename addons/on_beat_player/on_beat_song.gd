@tool
class_name OnBeatSong
extends Resource

@export var name: StringName
@export var author: String
@export_range(0, 400) var bpm: int
@export var first_beat_offset_time: float
@export var stream: AudioStream

var started: bool = false
var begin_time: float
var delay_time: float
var beats: int
var last_beat_time: float
var beat_duration: float
var playback_time: float
var playback_offset: float = 0.0

func start(from_position: float = 0.0):
	started = true
	reset_beats()
	playback_offset = from_position
	playback_time = from_position

func pause():
	playback_offset = playback_time

func resume():
	reset_beats()

func reset_beats():
	begin_time = Time.get_ticks_usec()
	delay_time = AudioServer.get_time_to_next_mix() \
		+ AudioServer.get_output_latency()
	beats = 0
	last_beat_time = 0.0
	beat_duration = 0.0

func get_playback_time() -> float:
	var raw_time: float = ((Time.get_ticks_usec() - begin_time) / 1000000.0) - delay_time
	return clampf(raw_time + playback_offset, 0, INF)

func update() -> bool:
	if not started:
		start()
	playback_time = get_playback_time()
	if playback_time < first_beat_offset_time:
		return false
	playback_time -= first_beat_offset_time
	var current_beats := int(playback_time * bpm / 60.0)
	var beat := current_beats > beats
	if beat:
		beats = current_beats
		beat_duration = playback_time - last_beat_time
		last_beat_time = playback_time
	return beat

func get_time_before_beat() -> float:
	return beat_duration - (playback_time - last_beat_time)
