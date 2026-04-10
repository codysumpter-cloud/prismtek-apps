# Dev Checklist

Use this checklist when making meaningful changes in `prismtek-apps`.

## Before changing structure

- confirm the change belongs in this repo
- confirm it is product implementation, not runtime substrate or policy work
- check whether an existing doc or decision already covers the area

## Before opening a PR

- update docs if repo ownership or structure changed
- make sure naming still matches the current layered naming rules
- check whether package or app boundaries became blurrier
- note any migration follow-up that still needs to happen

## If build or release behavior changes

- update `docs/AUTOMATION_MIGRATION.md` if ownership assumptions changed
- update `docs/BUILD_OWNERSHIP_AUDIT.md` if current or target owners changed
- state whether the change is transitional or final ownership

## If you add a package

- explain why an existing package is not enough
- document the package role
- keep it product-facing and scoped

## If you add an app surface

- explain why it belongs in `apps/`
- note whether it is a real shipped surface or transitional
- link it back to BeMore or the Prismtek product family clearly

## If you touch app branding metadata

- do not ship placeholder third-party assets in manifests or icons
- prefer no icon metadata over fake remote icon URLs
- if branding is still in flux, keep labels honest and leave a clear follow-up note
