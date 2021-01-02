extends NinePatchRect;

onready var item_preview_name = $ItemName;
onready var item_preview_sprite = $ItemPreviewSprite;
onready var item_preview_description = $ItemDescription;

func set_preview_name(name):
	item_preview_name.text = name;

func set_preview_description(description):
	item_preview_description.text = description;

func set_preview_sprite(sprite_texture):
	if sprite_texture:
		item_preview_sprite.texture = sprite_texture;
	else:
		item_preview_sprite.texture = load("res://images/inventory-icons/previews/preview_unknown_item.png");
		
func set_information(name, description, preview_texture):
	print("annoying reminder, use .bbcode later!!!");
	set_preview_name(name);
	set_preview_sprite(preview_texture);
	set_preview_description(description);

func set_information_based_on_item(item_name):
	set_information(ItemDatabase.get_item(item_name).name,
					ItemDatabase.get_item(item_name).description,
					ItemDatabase.get_item(item_name).inventory_preview_image);
