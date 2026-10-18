$ErrorActionPreference = 'Stop'

$expectedJarSha256 = '81a82aaea5abcc8ff68b3dfcb58b3c3c429378efd98e7433460610fecd7ae45f'
$expectedDistributionSha256 = 'fba8464465835e74f7270bbf43d6d8a8d7709ab0a43ce1aa3323f73e9aa0c612'
$expectedUrl = 'distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-all.zip'
$expectedHashLine = "distributionSha256Sum=$expectedDistributionSha256"

try {
    $root = Split-Path -Parent $PSScriptRoot
    $jarPath = Join-Path $root 'gradle/wrapper/gradle-wrapper.jar'
    $propertiesPath = Join-Path $root 'gradle/wrapper/gradle-wrapper.properties'

    if (-not (Test-Path -LiteralPath $jarPath -PathType Leaf)) {
        throw "Gradle wrapper JAR is missing: $jarPath"
    }
    if (-not (Test-Path -LiteralPath $propertiesPath -PathType Leaf)) {
        throw "Gradle wrapper properties are missing: $propertiesPath"
    }

    $actualJarSha256 = (Get-FileHash -LiteralPath $jarPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualJarSha256 -cne $expectedJarSha256) {
        throw "Gradle wrapper JAR checksum mismatch: $actualJarSha256"
    }

    $lines = @(Get-Content -LiteralPath $propertiesPath)
    $urlLines = @($lines | Where-Object { $_.StartsWith('distributionUrl=') })
    $hashLines = @($lines | Where-Object { $_.StartsWith('distributionSha256Sum=') })

    if ($urlLines.Count -ne 1 -or $urlLines[0] -cne $expectedUrl) {
        throw 'Gradle distribution URL does not match pinned Gradle 8.13.'
    }
    if ($hashLines.Count -ne 1 -or $hashLines[0] -cne $expectedHashLine) {
        throw 'Gradle distribution SHA-256 does not match the pinned checksum.'
    }

    Write-Host 'Gradle Wrapper 8.13 verified (JAR, distribution URL and SHA-256).'
    exit 0
} catch {
    [Console]::Error.WriteLine("ERROR: $($_.Exception.Message)")
    exit 1
}
