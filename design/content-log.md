# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-08-28  Implemented choose-1-of-3 passive rewards on settling: expanded GameState.PASSIVE_ROSTER to 10 entries (4 new: warm_current, star_cartographer, steady_hands, deep_anchor), added draw_passive_choices()/has_passive(), and a popup UI in travel_screen.gd — first settlement still auto-grants Founding Bonus, every settlement after draws 3 random unowned passives to choose from.
