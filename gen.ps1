param(
  [string]$l = "python,csharp,descriptor",
  [string]$o = "out"
)
# Generate protobuf code from rotom.proto into ./out/<lang>/
# Usage:
#   ./gen.ps1                        # python + csharp + descriptor (default)
#   ./gen.ps1 -l go                  # only go
#   ./gen.ps1 -l python,csharp       # only python + csharp
#   ./gen.ps1 -l all                 # every supported language
#   ./gen.ps1 -l list                # show supported languages
#   ./gen.ps1 -o build -l go         # custom output dir
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$ProtoFile = "rotom.proto"
$OutDir = $o
$langs = $l

$Supported = @("python","csharp","cpp","java","kotlin","objc","php","ruby","rust","go","grpc-go","descriptor")

if ($langs -eq "list") {
  Write-Output ("Supported languages: " + ($Supported -join " ") + " (+ all)")
  exit 0
}
if ($langs -eq "all") { $langs = $Supported -join "," }

$langList = $langs -split '[,;\s]+' | Where-Object { $_ -ne "" }
foreach ($lang in $langList) {
  if ($Supported -notcontains $lang) {
    Write-Error "Unknown language: $lang. Supported: $($Supported -join ', ') (+ all, list)"
  }
}

function Has($n) { return $langList -contains $n }

if (-not (Get-Command protoc -ErrorAction SilentlyContinue)) {
  Write-Error "protoc not found in PATH."
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$args = @("--proto_path=.")
$generated = @()

if (Has "python") {
  New-Item -ItemType Directory -Force -Path "$OutDir/python" | Out-Null
  $args += "--python_out=$OutDir/python", "--pyi_out=$OutDir/python"
  $generated += "$OutDir/python"
}
if (Has "csharp") {
  New-Item -ItemType Directory -Force -Path "$OutDir/csharp" | Out-Null
  $args += "--csharp_out=$OutDir/csharp"
  $generated += "$OutDir/csharp"
}
if (Has "cpp") {
  New-Item -ItemType Directory -Force -Path "$OutDir/cpp" | Out-Null
  $args += "--cpp_out=$OutDir/cpp"
  $generated += "$OutDir/cpp"
}
if (Has "java") {
  New-Item -ItemType Directory -Force -Path "$OutDir/java" | Out-Null
  $args += "--java_out=$OutDir/java"
  $generated += "$OutDir/java"
}
if (Has "kotlin") {
  New-Item -ItemType Directory -Force -Path "$OutDir/kotlin" | Out-Null
  $args += "--kotlin_out=$OutDir/kotlin"
  $generated += "$OutDir/kotlin"
}
if (Has "objc") {
  New-Item -ItemType Directory -Force -Path "$OutDir/objc" | Out-Null
  $args += "--objc_out=$OutDir/objc"
  $generated += "$OutDir/objc"
}
if (Has "php") {
  New-Item -ItemType Directory -Force -Path "$OutDir/php" | Out-Null
  $args += "--php_out=$OutDir/php"
  $generated += "$OutDir/php"
}
if (Has "ruby") {
  New-Item -ItemType Directory -Force -Path "$OutDir/ruby" | Out-Null
  $args += "--ruby_out=$OutDir/ruby"
  $generated += "$OutDir/ruby"
}
if (Has "rust") {
  New-Item -ItemType Directory -Force -Path "$OutDir/rust" | Out-Null
  $args += "--rust_out=$OutDir/rust"
  $generated += "$OutDir/rust"
}
if (Has "go") {
  if (-not (Get-Command protoc-gen-go -ErrorAction SilentlyContinue)) {
    Write-Error "protoc-gen-go not found. Install: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
  }
  New-Item -ItemType Directory -Force -Path "$OutDir/go" | Out-Null
  $args += "--go_out=$OutDir/go", "--go_opt=paths=source_relative"
  $generated += "$OutDir/go"
}
if (Has "grpc-go") {
  if (-not (Get-Command protoc-gen-go-grpc -ErrorAction SilentlyContinue)) {
    Write-Error "protoc-gen-go-grpc not found. Install: go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
  }
  New-Item -ItemType Directory -Force -Path "$OutDir/grpc-go" | Out-Null
  $args += "--go-grpc_out=$OutDir/grpc-go", "--go-grpc_opt=paths=source_relative"
  $generated += "$OutDir/grpc-go"
}
if (Has "descriptor") {
  $args += "--descriptor_set_out=$OutDir/rotom.pb", "--include_source_info"
  $generated += "$OutDir/rotom.pb"
}

& protoc @args $ProtoFile

Write-Output "Generated into ${OutDir}/:"
foreach ($g in $generated) { Write-Output "  $g" }
