# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-09-23  Implemented choose-1-of-3 settling reward: Founding Bonus is now granted only on the player's first settlement, later settlements draw 3 unowned passives from a new GameState.PASSIVE_POOL and let the player pick one via a modal overlay on the Travel Screen; founded_first_vessel persisted in save.json.
