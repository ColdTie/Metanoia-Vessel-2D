# Metanoia: Vessel — Systems Design

*Ground truth for all development. Update when systems change.*

---

## Core Loop

1. **Travel** — choose a destination from the Travel Chart; spend fuel to arrive
2. **Explore** — walk the surface, encounter creatures, collect specimens
3. **Settle** — found a Vessel on a world; choose 1-of-3 passive rewards
4. **Repeat** — accumulate passives; unlock void endgame at 10

---

## Travel

- Player starts at Ardent Shore; fuel = 100 / 100
- Each world has a **distance** cost (fuel spent to travel there from anywhere)
- Fuel refills partially at Vessels; also from trade and exploration finds
- Travel is narrative-instant (no travel minigame yet; cut to arrival)

### World Catalog (v1 — 5 worlds)

| ID | Name | Type | Distance | Specimens |
|----|------|------|----------|-----------|
| ardent_shore | Ardent Shore | Temperate | 0 (start) | ember_moth, tide_crawler |
| pale_drift | Pale Drift | Ice | 3 | frost_wisp, deep_rumbler |
| verdant_coil | Verdant Coil | Jungle | 5 | canopy_singer, root_walker |
| the_hush | The Hush | Desert | 7 | sand_tender, echo_lizard |
| mirrorpool | Mirrorpool | Ocean | 9 | lens_fish, tide_weaver |

---

## Worlds

Each world carries:
- **type** — governs which passive bonuses apply
- **description** — 1–2 sentences of flavor
- **specimens** — 2 collectible creature/plant types
- **settled** flag + **vessel_name** (player-set or default "Vessel of X")

---

## Settling & Vessels

- A world can be settled once; action available when player is present
- On settle: player names the Vessel (dialog TODO), receives a passive
- **Reward flow**:
  - First-ever settlement always grants `founding_bonus` directly (+5 max fuel)
  - Every settlement after that offers a **choose-1-of-3** modal, drawing 3
    random unowned passives from `GameState.PASSIVE_POOL`
  - If fewer than 3 unowned passives remain, as many as are left are offered;
    if none remain, settling still succeeds with no passive awarded
- Settled worlds show `[V]` marker in travel chart
- Vessels provide partial fuel refill (TODO) and trade options (TODO)

---

## Passives

Persistent bonuses collected by settling, completing missions, and rare finds.

- Stored in `GameState.passives` array
- Reaching `MAX_PASSIVES` (10) triggers the void unlock check
- Each passive is `{ id, name, desc, source }` dict

### Passive Roster (10 / 10 — full for void unlock)

| ID | Name | Effect | Source |
|----|------|--------|--------|
| founding_bonus | Founding Bonus | First settlement — +5 max fuel | auto, 1st settle only |
| root_knowledge | Root Knowledge | Jungle worlds yield extra specimens | choose-1-of-3 pool |
| echo_listener | Echo Listener | Unlocks extra creature dialogue options | choose-1-of-3 pool |
| frost_hardened | Frost Hardened | Ice-world travel costs 1 less fuel | choose-1-of-3 pool |
| tide_reader | Tide Reader | Ocean worlds reveal hidden specimens | choose-1-of-3 pool |
| dust_walker | Dust Walker | Desert worlds never trigger forced combat | choose-1-of-3 pool |
| fuel_cache | Fuel Cache | Vessels refill extra fuel when visited | choose-1-of-3 pool |
| starlit_calm | Starlit Calm | Further reduces forced-combat chance everywhere | choose-1-of-3 pool |
| trade_instinct | Trade Instinct | Selling plants/info yields more credits | choose-1-of-3 pool |
| deep_listener | Deep Listener | Unlocks rare peaceful resolutions with hostile creatures | choose-1-of-3 pool |

Only `founding_bonus` (max fuel) is mechanically wired today; the rest are
recorded and displayed but their effects hook into systems that are still
TODO (specimens, dialogue, combat, economy).

---

## Void / Black Hole (Endgame)

- Triggered when `GameState.passives.size() >= 10`
- The Void appears as a special destination in the travel chart
- **⚠ UNRESOLVED**: Does the replicator feed into this? What does founding mean
  if things can be copied? Do NOT implement the void without resolving this first.

---

## Encounters & Creatures

Encounter types per mission:
- **Talk** (most common): creature has dialogue tree; outcomes vary
- **Avoid** (almost always available): costs time/resources; never catastrophic
- **Combat** (≈ 1/3 of missions): opt-in; even hostile creatures usually have a talk option

Forced combat: almost never. The exception is a tiny number of scripted story beats.

---

## Ship

- **Decorations**: cosmetic items displayed on ship view scene (TODO)
- **Plant selling**: specimens → credits at any Vessel (TODO)
- **Info selling**: world-scan data → credits at any Vessel (TODO)

---

## Economy

| Resource | Starts | Sources | Sinks |
|----------|--------|---------|-------|
| Credits | 0 | selling plants/info, missions | decorations, info buys |
| Fuel | 100/100 | Vessels (refill), finds | travel (distance cost) |

---

## Save Format (`user://save.json`)

```json
{
  "version": 1,
  "current_world": "Ardent Shore",
  "passives": [],
  "ship_decorations": [],
  "specimens": [],
  "credits": 0,
  "fuel": 100,
  "settled_worlds": [
    { "id": "ardent_shore", "vessel_name": "Vessel of Ardent Shore" }
  ]
}
```

---

## Scene Map

| Scene | Path | Status |
|-------|------|--------|
| Travel Screen | `scenes/travel/travel_screen.tscn` | ✅ v1 |
| World Surface | `scenes/world/world_surface.tscn` | TODO |
| Encounter | `scenes/encounter/encounter.tscn` | TODO |
| Ship View | `scenes/ship/ship_view.tscn` | TODO |
| Passive Select (1-of-3) | built in code, `travel_screen.gd` `_show_passive_choice_modal` | ✅ v1 |
| Vessel Naming Dialog | `scenes/ui/vessel_name_dialog.tscn` | TODO |
