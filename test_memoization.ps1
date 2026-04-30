$url = 'https://functionprojectfibonacci3-eyf2cechdzdsaaat.eastus2-01.azurewebsites.net/api/fibonaccimemo'
$body = '{"nth":35}'

Write-Host "=== PRUEBA DE MEMOIZACION - ESTADO CALIENTE ===" 

$times_warm = @()
for ($i = 1; $i -le 3; $i++) {
    $time = (Measure-Command {
        Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json' -Body $body -ErrorAction SilentlyContinue | Out-Null
    }).TotalMilliseconds
    $times_warm += $time
    Write-Host "Llamada $i (warm): $([math]::Round($time, 2)) ms"
}

$avg_warm = [math]::Round(($times_warm | Measure-Object -Average).Average, 2)
Write-Host "Promedio estado caliente: $avg_warm ms"

Write-Host ""
Write-Host "=== REINICIANDO FUNCTION APP ===" 
Start-Sleep -Seconds 2
az functionapp restart --name FunctionProjectFibonacci3 --resource-group SCALABILITY_LAB_II -o none
Write-Host "Function App reiniciada"

Write-Host ""
Write-Host "=== PRUEBA DE MEMOIZACION - ESTADO FRIO ===" 
Start-Sleep -Seconds 5

$times_cold = @()
for ($i = 1; $i -le 3; $i++) {
    $time = (Measure-Command {
        Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json' -Body $body -ErrorAction SilentlyContinue | Out-Null
    }).TotalMilliseconds
    $times_cold += $time
    Write-Host "Llamada $i (cold): $([math]::Round($time, 2)) ms"
}

$avg_cold = [math]::Round(($times_cold | Measure-Object -Average).Average, 2)
Write-Host "Promedio estado frio: $avg_cold ms"

Write-Host ""
Write-Host "=== RESUMEN ===" 
Write-Host "Estado Caliente (Warm):"
for ($i = 0; $i -lt $times_warm.Count; $i++) {
    Write-Host "  Llamada $($i+1): $([math]::Round($times_warm[$i], 2)) ms"
}
Write-Host "  Promedio: $avg_warm ms"

Write-Host ""
Write-Host "Estado Frio (Cold):"
for ($i = 0; $i -lt $times_cold.Count; $i++) {
    Write-Host "  Llamada $($i+1): $([math]::Round($times_cold[$i], 2)) ms"
}
Write-Host "  Promedio: $avg_cold ms"

$diff = [math]::Round($avg_cold - $avg_warm, 2)
if ($avg_warm -gt 0) {
    $ratio = [math]::Round($avg_cold / $avg_warm, 2)
    Write-Host ""
    Write-Host "Diferencia (Cold - Warm): $diff ms (Cold es $ratio x mas lento)"
}
