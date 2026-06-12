param(
  [int]$Port = 4173,
  [switch]$Dist
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ServeRoot = $ProjectRoot
if ($Dist) {
  $ServeRoot = Join-Path $ProjectRoot "dist"
  if (-not (Test-Path -LiteralPath $ServeRoot)) {
    throw "dist/ does not exist. Run tools/build.ps1 before serving with -Dist."
  }
}

$listener = [System.Net.HttpListener]::new()
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

try {
  $listener.Start()
  Write-Host "Serving $ServeRoot at $prefix"
  Write-Host "Press Ctrl+C to stop."

  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $relativePath = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
      $relativePath = "index.html"
    }

    $targetPath = Join-Path $ServeRoot $relativePath
    $resolvedRoot = (Resolve-Path -LiteralPath $ServeRoot).Path
    $resolvedTarget = $null
    if (Test-Path -LiteralPath $targetPath -PathType Container) {
      $targetPath = Join-Path $targetPath "index.html"
    }
    if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
      $resolvedTarget = (Resolve-Path -LiteralPath $targetPath).Path
    }

    if ($null -eq $resolvedTarget -or -not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
      $context.Response.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("Not found")
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
      $context.Response.Close()
      continue
    }

    $extension = [System.IO.Path]::GetExtension($resolvedTarget).ToLowerInvariant()
    $contentType = switch ($extension) {
      ".html" { "text/html; charset=utf-8" }
      ".js" { "text/javascript; charset=utf-8" }
      ".css" { "text/css; charset=utf-8" }
      ".json" { "application/json; charset=utf-8" }
      ".svg" { "image/svg+xml" }
      ".png" { "image/png" }
      ".webp" { "image/webp" }
      default { "application/octet-stream" }
    }

    $bytes = [System.IO.File]::ReadAllBytes($resolvedTarget)
    $context.Response.ContentType = $contentType
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.Close()
  }
}
finally {
  if ($listener.IsListening) {
    $listener.Stop()
  }
  $listener.Close()
}
