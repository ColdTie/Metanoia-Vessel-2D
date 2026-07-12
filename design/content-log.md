# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-07-12  Choose-1-of-3 settling reward: completed the 10-passive roster in GameState, first settlement grants Founding Bonus automatically, every settlement after that draws 3 random unowned passives via GameState.get_random_passive_choices() and the player picks one inline in the Travel Screen (travel locked while a choice is pending).
