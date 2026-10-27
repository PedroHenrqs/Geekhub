# Prepara o projeto GeekHub no Windows. Execute DENTRO da pasta do projeto:
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
$ErrorActionPreference = "Stop"

Write-Host "1/4 Gerando as pastas de plataforma (android, web, windows...)" -ForegroundColor Cyan
flutter create . --project-name geekhub --org br.edu.geekhub --platforms=android,web,windows

Write-Host "2/4 Baixando dependencias" -ForegroundColor Cyan
flutter pub get

Write-Host "3/4 Garantindo permissao de INTERNET no Android" -ForegroundColor Cyan
$manifest = "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifest) {
  $content = Get-Content $manifest -Raw
  if ($content -notmatch 'android.permission.INTERNET') {
    $regex = [regex]'(<manifest[^>]*>)'
    $perm = "`r`n    <uses-permission android:name=`"android.permission.INTERNET`"/>"
    $content = $regex.Replace($content, ('$1' + $perm), 1)
    Set-Content -Path $manifest -Value $content -NoNewline
    Write-Host "   permissao adicionada."
  } else { Write-Host "   ja existe." }
}

Write-Host "4/4 Analise estatica e testes" -ForegroundColor Cyan
flutter analyze
flutter test

Write-Host ""
Write-Host "Pronto. Rode:  flutter run -d chrome   (ou -d windows / dispositivo Android)" -ForegroundColor Green
Write-Host "LEMBRE: troque SEU_EMAIL@exemplo.com em lib\core\constants\app_constants.dart" -ForegroundColor Yellow
