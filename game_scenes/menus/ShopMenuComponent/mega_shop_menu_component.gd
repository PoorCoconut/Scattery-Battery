extends CanvasLayer
class_name PrisonShopMenuComponent

@onready var scrap_currency: Label = %Scrap
@onready var ss_message: Label = %SSMessage
@onready var title_image: TextureProgressBar = %TitleImage
@onready var head_image: TextureProgressBar = %HeadImage
@onready var heart_image: TextureProgressBar = %HeartImage
@onready var thrust_image: TextureProgressBar = %ThrustImage
@onready var body_image: TextureProgressBar = %BodyImage
@onready var item_hint_message: RichTextLabel = %ItemHintMessage
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton

@export var message_dur : float = 1

@export var category_containers : Array[Control]
@export var category_names : Array[String]
@export var category_title_textures : Dictionary[String, Texture2D]
@export var category_default_textures : Dictionary[String, Texture2D]

## Maps an item_id (e.g. "head_kineticram") to its "owned" bool var name on SaveManager (e.g. "ram_mod").
## Fill this in the Inspector for every purchasable mod item.
@export var id_to_owned_key : Dictionary[String, String]

var current_index : int = 0
var current_category : String :
	get: return category_names[current_index]

var progress_bars : Dictionary
var selected_textures : Dictionary = {}   # category -> equipped item's texture
var equipped_ids : Dictionary = {}        # category -> equipped item's id
var active_tween : Tween

## Emitted whenever something is bought or its equip state changes.
signal item_purchased(id: String)
signal item_equipped(id: String)
signal item_unequipped(id: String)

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
	progress_bars = {
		"head": head_image,
		"heart": heart_image,
		"thrust": thrust_image,
		#"body": body_image,
	}
	for category in progress_bars.keys():
		var bar: TextureProgressBar = progress_bars[category]
		bar.texture_progress = category_default_textures.get(category)
		bar.value = bar.max_value

	_restore_from_save()
	_update_category_view()
	_update_currency_label()

	ss_message.visible_ratio = 0
	ss_message.text = shop_messages[randi_range(0, shop_messages.size() - 1)]
	show_shop()

## Re-applies purchased/equipped state from SaveManager onto the row nodes and bars.
## Call this after all ShopItemRowComponents are in the tree (they add_to_group in their own _ready).
func _restore_from_save() -> void:
	for category in progress_bars.keys():
		for member in get_tree().get_nodes_in_group(category):
			if not member is ShopItemRowComponent:
				continue
			var row: ShopItemRowComponent = member
			var owned_key : String = id_to_owned_key.get(row.item_id, "")
			if owned_key != "" and SaveManager.get(owned_key) == true:
				row.mark_purchased()

		var equipped_id : String = SaveManager.get("equipped_" + category)
		if equipped_id != "":
			for member in get_tree().get_nodes_in_group(category):
				if member is ShopItemRowComponent and member.item_id == equipped_id:
					_equip_item(member, equipped_id, false)  # false = don't re-emit/re-save, just visuals

func show_shop():
	var tween = get_tree().create_tween()
	tween.tween_property(ss_message, "visible_ratio", 1.0, message_dur)

func hide_shop():
	pass

func _update_currency_label() -> void:
	scrap_currency.text = str(SaveManager.scrap)

func _on_prev_button_pressed() -> void:
	current_index = wrapi(current_index - 1, 0, category_containers.size())
	_update_category_view()

func _on_next_button_pressed() -> void:
	current_index = wrapi(current_index + 1, 0, category_containers.size())
	_update_category_view()

func _update_category_view() -> void:
	if active_tween:
		active_tween.kill()

	for i in category_containers.size():
		category_containers[i].visible = (i == current_index)

	title_image.texture_progress = category_title_textures.get(current_category)
	title_image.value = 0.0
	body_image.value = 0.0

	active_tween = get_tree().create_tween().set_parallel()
	active_tween.tween_property(title_image, "value", title_image.max_value, 0.5)
	active_tween.tween_property(body_image, "value", body_image.max_value, 0.5)
	for bar in progress_bars.values():
		bar.value = 0.0
		active_tween.tween_property(bar, "value", bar.max_value, 0.5)

	item_hint_message.text = ""

func _on_shop_item_row_component_ir_button_hover(hover_img: Texture2D, title_img: Texture2D, desc: String, id: String) -> void:
	if active_tween:
		active_tween.kill()

	var category := id.split("_")[0]
	var target_bar: TextureProgressBar = progress_bars.get(category)

	title_image.value = 0.0
	title_image.texture_progress = title_img
	active_tween = get_tree().create_tween().set_parallel()
	active_tween.tween_property(title_image, "value", title_image.max_value, 0.5)

	if target_bar:
		target_bar.value = 0.0
		target_bar.texture_progress = hover_img
		active_tween.tween_property(target_bar, "value", target_bar.max_value, 0.5)

	item_hint_message.visible_ratio = 0.0
	item_hint_message.text = desc
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(item_hint_message, "visible_ratio", 1.0, 0.5)

func _on_shop_item_row_component_ir_button_unhover(id: String) -> void:
	if active_tween:
		active_tween.kill()

	var category := id.split("_")[0]
	var target_bar: TextureProgressBar = progress_bars.get(category)

	title_image.texture_progress = category_title_textures.get(current_category)
	title_image.value = 0.0
	active_tween = get_tree().create_tween().set_parallel()
	active_tween.tween_property(title_image, "value", title_image.max_value, 0.5)

	if target_bar:
		if selected_textures.has(category):
			target_bar.texture_progress = selected_textures[category]
		else:
			target_bar.texture_progress = category_default_textures.get(category)
		target_bar.value = 0.0
		active_tween.tween_property(target_bar, "value", target_bar.max_value, 0.5)

func _on_shop_item_row_component_ir_purchase_requested(row: ShopItemRowComponent, id: String, item_price: int) -> void:
	if SaveManager.scrap < item_price:
		SoundBank.play_sfx("player_hit")  # swap for whatever your "can't afford" cue is
		return
	SaveManager.scrap -= item_price
	_update_currency_label()
	row.mark_purchased()

	var owned_key : String = id_to_owned_key.get(id, "")
	if owned_key != "":
		SaveManager.set(owned_key, true)
	else:
		push_warning("No SaveManager owned-key mapped for item '%s' — purchase won't persist!" % id)

	_equip_item(row, id)
	item_purchased.emit(id)
	SaveManager.save_game_data()

func _on_shop_item_row_component_ir_equip_toggle_requested(row: ShopItemRowComponent, id: String) -> void:
	if row.is_equipped:
		_unequip_category(row.get_category())
	else:
		_equip_item(row, id)
	SaveManager.save_game_data()

func _equip_item(row: ShopItemRowComponent, id: String, notify: bool = true) -> void:
	var category := row.get_category()
	_unequip_category(category, notify)   # clear whatever was previously equipped here

	row.set_equipped(true)
	equipped_ids[category] = id
	selected_textures[category] = row.item_image_normal

	var target_bar: TextureProgressBar = progress_bars.get(category)
	if target_bar:
		target_bar.texture_progress = row.item_image_normal
		target_bar.value = target_bar.max_value

	SaveManager.set("equipped_" + category, id)

	if notify:
		item_equipped.emit(id)
		Events.mod_equipped.emit(category, id)

func _unequip_category(category: String, notify: bool = true) -> void:
	for member in get_tree().get_nodes_in_group(category):
		if member is ShopItemRowComponent and member.is_equipped:
			member.set_equipped(false)
			if notify:
				item_unequipped.emit(member.item_id)
				Events.mod_unequipped.emit(category, member.item_id)

	equipped_ids.erase(category)
	selected_textures.erase(category)
	SaveManager.set("equipped_" + category, "")

	var target_bar: TextureProgressBar = progress_bars.get(category)
	if target_bar:
		target_bar.texture_progress = category_default_textures.get(category)
		target_bar.value = target_bar.max_value


func _on_prison_button_pressed() -> void:
	GameManager.load_next_level("res://game_scenes/worlds/Arena/world_arena.tscn")
