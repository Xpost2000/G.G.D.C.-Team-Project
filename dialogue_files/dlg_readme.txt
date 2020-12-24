The format will sort of look like this:

We will always start on the "start" branch.
node_name or branch_name : {
    *PICK ONLY ONE OF THESE OTHERWISE UNDEFINED BEHAVIOR MAY HAPPEN!*
    speaker_name & _optional_ speaker_portrait

    This is meant to be used for "non-corporeal" things like
    the Narrator or something like that...

    OR

    speaker

    This is meant to be a node in the current level. I will not define what
    happens if we don't actually have such a node.

    That node should also have a Sprite/AnimatedSprite field called DialoguePortrait.
    This will be used for drawing their portrait.

    We should safely expect "MainCharacter" to ALWAYS exist.

    text

    This is hopefully self explanatory.


    *PICK ONLY ONE OF THESE TWO OTHERWISE UNDEFINED BEHAVIOR MAY HAPPEN!*
    next

    This will go to the next branch if given any value. If you leave it empty, then
    this will be the end of the dialogue, and we get back to gameplay.

    OR

    choices : [
       {
         text

         This is also self explanatory.


         #TODO define a way for conditional branching that isn't stupid#
         next

         This is the same as the next branch you saw earlier.

         actions: [
                  This all depends on the type. these are to be decided.
                  {"type": "give_gold", "value": 1500},
                  {"type": "remove_gold", "value": 8500},
                  {"type": "give_item", "value": "broken_straight_sword"},
                  # "to" as in stage.
                  {"type": "update_quest_journal", "quest": "quest_name", "to": 0}
         ]

         This is an array describing what may happen if the choice is selected.
         This field is optional.
       }
    ]

    This is an array of choices which are described inside the braces...
}

Here's a working example of what I'm sort of thinking of.
Obviously JSON isn't very comfortable to write, but this shouldn't be too painful.
{
    "start": {
         "speaker_name": "The Narrator",
         "text": "Welcome to the game! This is some expositionary text for explaining how this works.",
         "next": "interjection_a"
    },

    "interjection_a": {
         "speaker": "MainCharacter",
         "text": "Ummm... Okay? I don't quite think this is a game...",
         "next": "prompt_a"
    },

    "prompt_a": {
         "speaker": "MainCharacter",
         "text": "Do you think this is a game?",
         choices: [
             {
                "text": "Yes?",
                "next": "cool"
             },
             {
                "text": "No?",
                "next": "toobad"
             } 
         ]
    },

    "toobad": {
        "speaker": "The Narrator",
        "text": "Well too bad... I say it's a game so this will be a game. Got it?"
        next: "cool"
    },

    "cool": {
        "speaker": "The Narrator",
        "text": "Cool, we're on the same page..."
        // ETC.
    }
}
