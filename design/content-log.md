# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-09-07  Implemented choose-1-of-3 passive reward on settling: GameState.PASSIVE_POOL + get_passive_choices(), new Passive Select modal (scenes/ui/passive_select.tscn), wired into travel_screen settle flow, replacing the hardcoded founding_bonus-only grant.
