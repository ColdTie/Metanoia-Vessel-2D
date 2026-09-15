# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-09-15  Implemented choose-1-of-3 passive selection on settle: filled out the 10-entry passive roster, added GameState.passive_pool/draw_passive_choices/grant_passive_from_pool, and a popup UI in travel_screen.gd; first settlement still auto-grants Founding Bonus, later settlements pick 1 of 3 drawn passives. Passive pool now persisted in save.json.
