extends Resource;

export(int) var strength = 10;
export(int) var dexterity = 10;
export(int) var constitution = 10;
export(int) var willpower = 10;
export(int) var intelligence = 10;
export(int) var charisma = 10;
export(int) var luck = 10;

#func duplicate():
#	var dup = get_script().new();
#	dup.strength = self.strength;
#	dup.dexterity = self.dexterity;
#	dup.constitution = self.constitution;
#	dup.willpower = self.willpower;
#	dup.intelligence = self.intelligence;
#	dup.charisma = self.charisma;
#	dup.luck = self.luck;
#	return dup;

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
