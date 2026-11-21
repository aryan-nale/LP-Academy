# tests/check_assets.ps1
$files = Get-ChildItem -Path "e:\ACE-Academy-main\frontend" -Recurse -Include *.jsx, *.js, *.html, *.css -Exclude node_modules
$publicDir = "e:\ACE-Academy-main\frontend\public"
$publicFiles = Get-ChildItem -Path $publicDir -File | Select-Object -ExpandProperty Name

Write-Host "Public directory contains:" -ForegroundColor Cyan
$publicFiles | ForEach-Object { Write-Host "  - $_" }

Write-Host "`nChecking asset references in frontend files:" -ForegroundColor Cyan
$pattern = '(?:\/|src=["'']|href=["'']|url\(["'']?)([a-zA-Z0-9_\-]+\.(?:png|jpg|jpeg|svg|mp4|webp|ico))'

$missing = @()
foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f.FullName)
    $matches = [regex]::Matches($text, $pattern)
    foreach ($m in $matches) {
        $asset = $m.Groups[1].Value
        # Check if asset exists in public folder
        if ($publicFiles -notcontains $asset) {
            $missing += "$asset referenced in $(Split-Path $f.FullName -Leaf)"
        }
    }
}

if ($missing.Count -eq 0) {
    Write-Host "✅ All referenced assets exist in frontend/public!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Missing or unverified asset references:" -ForegroundColor Yellow
    $missing | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" }
}
