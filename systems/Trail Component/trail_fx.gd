extends Line2D
class_name Trail

var queue : Array
var target : Node2D
@export var MAX_LENGTH : int = 5
@export var TELEPORT_THRESHOLD : float = 100.0

func _ready() -> void:
	target = get_parent()

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		var pos = target.global_position
		if queue.size() > 0 and pos.distance_to(queue[0]) > TELEPORT_THRESHOLD:
			queue.clear()
			clear_points()
			
		queue.push_front(pos)
		
		if queue.size() > MAX_LENGTH:
			queue.pop_back()
	else:
		if queue.size() > 0:
			queue.pop_back() 
		else:
			queue_free()
			return
			
	clear_points()
	for point in queue:
		add_point(point)

func _get_position():
	return get_parent().global_position
