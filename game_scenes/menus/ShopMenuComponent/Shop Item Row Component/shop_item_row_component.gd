extends HBoxContainer
class_name ShopItemRowComponent

@export_group("Item Icons")
@export var item_image_hover : Texture2D = preload("uid://b5ha2ebfytva7")   # legacy/reference; superseded by state textures below
@export var item_image_normal : Texture2D
@export var item_title_image : Texture2D
@export_multiline("ENTER ITEM DESCRIPTION") var item_desc : String = "DESCRIPTION"
##There are 3 categories with 3 modules. Use category_module as the item id. ex: head_kineticram
@export var item_id : String = "type_item"
@export var price : int = 0

@export_group("Locked State (Not Purchased)")
@export var locked_normal : Texture2D
@export var locked_hover : Texture2D
@export var locked_pressed : Texture2D

@export_group("Owned State (Purchased, Unequipped)")
@export var owned_normal : Texture2D
@export var owned_hover : Texture2D
@export var owned_pressed : Texture2D

@export_group("Equipped State")
@export var equipped_normal : Texture2D
@export var equipped_hover : Texture2D
@export var equipped_pressed : Texture2D

@onready var item_label: RichTextLabel = $ItemLabel
@onready var texture_button: TextureButton = $TextureButton
var itemlabel_string : String = "ITEM"

var is_purchased : bool = false
var is_equipped : bool = false

signal ir_button_hover(hover_img: Texture2D, title_img: Texture2D, desc: String, id: String)
signal ir_button_unhover(id: String)
signal ir_purchase_requested(row: ShopItemRowComponent, id: String, item_price: int)
signal ir_equip_toggle_requested(row: ShopItemRowComponent, id: String)

func _ready() -> void:
	itemlabel_string = item_label.text
	add_to_group(get_category())
	_update_button_visuals()

func get_category() -> String:
	return item_id.split("_")[0]

func _update_button_visuals() -> void:
	if is_equipped:
		texture_button.texture_normal = equipped_normal
		texture_button.texture_hover = equipped_hover
		texture_button.texture_pressed = equipped_pressed
	elif is_purchased:
		texture_button.texture_normal = owned_normal
		texture_button.texture_hover = owned_hover
		texture_button.texture_pressed = owned_pressed
	else:
		texture_button.texture_normal = locked_normal
		texture_button.texture_hover = locked_hover
		texture_button.texture_pressed = locked_pressed

func _on_texture_button_mouse_entered() -> void:
	item_label.text = "[wave amp = 2.0]" + itemlabel_string + "[/wave]"
	ir_button_hover.emit(item_image_hover, item_title_image, item_desc, item_id)

func _on_texture_button_mouse_exited() -> void:
	item_label.text = itemlabel_string
	ir_button_unhover.emit(item_id)

func _on_texture_button_pressed() -> void:
	if not is_purchased:
		ir_purchase_requested.emit(self, item_id, price)
	else:
		ir_equip_toggle_requested.emit(self, item_id)

## Called by the shop menu once a purchase succeeds.
func mark_purchased() -> void:
	is_purchased = true
	SoundBank.play_sfx("metal_hit")
	_update_button_visuals()

## Called by the shop menu to reflect equip state visually.
func set_equipped(value: bool) -> void:
	is_equipped = value
	_update_button_visuals()
