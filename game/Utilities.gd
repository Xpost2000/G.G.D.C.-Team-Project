extends Node;

# Should probably do some reading on resources.
func read_entire_file_as_string(file_name):
	var file = File.new();
	file.open(file_name, File.READ);
	return file.get_as_text();

func read_json_no_check(filepath):
	return JSON.parse(Utilities.read_entire_file_as_string(filepath)).get_result();

func dictionary_get_optional(dictionary, key, not_present=null):
	return dictionary[key] if dictionary.has(key) else not_present;
