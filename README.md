# Godot - OnBeatPlayer

An addon for the Godot engine implementing an audio stream player with tempo-based signaling.

The addon was developped while working on a personal project and is uploaded here for future usage.

**Requires Godot 4.2+**

## Installation

To add the addon, copy the `addons` folder into the root of your project. Then, in *Project Settings*, enable the plugin like shown below

<img src="assets\enable.png" width="960"/>

## OnBeatPlayer <img src="addons\on_beat_player\assets\OnBeatPlayer.png" width="32"/>

The main node of the addon. It adds a few additional properties in the inspector.

### Inspector

<img src="assets\obp_editor.png"/>

### properties

- **current_song**: the song that is currently playing (pausing does not reset this variable)

- **default_crossfade_time**: the duration of a transition in seconds

- **pre_beat_offset**: the time before the next beat when the the *pre_beat* signal will be emitted. (i.e. if the offset is 0.1, the pre_beat signal will be called 0.1s before the next beat). This is useful when needing to do computation in preparation of the next or to play some animation in advance.

- **songs**: the songs registered to the player (see *OnBeatSong* below)

### methods

```
play(song_name: StringName, from_start: bool = true) -> bool

transition_to(song_name: StringName, crossfade_time: float = 0.0, from_start: bool = true) -> void

get_song_names() -> Array[StringName]
```

## OnBeatPlayer

### OnBeatSong <img src="addons\on_beat_player\assets\OnBeatSong.png" width="32"/>
The OnBeatSong is the resource used to provide the OnBeatPlayer with song. It contains basic identification, the data required to sync the signals to the tempo and the AudioStream itself.
    
<img src="assets\obs_editor.png"/>
    
### properties

- **name**: the name of the song

- **author**: the author of the song

- **bpm**: the tempo of the song in beats per minute

- **first_beat_offset_time**: the time between the begining of the audio stream and the first beat

- **stream**: the audio stream of the song