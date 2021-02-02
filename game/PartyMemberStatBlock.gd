extends Resource;

export(int) var strength: int = 10;
export(int) var dexterity: int = 10;
export(int) var constitution: int = 10;
export(int) var willpower: int = 10;
export(int) var intelligence: int = 10;
export(int) var charisma: int = 10;
export(int) var luck: int = 10;

func _make_new_label(text):
	var new_label = Label.new();
	new_label.text = text;
	return new_label;

func get_as_labels():
	var widgets = [
		_make_new_label("Strength:	   " + str(strength)),
		_make_new_label("Dexterity:	   " + str(dexterity)),
		_make_new_label("Constitution: " + str(constitution)),
		_make_new_label("Willpower:	   " + str(willpower)),
		_make_new_label("Intelligence: " + str(intelligence)),
		_make_new_label("Charisma:	   " + str(charisma)),
		_make_new_label("Luck:		   " + str(luck))
		];
	return widgets;
