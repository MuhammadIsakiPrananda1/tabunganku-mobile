# 🚀 TabunganKu - One-Click Release Script
# Automates: Build, commit, tagging, and pushing to GitHub.

# 1. Read version from pubspec.yaml
$pubspec = Get-Content "pubspec.yaml" -Raw
$versionLine = $pubspec | Select-String -Pattern "version: (.*)"
$versionWithBuild = $versionLine.Matches.Groups[1].Value.Trim()
$version = $versionWithBuild.Split("+")[0]

Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "🚀 Preparing Release v$version" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

# 2. Sync AppVersion.dart (Optional safety check)
Write-Host "🔍 Verifying AppVersion.dart..."
$appVersionPath = "lib/core/constants/app_version.dart"
$appVersionContent = @"
class AppVersion {
  static const String version = '$version';
  static const String buildNumber = '$($versionWithBuild.Split("+")[1])';
  static const String fullVersion = 'v`$version';
  static const String edition = 'Edisi Mint Fresh v`$version';
}
"@
$appVersionContent | Out-File -FilePath $appVersionPath -Encoding utf8

# 3. Clean and Get Packages
Write-Host "📦 Getting dependencies..."
flutter pub get

# 4. Commit changes
Write-Host "💾 Committing changes..."
git add .
git commit -m "chore: bump version to $version"

# 5. Create and Push Tag
Write-Host "🏷️ tag v$version..."
$tagName = "v$version"

# Remove existing tag if it exists locally
if (git tag -l $tagName) {
    Write-Host "⚠️ Tag $tagName already exists locally. Removing it..." -ForegroundColor Yellow
    git tag -d $tagName
}

git tag $tagName
Write-Host "⬆️ Pushing to GitHub..." -ForegroundColor Green
git push origin main
git push origin $tagName

Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "✅ Done! GitHub Action should now be building your release." -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan
