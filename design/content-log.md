# Content Log

One line per session.

2026-06-24  Scaffolded Godot 4 project: project.godot, GameState + SaveLoad autoloads, Travel Screen v1 (parallax stars, destination list with fuel costs, found-vessel stub, save-on-settle, world descriptions).
2026-07-21  Implemented choose-1-of-3 passive reward flow: founding_bonus now grants only on the true first settlement, later settlements draw 3 unowned passives from a new 9-entry GameState.passive_roster via a popup (scenes/ui/passive_select.tscn); wired frost_hardened/deep_diver/stellar_cartographer as real travel-fuel discounts.
