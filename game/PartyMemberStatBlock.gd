var strength: int;
var dexterity: int;
var constitution: int;
var willpower: int;
var intelligence: int;
var charisma: int;
var luck: int;

func _init():
	self.dexterity = 10;
	self.constitution = 10;
	self.willpower = 10;
	self.intelligence = 10;
	self.charisma = 10;
	self.luck = 10;

func duplicate():
	var dup = get_script().new();
	dup.strength = self.strength;
	dup.dexterity = self.dexterity;
	dup.constitution = self.constitution;
	dup.willpower = self.willpower;
	dup.intelligence = self.intelligence;
	dup.charisma = self.charisma;
	dup.luck = self.luck;
	return dup;

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
