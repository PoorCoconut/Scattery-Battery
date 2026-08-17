extends HBoxContainer

@export var ship_image : Texture2D = preload("uid://b5ha2ebfytva7")
@export_multiline("ENTER ITEM DESCRIPTION") var item_desc : String = "DESCRIPTION"
##3 types: wpn, engi, hull
@export var item_id : String = "type_item"

@onready var item_label: RichTextLabel = $ItemLabel
@onready var texture_button: TextureButton = $TextureButton
var itemlabel_string : String = "ITEM"
signal ir_button_hover(img : CompressedTexture2D, desc : String)
signal ir_button_pressed(id : String)

func _ready() -> void:
	itemlabel_string = item_label.text

func _on_texture_button_mouse_entered() -> void:
	item_label.text = "[wave amp=1.0]" + itemlabel_string + "[/wave]"
	ir_button_hover.emit(ship_image, item_desc)

func _on_texture_button_mouse_exited() -> void:
	item_label.text = itemlabel_string

func _on_texture_button_pressed() -> void:
	SoundBank.play_sfx("ui_buy")
	texture_button.disabled = true
	ir_button_pressed.emit(item_id)
