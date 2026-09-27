# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-09-27  Implemented choose-1-of-3 passive selection on settling: filled out the passive roster to 10 (4 new: deep_reserves, keen_trader, quiet_hands, safe_harbor), added GameState.get_passive_choices/grant_passive/has_passive, wired frost_hardened and deep_reserves to real effects (ice travel cost, max fuel), and added an in-scene choice overlay in travel_screen.gd for settlements after the first.
