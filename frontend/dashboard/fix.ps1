# fix.ps1
# Run from inside dashboard/ folder:
#   powershell -ExecutionPolicy Bypass -File fix.ps1

Write-Host "Fixing filename casing and BOM issues..." -ForegroundColor Cyan

# ── Step 1: Fix wrong-cased filenames via temp rename ────────────────
Write-Host "`nStep 1: Renaming files to correct case..." -ForegroundColor Yellow

if (Test-Path "src\context\Appcontext.js") {
    Rename-Item "src\context\Appcontext.js" "Appcontext_TEMP.js"
    Rename-Item "src\context\Appcontext_TEMP.js" "AppContext.js"
    Write-Host "  Fixed: Appcontext.js -> AppContext.js" -ForegroundColor Green
} elseif (Test-Path "src\context\AppContext.js") {
    Write-Host "  OK: AppContext.js already correct" -ForegroundColor Gray
}

if (Test-Path "src\components\deleteModal.js") {
    Rename-Item "src\components\deleteModal.js" "deleteModal_TEMP.js"
    Rename-Item "src\components\deleteModal_TEMP.js" "DeleteModal.js"
    Write-Host "  Fixed: deleteModal.js -> DeleteModal.js" -ForegroundColor Green
} elseif (Test-Path "src\components\DeleteModal.js") {
    Write-Host "  OK: DeleteModal.js already correct" -ForegroundColor Gray
}

# ── Step 2: Rewrite every JS file without BOM ────────────────────────
Write-Host "`nStep 2: Rewriting files without BOM..." -ForegroundColor Yellow

$files = Get-ChildItem -Recurse -Include "*.js","*.css","*.html","*.env" -Path "src","public",".env" -ErrorAction SilentlyContinue

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    # Remove BOM if present
    if ($content.StartsWith([char]0xFEFF)) {
        $content = $content.Substring(1)
    }
    # Write back without BOM
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($file.FullName, $content, $enc)
    Write-Host "  Cleaned: $($file.Name)"
}

# Also fix .env
if (Test-Path ".env") {
    $content = [System.IO.File]::ReadAllText(".env", [System.Text.Encoding]::UTF8)
    if ($content.StartsWith([char]0xFEFF)) { $content = $content.Substring(1) }
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Resolve-Path ".env").Path, $content, $enc)
    Write-Host "  Cleaned: .env"
}

# ── Step 3: Verify the critical files exist with right names ─────────
Write-Host "`nStep 3: Verifying critical files..." -ForegroundColor Yellow

$critical = @(
    "src\context\AppContext.js",
    "src\components\DeleteModal.js",
    "src\components\Sidebar.js",
    "src\components\UI.js",
    "src\components\ProductForm.js",
    "src\components\Toast.js",
    "src\components\Topbar.js",
    "src\hooks\useProducts.js",
    "src\hooks\useToast.js",
    "src\utils\helpers.js",
    "src\screens\Dashboard.js",
    "src\screens\AddProduct.js",
    "src\screens\EditProduct.js",
    "src\screens\ProductList.js",
    "src\screens\OutputScreen.js",
    "src\App.js",
    "src\index.js",
    "src\index.css",
    "src\App.css",
    "public\index.html"
)

$allGood = $true
foreach ($f in $critical) {
    if (Test-Path $f) {
        Write-Host "  OK  $f" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $f" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""
if ($allGood) {
    Write-Host "Everything looks good! Run: npm start" -ForegroundColor Cyan
} else {
    Write-Host "Some files are missing. Run setup.ps1 first, then run fix.ps1 again." -ForegroundColor Red
}