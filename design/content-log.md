# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-09-28  Implemented choose-1-of-3 passive settling reward: first settlement still guarantees Founding Bonus, every settlement after draws 3 from a 5-entry passive pool via a code-built popup (scripts/ui/passive_select.gd); frost_hardened is now functionally wired into travel cost via GameState.get_travel_cost().
