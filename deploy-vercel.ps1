# deploy-vercel.ps1
$ErrorActionPreference = "Stop"

Write-Host "==> Configuring build environment..." -ForegroundColor Cyan
$env:PATH = "C:\Users\shiva\.cargo\bin;C:\Users\shiva\w64devkit\bin;" + $env:PATH
# Use C: drive for intermediate build artifacts (143+ GB free) to avoid filling D: drive
$env:CARGO_TARGET_DIR = "C:\Users\shiva\.cargo-target"

$webDir = Join-Path $PSScriptRoot "apps\figcraft-web"
$distDir = Join-Path $PSScriptRoot "dist\web"

Write-Host "==> Building WebAssembly release package with Trunk (using $env:CARGO_TARGET_DIR)..." -ForegroundColor Cyan
Push-Location $webDir
try {
    trunk build --release
} finally {
    Pop-Location
}

if (-not (Test-Path (Join-Path $distDir "index.html"))) {
    Write-Error "dist/web/index.html not found after build!"
}

Copy-Item (Join-Path $webDir "vercel.json") (Join-Path $distDir "vercel.json") -Force

Write-Host "==> Deploying dist/web to Vercel..." -ForegroundColor Green
Push-Location $distDir
try {
    npx -y vercel --prod
} finally {
    Pop-Location
}
