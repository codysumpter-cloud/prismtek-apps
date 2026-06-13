# Ship of Fools Fruit Import

Pixel Fruit Arena can generate playable/selectable fruit definitions from the Ship of Fools Devil Fruit Encyclopedia.

Source: <https://shipoffools.fandom.com/wiki/Devil_Fruit_Encyclopedia>

The source page itself says the encyclopedia belongs to the Ship of Fools wiki and is not currently up to date, so generated fruit data is marked `licenseReviewRequired: true` and should be reviewed before public redistribution.

## Import

From `games/pixel-fruit-arena/`:

```bash
npm run import:shipoffools-fruits
npm test
npm run build
```

The importer writes:

- `src/fruits/generatedShipOfFoolsFruits.js`
- `data/fruits/shipoffools-fruits.generated.json`

Runtime fruit selection imports the generated module through `src/fruits/fruits.js`, so imported fruits appear anywhere `FRUITS` is used, including the newest lobby fruit picker.

## Gameplay mapping

Each imported fruit receives three generic but playable abilities:

- `Shot`
- `Surge`
- `Breaker`

Ability kinds are mapped by encyclopedia type:

- Logia: projectile / field / dash
- Zoan: melee / dash / uppercut
- Ancient Zoan: melee / dash / heavy
- Mythical Zoan: melee / burst / uppercut
- Paramecia: projectile / field / heavy

Those kinds use the newest game combat system, including directional variants, hitboxes, training overlay events, CPU use, awakening, mastery, and lobby selection.
