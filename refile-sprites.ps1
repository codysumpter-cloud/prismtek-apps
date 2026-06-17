<<<<<<< HEAD
# refile-sprites.ps1
# Moves character/creature sprites from game-assets/misc/ to game-assets/characters/
# via git mv, then commits and pushes.

$ErrorActionPreference = "Continue"
$REPO = "C:\Users\cody_\prismtek-push\prismtek-apps"
Set-Location $REPO

Write-Host "=== Refile: misc/ -> characters/ ===" -ForegroundColor Cyan
Write-Host "Repo: $REPO" -ForegroundColor Gray

$files = @(
    # Dinosaurs / prehistoric
    "trex.zip",
    "triceratops.zip",
    "stegosaurus.zip",
    "ankylosaurus.zip",
    "raptor.7z",
    "pterodactyl.zip",
    "Dinasour30.png",
    "dinasour_1.gif",
    # Mammals
    "Fox Sprite Sheet.png",
    "Koala Sprite Sheet.json",
    "Koala Sprite Sheet.png",
    "Ferret Sprite Sheet.json",
    "Ferret Sprite Sheet.png",
    "Rabbit halberdier sprite sheets.rar",
    "Cow.zip",
    "Cows.zip",
    "Deer.zip",
    "Squirrel.zip",
    "FarmHorsePack.zip",
    "Pony 5.png",
    "sheep.png",
    "sheep_assets.rar",
    "pig.png",
    "Rat archer sprite sheet.zip",
    "RatPack_v1-00.zip",
    "Armadillo Sprite Sheet.png",
    "pixel_art_hedgehog.zip",
    "Bat.zip",
    "Bat (1).zip",
    "Pet Dogs Pack.zip",
    "GandalfHardcore Pet companion.zip",
    # Cats / kittens
    "Sleeping-Kittens.zip",
    "black-kitten.zip",
    "grey-kitten.zip",
    "outlines-kitten.zip",
    "white-kitten.zip",
    # Birds
    "Goose.zip",
    "Crow Animations.rar",
    "Pigeons.zip",
    "birb.png",
    "Ducky.zip",
    "DuckyV2.zip",
    "ParrotAssets.png",
    "ParrotGIF.gif",
    "Butterfly.zip",
    # Sea / reptile
    "octopus-jellyfish-shark-and-turtle-free-sprite-pixel-art.zip",
    "Turtle.png",
    "otter_sprite_pack.zip",
    "Toad animations.rar",
    "PixelSnakes_Free_Carysaurus.zip",
    "PixelWasps_Free_Carysaurus.zip",
    "Manzana_Snail.zip",
    "Snail_Char 3.0.zip",
    # Fantasy / characters
    "Ghost_Download.zip",
    "kaitlyn_unicorn.png",
    "Santa - Sprite Sheet.png",
    "ROLEWORLD CLERIC FREE.zip",
    # Pokemon / creature sprites
    "Charmander Blinking Idle (1).png",
    "Charmander Blinking Idle (2).png",
    "Charmander Blinking Idle (3).png",
    "Charmander Blinking Idle (4).png",
    "Charmander Blinking Idle (5).png",
    "Charmander Blinking Idle (6).png",
    "Charmander Blinking Idle (7).png",
    "Charmander Blinking Idle (8).png",
    "Charmander Blinking Idle (9).png",
    "Charmander-Blink-1.gif"
)

$moved = 0
$skipped = 0
$errors = 0

foreach ($file in $files) {
    $src = "game-assets/misc/$file"
    $dst = "game-assets/characters/$file"

    if (Test-Path $src) {
        Write-Host "  mv  $file" -ForegroundColor Green
        git mv -- $src $dst 2>&1
        if ($LASTEXITCODE -eq 0) { $moved++ } else {
            Write-Host "      ERROR moving $file (exit $LASTEXITCODE)" -ForegroundColor Red
            $errors++
        }
    } else {
        Write-Host "  --  SKIP (not found): $file" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host ""
Write-Host "Summary: $moved moved, $skipped skipped, $errors errors" -ForegroundColor Cyan

if ($moved -gt 0) {
    Write-Host ""
    Write-Host "Committing..." -ForegroundColor Cyan
    git commit -m "refile: move character sprites from misc/ to characters/"

    Write-Host ""
    Write-Host "Pushing to origin..." -ForegroundColor Cyan
    git push

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: pushed to remote." -ForegroundColor Green
    } else {
        Write-Host "WARNING: push returned exit code $LASTEXITCODE" -ForegroundColor Yellow
    }
} else {
    Write-Host "Nothing to commit." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Press any key to close." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
=======
# refile-sprites.ps1
# Moves character/creature sprites from game-assets/misc/ to game-assets/characters/
# via git mv, then commits and pushes.

$ErrorActionPreference = "Continue"
$REPO = "C:\Users\cody_\prismtek-push\prismtek-apps"
Set-Location $REPO

Write-Host "=== Refile: misc/ -> characters/ ===" -ForegroundColor Cyan
Write-Host "Repo: $REPO" -ForegroundColor Gray

$files = @(
    # Dinosaurs / prehistoric
    "trex.zip",
    "triceratops.zip",
    "stegosaurus.zip",
    "ankylosaurus.zip",
    "raptor.7z",
    "pterodactyl.zip",
    "Dinasour30.png",
    "dinasour_1.gif",
    # Mammals
    "Fox Sprite Sheet.png",
    "Koala Sprite Sheet.json",
    "Koala Sprite Sheet.png",
    "Ferret Sprite Sheet.json",
    "Ferret Sprite Sheet.png",
    "Rabbit halberdier sprite sheets.rar",
    "Cow.zip",
    "Cows.zip",
    "Deer.zip",
    "Squirrel.zip",
    "FarmHorsePack.zip",
    "Pony 5.png",
    "sheep.png",
    "sheep_assets.rar",
    "pig.png",
    "Rat archer sprite sheet.zip",
    "RatPack_v1-00.zip",
    "Armadillo Sprite Sheet.png",
    "pixel_art_hedgehog.zip",
    "Bat.zip",
    "Bat (1).zip",
    "Pet Dogs Pack.zip",
    "GandalfHardcore Pet companion.zip",
    # Cats / kittens
    "Sleeping-Kittens.zip",
    "black-kitten.zip",
    "grey-kitten.zip",
    "outlines-kitten.zip",
    "white-kitten.zip",
    # Birds
    "Goose.zip",
    "Crow Animations.rar",
    "Pigeons.zip",
    "birb.png",
    "Ducky.zip",
    "DuckyV2.zip",
    "ParrotAssets.png",
    "ParrotGIF.gif",
    "Butterfly.zip",
    # Sea / reptile
    "octopus-jellyfish-shark-and-turtle-free-sprite-pixel-art.zip",
    "Turtle.png",
    "otter_sprite_pack.zip",
    "Toad animations.rar",
    "PixelSnakes_Free_Carysaurus.zip",
    "PixelWasps_Free_Carysaurus.zip",
    "Manzana_Snail.zip",
    "Snail_Char 3.0.zip",
    # Fantasy / characters
    "Ghost_Download.zip",
    "kaitlyn_unicorn.png",
    "Santa - Sprite Sheet.png",
    "ROLEWORLD CLERIC FREE.zip",
    # Pokemon / creature sprites
    "Charmander Blinking Idle (1).png",
    "Charmander Blinking Idle (2).png",
    "Charmander Blinking Idle (3).png",
    "Charmander Blinking Idle (4).png",
    "Charmander Blinking Idle (5).png",
    "Charmander Blinking Idle (6).png",
    "Charmander Blinking Idle (7).png",
    "Charmander Blinking Idle (8).png",
    "Charmander Blinking Idle (9).png",
    "Charmander-Blink-1.gif"
)

$moved = 0
$skipped = 0
$errors = 0

foreach ($file in $files) {
    $src = "game-assets/misc/$file"
    $dst = "game-assets/characters/$file"

    if (Test-Path $src) {
        Write-Host "  mv  $file" -ForegroundColor Green
        git mv -- $src $dst 2>&1
        if ($LASTEXITCODE -eq 0) { $moved++ } else {
            Write-Host "      ERROR moving $file (exit $LASTEXITCODE)" -ForegroundColor Red
            $errors++
        }
    } else {
        Write-Host "  --  SKIP (not found): $file" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host ""
Write-Host "Summary: $moved moved, $skipped skipped, $errors errors" -ForegroundColor Cyan

if ($moved -gt 0) {
    Write-Host ""
    Write-Host "Committing..." -ForegroundColor Cyan
    git commit -m "refile: move character sprites from misc/ to characters/"

    Write-Host ""
    Write-Host "Pushing to origin..." -ForegroundColor Cyan
    git push

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: pushed to remote." -ForegroundColor Green
    } else {
        Write-Host "WARNING: push returned exit code $LASTEXITCODE" -ForegroundColor Yellow
    }
} else {
    Write-Host "Nothing to commit." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Press any key to close." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
