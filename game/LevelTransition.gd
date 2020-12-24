extends Area2D

# What it sounds like.
# these will begin the path under res://scenes/
# so you should only put the level name.
export(String) var scene_to_transition_to;
# This is the node that we will place you at if you walk into the transition.
export(String) var landmark_node;
