param(
    [Parameter(Mandatory = $true)]
    [string] $SqfVm
)

$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$sourcePath = Join-Path $projectRoot 'addons/path/functions/fnc_advanceFlightPath.sqf'
$headerPath = Join-Path $projectRoot 'addons/path/script_component.hpp'
$testPath = Join-Path $projectRoot '.hemtt/missions/test.Altis/rtz_path_geometry.sqf'

# Execute the production SQF body. Only its framework include is replaced;
# MAX_SKIP is taken from the production header, not duplicated in the tests.
$body = Get-Content -Raw -Encoding utf8 -LiteralPath $sourcePath
$body = [regex]::Replace($body, '(?m)^#include "script_component.hpp"\r?\n', '')
$header = Get-Content -Raw -Encoding utf8 -LiteralPath $headerPath
$maxSkip = [regex]::Match($header, '(?m)^#define MAX_SKIP\s+(\d+)').Groups[1].Value
if (!$maxSkip) { throw 'Cannot find MAX_SKIP in the production header.' }
$tests = Get-Content -Raw -Encoding utf8 -LiteralPath $testPath
$program = "#define MAX_SKIP $maxSkip`nprivate _production = {`n$body`n};`n_production call {`n$tests`n};`n"
$temporaryScript = Join-Path ([IO.Path]::GetTempPath()) ('rtz-path-geometry-' + [guid]::NewGuid().ToString('N') + '.sqf')

try {
    [IO.File]::WriteAllText($temporaryScript, $program, (New-Object Text.UTF8Encoding($false)))
    $result = & $SqfVm --automated --suppress-welcome --no-work-print --no-execute-print --no-spawn-player --max-runtime 5000 --input-sqf $temporaryScript 2>&1
    $code = $LASTEXITCODE
    $result | Write-Output
    $log = $result -join "`n"
    if ($code -ne 0 -or $log -match '\[(ERR|FAT)\]' -or $log -notmatch 'RTZ path geometry: \d+ cases passed') {
        throw "SQF-VM regression run failed (exit code $code)."
    }
} finally {
    Remove-Item -LiteralPath $temporaryScript -ErrorAction SilentlyContinue
}
