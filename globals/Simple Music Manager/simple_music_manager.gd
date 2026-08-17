extends Node
@onready var base: AudioStreamPlayer = $Base

#const STREAM_DRUMS = 2
#const STREAM_MELODY_BOSS = 3
#const STREAM_MELODY_NORM = 4
#const STREAM_MELODY_SHOP = 5
#
#var sync_stream: AudioStreamSynchronized
#
#var drum_tween: Tween
#var melody_tween: Tween
#
#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#
	#Events.change_melody.connect(handle_melody)
	#Events.do_drums.connect(handle_drums)
	#
	#sync_stream = base.stream as AudioStreamSynchronized
	#
	#for idx in [STREAM_DRUMS, STREAM_MELODY_BOSS, STREAM_MELODY_NORM, STREAM_MELODY_SHOP]:
		#sync_stream.set_sync_stream_volume(idx, -60.0)
	#
	#base.play()
#
#func handle_drums(enable: bool) -> void:
	#if drum_tween and drum_tween.is_valid():
		#drum_tween.kill()
	#
	#var target = -5.0 if enable else -60.0
	#var current = sync_stream.get_sync_stream_volume(STREAM_DRUMS)
	#
	#drum_tween = get_tree().create_tween()
	#drum_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	#drum_tween.tween_method(_set_drum_volume, current, target, 1.0)
#
#func _set_drum_volume(db: float) -> void:
	#sync_stream.set_sync_stream_volume(STREAM_DRUMS, db)
#
#func handle_melody(type: String) -> void:
	##print("CHANGING MELODY TO: " + type)
	#
	#if melody_tween and melody_tween.is_valid():
		#melody_tween.kill()
	#
	#var targets = {
		#STREAM_MELODY_BOSS: -60.0,
		#STREAM_MELODY_NORM: -60.0,
		#STREAM_MELODY_SHOP: -60.0,
	#}
	#if type == "boss":
		#targets[STREAM_MELODY_BOSS] = -5.0
	#elif type == "norm":
		#targets[STREAM_MELODY_NORM] = -5.0
	#elif type == "shop":
		#targets[STREAM_MELODY_SHOP] = -5.0
	#
	#melody_tween = get_tree().create_tween()
	#melody_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	#melody_tween.set_parallel(true)
	#
	#for idx in targets:
		#var current = sync_stream.get_sync_stream_volume(idx)
		#var target = targets[idx]
		#var duration = 1.0 if target == -5.0 else 2.0
		#melody_tween.tween_method(_set_melody_volume.bind(idx), current, target, duration)
#
#func _set_melody_volume(db: float, idx: int) -> void:
	#sync_stream.set_sync_stream_volume(idx, db)
