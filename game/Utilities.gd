extends Node;

# Should probably do some reading on resources.
func read_entire_file_as_string(file_name):
	var file = File.new();
	file.open(file_name, File.READ);
	return file.get_as_text();
