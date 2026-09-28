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
- Actual cost is `GameState.get_travel_cost(world_id)`: base distance, modified
  by owned passives (e.g. `frost_hardened` shaves 1 fuel off ice-world travel)
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
  - First settlement ever: guaranteed `founding_bonus` (+5 max fuel), no choice shown
  - Every settlement after: choose 1 of 3 passives randomly drawn from
    `GameState.PASSIVE_POOL` (excludes passives already owned), via
    `scripts/ui/passive_select.gd` popup
  - If the pool is exhausted (all non-founding passives owned), settling still
    succeeds with no additional passive
- Settled worlds show `[V]` marker in travel chart
- Vessels provide partial fuel refill (TODO) and trade options (TODO)

---

## Passives

Persistent bonuses collected by settling, completing missions, and rare finds.

- Stored in `GameState.passives` array
- Reaching `MAX_PASSIVES` (10) triggers the void unlock check
- Each passive is `{ id, name, desc, source }` dict

### Passive Roster (planned — 10 needed for void unlock)

| ID | Name | Effect | Status |
|----|------|--------|--------|
| founding_bonus | Founding Bonus | First settlement — +5 max fuel | ✅ implemented |
| root_knowledge | Root Knowledge | Jungle worlds yield extra specimens | drawable; effect TODO (needs specimen system) |
| echo_listener | Echo Listener | Unlocks extra creature dialogue options | drawable; effect TODO (needs dialogue system) |
| frost_hardened | Frost Hardened | Ice-world travel costs 1 less fuel | ✅ implemented (`GameState.get_travel_cost`) |
| tide_reader | Tide Reader | Ocean worlds reveal hidden specimens | drawable; effect TODO (needs specimen system) |
| dust_walker | Dust Walker | Desert worlds never trigger forced combat | drawable; effect TODO (needs combat system) |
| *(4 more TBD)* | | | not yet in pool |

`root_knowledge`, `echo_listener`, `frost_hardened`, `tide_reader`, and
`dust_walker` are drawable now via `GameState.get_passive_choices()`; their
mechanical effects beyond `frost_hardened` land once the systems they hook
into (specimens, dialogue, combat) exist.

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
| Passive Select (1-of-3) | `scripts/ui/passive_select.gd` (code-built popup, no .tscn) | ✅ v1 |
| Vessel Naming Dialog | `scenes/ui/vessel_name_dialog.tscn` | TODO |
