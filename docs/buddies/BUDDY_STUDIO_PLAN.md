# Guided Buddy Studio plan

This placeholder records the GitHub-first task scope for issue #97.

Guided Buddy Studio should let users create validated ASCII and pixel Buddies without needing to understand spritesheets, ASCII dimensions, palettes, or animation frame rules.

Initial implementation should focus on:

- T-Rex egg and baby stages
- ASCII and pixel preview entry points
- style packs from `prismtek-buddy-core` PR #2
- validation-first save flow
- quality score display
- one-tap repair action surface

No raw generated ASCII or image output should render directly in live Buddy runtime. Candidate assets must move through normalization, validation, scoring, compilation, preview, and save gates.
