extends Node;

# Should probably do some reading on resources.
func read_entire_file_as_string(file_name):
	var file = File.new();
	file.open(file_name, File.READ);
	return file.get_as_text();

func read_json_no_check(filepath):
	return JSON.parse(Utilities.read_entire_file_as_string(filepath)).get_result();

func write_entire_file_from_string(file_name, string):
	# lifted directly from docs
	var file = File.new();
	file.open(file_name, File.WRITE);
	file.store_string(string);
	file.close();

func dictionary_get_optional(dictionary, key, not_present=null):
	return dictionary[key] if dictionary.has(key) else not_present;

func get_file_names_of_directory(path):
	var result = [];
	var directory = Directory.new();
	# not error checking
	directory.open(path);

	directory.list_dir_begin();
	var file_name_to_append = directory.get_next();
	while len(file_name_to_append):
		if !directory.current_is_dir():
			result.push_back(file_name_to_append);
		file_name_to_append = directory.get_next();

	return result;
