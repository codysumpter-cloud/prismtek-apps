# Prismcade Weather / Season System

Shared model: `apps/prismcade-native/Shared/Platform/WeatherSystem.swift`
(`WeatherState` + `WeatherLayer`). Weather is **gameplay**, not decoration — it changes player
physics, scoring, and the seasonal look. Driven by the run score.

## Score thresholds (both runners)
| Score | State | Season |
| --- | --- | --- |
| 0–9 | clear | spring |
| 10–19 | wind | — |
| 20–29 | rain | — |
| 30–39 | storm | — |
| 40–49 | autumn | autumn |
| 50+ | snow | winter |

## Player physics effects
**Flappy Pixel**
- rain: gravity ×1.12, flap ×0.94
- storm: gravity ×1.20, flap ×0.90, vertical wind gust (sinusoidal, amp 120)
- wind: vertical gust (amp 70)
- snow: gravity ×0.90, flap ×0.88 (floaty/slow)

**Prismtek Dino Dash**
- wind: run speed ×1.06, jump ×1.05
- storm: run speed ×1.10, jump ×0.95
- rain: run speed ×0.96
- snow: run speed ×0.90, jump ×0.92

All modifiers are gentle — weather adds challenge/atmosphere, never makes a run impossible.

## Scoring
Each state has a `survivalBonus` (clear 0 → storm/snow 3). Flappy adds it per gate cleared;
Dino adds a lump bonus per weather transition (`weatherBonusTotal`).

## Visuals
- Full-screen seasonal **tint** overlay (alpha per state; storm darkest, snow cool blue, autumn warm).
- Animated **CraftPix particles** per state (wind streaks, falling rain, falling snow).
- A `Weather: <state>` HUD label on each transition + a transition SFX.

## Assets used (CraftPix Weather Effects Assets Pack, `~/Documents/Libresprite/`)
`weather_wind_1/2` (Wind), `weather_rain_1/2` (6 Weather/Rain), `weather_snow_1` (Snow1),
`weather_thunder_1` (Thunder), `weather_shine_1` (Shine, hit FX). Curated copies in
`Shared/Resources/Art/Weather/`. License: CraftPix file license (owner-provided pack).

## Verified
Flappy + Dino autoverify receipts record `weatherIsGameplay: true`, `weatherPeakState: snow`,
and the thresholds; snapshots `flappy-weather-snapshot` / `dino-weather-snapshot` show the storm
state with tint + rain.

## Limitations
- No dedicated autumn-leaf sprite yet (autumn uses warm tint + wind particles).
- Thunder/lightning flash not yet wired (asset imported as `weather_thunder_1` for a future pass).
- Buck uses the weather wind sprites decoratively only (its score model differs).
