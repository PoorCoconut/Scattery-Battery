extends Node2D

@onready var in_animate: AnimationPlayer = $InAnimate

func _ready() -> void:
	in_animate.play("animate")

func _on_in_animate_animation_finished(anim_name: StringName) -> void:
	queue_free()
