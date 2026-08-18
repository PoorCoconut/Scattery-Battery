extends CanvasLayer
class_name SectorShopMenuComponent

@onready var sector_points: Label = %SectorPoints
@onready var ss_message: Label = %SSMessage
@onready var ship_image_bar: TextureProgressBar = %ShipImageBar
@onready var item_hint_message: RichTextLabel = %ItemHintMessage

@export var message_dur : float = 1



var shop_messages : Array = [
	"Captured Again? Maybe my wares can help.",
	"Find anything useful?",
	"How far did you get this time?",
	"Hello World!",
	"Beep Boop",
	"Keep getting hit? What about shields?",
	"Back again?",
	"Have you ever tried dodging?",
	"I'm CHARGE-ing you extra. Heh Heh.",
	"Use your battery wisely!",
	"Got some scrap? Hit me up!"
	]

func _ready() -> void:
	ss_message.visible_ratio = 0
	ss_message.text = shop_messages[randi_range(0, shop_messages.size()-1)]
	show_shop()

func show_shop():
	#Events.change_melody.emit("shop")
	var tween = get_tree().create_tween()
	tween.tween_property(ss_message, "visible_ratio", 1.0, message_dur)

func hide_shop():
	pass

func _on_shop_item_row_component_ir_button_hover(img: Texture2D, desc: String) -> void:
	ship_image_bar.value = 0.0
	ship_image_bar.texture_progress = img
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(ship_image_bar, "value", ship_image_bar.max_value, 0.5)
	
	item_hint_message.visible_ratio = 0.0
	item_hint_message.text = desc
	var tween2 : Tween = get_tree().create_tween()
	tween2.tween_property(item_hint_message, "visible_ratio", 1.0, 0.5)
		  
func _on_shop_item_row_component_ir_button_pressed(id: String) -> void:
	match id:
		"wpn_novabeam":
			print("Bought the NOVABEAM")
