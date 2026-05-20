$ErrorActionPreference = 'Stop'

$connectUrl = 'http://localhost:38083/connectors'
$root = Split-Path -Parent $PSScriptRoot

$sourceConfig = Get-Content -Raw (Join-Path $root 'connectors\mysql-source.config.json')

Invoke-RestMethod -Method Put -Uri "$connectUrl/mysql-farmadb-source/config" -ContentType 'application/json' -Body $sourceConfig | Out-Null

for ($attempt = 1; $attempt -le 10; $attempt++) {
	try {
		$status = Invoke-RestMethod -Method Get -Uri "$connectUrl/mysql-farmadb-source/status"
		if ($status.connector.state) {
			return $status
		}
	}
	catch {
		if ($attempt -eq 10) {
			throw
		}
	}

	Start-Sleep -Seconds 1
}
