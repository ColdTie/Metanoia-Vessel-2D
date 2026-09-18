# Metanoia: Vessel — CLAUDE.md

## Project

2D space exploration game in Godot 4 / GDScript. HTML5-deployable via GitHub Pages.
Peaceful by design: most encounters avoidable or resolved through dialogue, combat on ~1/3 of missions and almost never forced. Rewards come from settling worlds and founding Vessels, not from killing.

## Tech Stack

- **Engine**: Godot 4 (GL Compatibility renderer — required for HTML5/WebGL)
- **Language**: GDScript only. No C#, no GDNative, no plugins that break HTML5
- **Persistence**: `user://save.json` via `SaveLoad` autoload
- **Export**: HTML5 target, must stay Pages-deployable

## Structure

```
project.godot
assets/sprites/          — real sprites go here; placeholders fine
design/
  systems.md             — game design ground truth; keep in sync
  content-log.md         — one line per session
scenes/
  travel/
    travel_screen.tscn   — main navigation hub (start scene)
scripts/
  autoloads/
    game_state.gd        — singleton: world catalog, player state, signals
    save_load.gd         — load/save to user://save.json
  travel/
    travel_screen.gd     — travel screen UI + logic (builds UI in code)
```

## Autoloads

| Name | Path | Purpose |
|------|------|---------|
| `GameState` | `scripts/autoloads/game_state.gd` | All mutable game state, signals |
| `SaveLoad` | `scripts/autoloads/save_load.gd` | JSON save/load |

## Key Systems (short ref — see design/systems.md for full detail)

- **Travel**: fuel-gated, distance-cost per world. `GameState.travel_to_world(id)`
- **Worlds**: catalogued in `GameState.world_catalog`, 5 worlds v1
- **Settling**: marks world settled, offers choose-1-of-3 passive popup (in `travel_screen.gd`)
- **Passives**: `GameState.passives`, max 10 → void unlock check
- **Specimens**: collected during world exploration (TODO)
- **Combat**: ~1/3 missions; almost never forced; rewards ≠ killing

## Open Questions

- **Replicator**: its role in the void/black-hole endgame is unresolved.
  Do NOT lock this design without flagging it here first.

## Per-Run Rules

1. One small, self-contained, testable increment
2. Keep `design/systems.md` in sync with any system change
3. Append one line to `design/content-log.md`
4. GDScript only; no plugins that break HTML5 export
5. Peaceful bias: default encounters to avoidable/talkable
