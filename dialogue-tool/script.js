/*
  TODO(jerry): Make name not something you can enter on dialogue choices and next scene, rather
  have them selectable from a list of nodes.
*/

// delete_dom_element_with_confirmation element things
function delete_dom_element_with_confirmation(element) {
    if (confirm("Are you sure you want to delete this scene?")) {
        element.remove();
    }
}

function remove_all_children_of(element, selector_filter="*") {
    console.log(element);
    element.querySelectorAll(selector_filter).forEach(
        function(node) {
            node.remove();
        });
}

// This is where I regret not using react or something
function construct_input_field(type, name, class_type, start_value="") {
    var input_field = document.createElement("input");

    input_field.setAttribute("type", type);
    input_field.setAttribute("name", name);
    input_field.setAttribute("class", class_type);
    input_field.setAttribute("value", start_value);

    return input_field;
}

// There is no god I should've surrendered to the framework gods.
// maybe I should've googled whether there was a better way to construct the DOM tree.
function construct_new_dialogue_choice_dom(text, next) {
    var dialogue_choice_div = document.createElement("div");
    dialogue_choice_div.setAttribute("class", "dialogue-scene-choice");
    {
        var label = document.createElement("label").appendChild(document.createTextNode("Text Content of Choice: "));
        dialogue_choice_div.appendChild(label);
        var input_field = construct_input_field("name", "choice-content", "choice-content");
        input_field.value = text;
        dialogue_choice_div.appendChild(input_field);
    } dialogue_choice_div.appendChild(document.createElement("br"));
    {
        var label = document.createElement("label").appendChild(document.createTextNode("Next Branch (EMPTY FOR END)"));
        dialogue_choice_div.appendChild(label);
        var input_field = construct_input_field("name", "next-node", "next-node");
        input_field.value = next;
        dialogue_choice_div.appendChild(input_field);
    } dialogue_choice_div.appendChild(document.createElement("br"));
    dialogue_choice_div.appendChild(document.createElement("br"));
    {
        var button = document.createElement("button");
        button.setAttribute("onclick", "delete_dom_element_with_confirmation(parentNode)");
        button.appendChild(document.createTextNode("Remove this choice."));

        dialogue_choice_div.appendChild(button);
    }

    return dialogue_choice_div;
}

function build_new_choice_dom_tree(root, text="???", next="") {
    root.appendChild(construct_new_dialogue_choice_dom(text, next));
}

let gensym_counter = 0;

function construct_dialogue_choices_toolbar() {
    var toolbar = document.createElement("span");
    toolbar.setAttribute("class", "toolbar");

    {
        var add_new_choice_button = document.createElement("button");
        add_new_choice_button.appendChild(document.createTextNode("Add New Choice"));
        add_new_choice_button.setAttribute("onclick", "build_new_choice_dom_tree(parentNode.parentNode)");
        toolbar.appendChild(add_new_choice_button);

        var remove_all_choices_button = document.createElement("button");
        remove_all_choices_button.appendChild(document.createTextNode("Remove All Choices"));
        toolbar.appendChild(remove_all_choices_button);
        remove_all_choices_button.setAttribute("onclick", "remove_all_children_of(parentNode.parentNode, \".dialogue-scene-choice\")");
    }

    return toolbar;
}

function construct_new_dialogue_scene_dom(name = "start",
                                          speaker_name_value = "PlayerCharacter",
                                          speaker_portrait_value = "testerbester",
                                          speaker_type_value = "NodeSpeaker",
                                          dialogue_text_content_value = "Enter Some Text Here",
                                          next_scene_value = "",
                                          choices_data = null) {
    var dialogue_option_div = document.createElement("div");
    dialogue_option_div.setAttribute("class", "dialogue-option");

    {
        var header = document.createElement("H2");
        header.appendChild(document.createTextNode("Dialogue Scene"));
        dialogue_option_div.appendChild(header);
    }

    // Scene Name
    {
        var label = document.createElement("label").appendChild(document.createTextNode("Name of Scene: "));
        dialogue_option_div.appendChild(label);
        dialogue_option_div.appendChild(construct_input_field("name", "scene-name", "scene-name", name));
    } dialogue_option_div.appendChild(document.createElement("br"));

    // Speaker Type UI
    {
        var header = document.createElement("H2");
        header.appendChild(document.createTextNode("Speaker Type"));
        dialogue_option_div.appendChild(header);

        {
            var node_speaker_radio_button = construct_input_field("radio", "speaker-type"+gensym_counter.toString(), "speaker-type", "NodeSpeaker");
            node_speaker_radio_button.checked = speaker_type_value == "NodeSpeaker";
            var label = document.createElement("label").appendChild(document.createTextNode("Node Speaker(EG: Player)"));
            dialogue_option_div.appendChild(label);
            dialogue_option_div.appendChild(node_speaker_radio_button);
        }
        dialogue_option_div.appendChild(document.createElement("br"));
        {
            var label = document.createElement("label").appendChild(document.createTextNode("Manual Speaker(EG: Narrator)"));
            dialogue_option_div.appendChild(label);
            var manually_specified_radio_button = construct_input_field("radio", "speaker-type"+gensym_counter.toString(), "speaker-type", "ManuallySpecified")
            manually_specified_radio_button.checked = speaker_type_value == "ManuallySpecified";
            dialogue_option_div.appendChild(manually_specified_radio_button);
        }

        gensym_counter += 1;
    }
    dialogue_option_div.appendChild(document.createElement("br"));
    dialogue_option_div.appendChild(document.createElement("br"));

    var aligned_table_div = document.createElement("div");
    aligned_table_div.setAttribute("class", "aligned-table");
    // Speaker Information
    {
        {
            var header = document.createElement("H2");
            header.appendChild(document.createTextNode("Speaker Information"));
            aligned_table_div.appendChild(header);
        }
        {
            var label = document.createElement("label");
            label.appendChild(document.createTextNode("Speaker Name or Node Name: "));
            aligned_table_div.appendChild(label);
            aligned_table_div.appendChild(construct_input_field("name", "speaker-name", "speaker-name", speaker_name_value));
        } aligned_table_div.appendChild(document.createElement("br"));
        {
            var label = document.createElement("label");
            label.appendChild(document.createTextNode("Speaker Portrait"));
            aligned_table_div.appendChild(label);
            aligned_table_div.appendChild(construct_input_field("name", "speaker-portrait", "speaker-portrait", speaker_portrait_value));
        }
    }
    dialogue_option_div.appendChild(aligned_table_div);
    dialogue_option_div.appendChild(document.createElement("br"));
    dialogue_option_div.appendChild(document.createElement("br"));
    // Dialogue Text Content
    {
        var header = document.createElement("H2");
        header.appendChild(document.createTextNode("Dialogue Text Content"));
        dialogue_option_div.appendChild(header);
        var text_area = document.createElement("textarea");
        text_area.setAttribute("class", "dialogue-content");
        text_area.value = dialogue_text_content_value;
        dialogue_option_div.appendChild(text_area);
    }
    dialogue_option_div.appendChild(document.createElement("br"));
    dialogue_option_div.appendChild(document.createElement("br"));
    // Next Branch
    {
        var label = document.createElement("label").appendChild(document.createTextNode("Next Branch(Leave empty \"\" for ending the dialogue)"));
        dialogue_option_div.appendChild(label);
        dialogue_option_div.appendChild(construct_input_field("name", "next-node", "next-node", next_scene_value));
    }

    dialogue_option_div.appendChild(document.createElement("br"));
    {
        var button = document.createElement("button");
        button.setAttribute("onclick", "delete_dom_element_with_confirmation(parentNode)");
        button.appendChild(document.createTextNode("Remove this scene."));

        dialogue_option_div.appendChild(button);
    }

    {
        var header = document.createElement("H2");
        header.appendChild(document.createTextNode("Dialogue Choices"));
        dialogue_option_div.appendChild(header);
        dialogue_option_div.appendChild(construct_dialogue_choices_toolbar());
    }

    if (choices_data != null) {
        Object.entries(choices_data).forEach(
            function(json_choice) {
                console.log(json_choice);
                build_new_choice_dom_tree(dialogue_option_div,
                                          json_choice[1]["text"],
                                          ("next" in json_choice[1] ? json_choice[1]["next"] : ""));
            }
        );
    }
    return dialogue_option_div;
}

function build_dialogue_scene_dom_tree() {
    var dialogue_scenes_div = document.getElementById("dialogue-scenes");

    dialogue_scenes_div.appendChild(construct_new_dialogue_scene_dom());
    console.log("ASSEMBLE!");
}

// oh my god I hate this so much.
function attempt_to_save_dom_as_json() {
    var final_json_data = {};

    function retrieve_speaker_info(scene_dom_tree) {
        let speaker_type = function () {
            var nodes = scene_dom_tree.querySelectorAll(".speaker-type");
            for (var node_index = 0; node_index < nodes.length; ++node_index) {
                if (nodes[node_index].checked) {
                    return nodes[node_index].value;
                }
            }
        }();

        var speaker_name = scene_dom_tree.getElementsByClassName("speaker-name")[0];
        if (speaker_type == "NodeSpeaker") {
            return {"type": speaker_type, "speaker": speaker_name.value};
        } else {
            var speaker_portrait = scene_dom_tree.getElementsByClassName("speaker-portrait")[0];
            return {"type": speaker_type, "speaker": speaker_name.value, "portrait": speaker_portrait.value};
        }
    }

    function retrieve_choices_info(scene_dom_tree) {
        var choices = [];
        scene_dom_tree.querySelectorAll(".dialogue-scene-choice").forEach(
            function (node) {
                var choice_text = node.getElementsByClassName("choice-content")[0];
                var choice_next_node_name = node.getElementsByClassName("next-node")[0];
                choices.push({"text": choice_text.value, "next": choice_next_node_name.value});
            }
        );

        return choices;
    }

    document.getElementById("dialogue-scenes").querySelectorAll(".dialogue-option").forEach(
        function (node) {
            var scene_name = node.getElementsByClassName("scene-name")[0];
            var scene_text = node.getElementsByClassName("dialogue-content")[0];

            var scene = {
                "speaker": retrieve_speaker_info(node),
                "text": scene_text.value
            };

            {
                var choices_list = retrieve_choices_info(node);
                if (choices_list && choices_list.length) {
                    scene["choices"] = choices_list;
                }
            }

            {
                var next_node_name = node.getElementsByClassName("next-node")[0];
                if (next_node_name && next_node_name.value.length) {
                    scene["next"] = next_node_name.value;
                }
            }
            
            final_json_data[scene_name.value] = scene;
        }
    );

    var json_string = JSON.stringify(final_json_data);
    {
        var data_uri = "data:application/json;charset=utf-8," + encodeURIComponent(json_string);
        let link_element = document.createElement("a");
        link_element.setAttribute("href", data_uri);
        link_element.setAttribute("download", "dialogue.json");
        link_element.click();
    }
    console.log(json_string);
}

function rebuild_dom_tree_from_json(data) {
    remove_all_children_of(document, ".dialogue-scene-choice");
    remove_all_children_of(document, ".dialogue-option");

    var dialogue_scenes_div = document.getElementById("dialogue-scenes");
    Object.entries(data).forEach(function(json_scene) {
        console.log(json_scene);
        dialogue_scenes_div.append(construct_new_dialogue_scene_dom(
            json_scene[0],
            json_scene[1]["speaker"]["speaker"],
            ("portrait" in json_scene[1]["speaker"]) ? json_scene[1]["speaker"]["portrait"] : "",
            json_scene[1]["speaker"]["type"],
            json_scene[1]["text"],
            ("next" in json_scene[1] ? json_scene[1]["next"] : ""),
            ("choices" in json_scene[1] ? json_scene[1]["choices"] : null)
        ));
    });
    // data.entries.forEach(function (json_scene) {
    //     console.log(json_scene);
    // })
}

function handle_load_file(file_input) {
    var file_reader = new FileReader();
    // file_reader.readAsDataURL(file_input.files[0]);
    file_reader.onload = function (event) {
        rebuild_dom_tree_from_json(JSON.parse(event.target.result));
    }
    file_reader.readAsText(file_input.files[0]);
}

build_dialogue_scene_dom_tree();
