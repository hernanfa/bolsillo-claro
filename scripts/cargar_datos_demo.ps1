<#
.SYNOPSIS
    Registra exactamente 20 gastos demostrativos en el backend de Bolsillo Claro.

.DESCRIPTION
    Script interactivo para registrar 20 gastos variados y realistas con montos en dolares (USD)
    para Ecuador, distribuidos en las categorias admitidas por el servidor.
    Solicita las credenciales del usuario de forma interactiva y segura sin guardar ni mostrar
    contrasenas ni tokens en pantalla o archivos.

.PARAMETER ApiBaseUrl
    URL base del backend. Por defecto: http://localhost:8000
#>

[CmdletBinding()]
param(
    [string]$ApiBaseUrl = "http://localhost:8000"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Bolsillo Claro - Registro de 20 Gastos Demostrativos   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Este script se comunicara con la API publica de Bolsillo Claro en:"
Write-Host "  $ApiBaseUrl`n" -ForegroundColor DarkCyan

# 1. Solicitud interactiva y segura de credenciales
$email = Read-Host "Ingresa el correo electronico del usuario"
if ([string]::IsNullOrWhiteSpace($email)) {
    Write-Host "`n[ERROR] El correo no puede estar vacio." -ForegroundColor Red
    exit 1
}

$securePass = Read-Host "Ingresa la contrasena" -AsSecureString
if ($null -eq $securePass -or $securePass.Length -eq 0) {
    Write-Host "`n[ERROR] La contrasena no puede estar vacia." -ForegroundColor Red
    exit 1
}

# Deserializar temporalmente la contrasena solo para la peticion HTTP y liberar memoria
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
$plainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
$securePass = $null

Write-Host "`nAutenticando usuario..." -ForegroundColor Yellow

# 2. Obtencion de token JWT
$loginUrl = "$ApiBaseUrl/usuarios/token"
$loginBody = "username=$([uri]::EscapeDataString($email.Trim()))&password=$([uri]::EscapeDataString($plainPass))"
$plainPass = $null # Eliminada de memoria inmediatamente

$jwtToken = $null
try {
    $loginResp = Invoke-RestMethod -Uri $loginUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $loginBody
    $jwtToken = $loginResp.access_token
} catch {
    Write-Host "`n[ERROR DE AUTENTICACION]" -ForegroundColor Red
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -in @(400, 401, 404)) {
        Write-Host "Credenciales incorrectas o el usuario '$email' no esta registrado en el backend." -ForegroundColor Red
        Write-Host "Verifica el correo y la contrasena, o registrate previamente desde la app." -ForegroundColor Yellow
    } else {
        Write-Host "No fue posible conectar con el servidor backend en '$ApiBaseUrl'." -ForegroundColor Red
        Write-Host "Asegurate de que el backend FastAPI este ejecutandose en http://localhost:8000." -ForegroundColor Yellow
    }
    exit 1
}

if ([string]::IsNullOrWhiteSpace($jwtToken)) {
    Write-Host "`n[ERROR] La respuesta del servidor no incluyo un token de acceso valido." -ForegroundColor Red
    exit 1
}

Write-Host "Autenticacion exitosa. Consultando categorias admitidas..." -ForegroundColor Green

# 3. Consulta de categorias admitidas en el backend
$catUrl = "$ApiBaseUrl/gastos/categorias"
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

$admittedCategories = @()
try {
    $catResp = Invoke-RestMethod -Uri $catUrl -Method Get -Headers $authHeaders
    $admittedCategories = $catResp.categorias
} catch {
    Write-Host "`n[ERROR] No fue posible obtener la lista de categorias del servidor." -ForegroundColor Red
    $jwtToken = $null
    exit 1
}

if ($admittedCategories.Count -eq 0) {
    Write-Host "`n[ERROR] El servidor no tiene categorias disponibles." -ForegroundColor Red
    $jwtToken = $null
    exit 1
}

# Mapear o asociar dinamicamente con las categorias admitidas
function ObtenerCategoriaValida([string]$preferida, [string[]]$disponibles) {
    $encontrada = $disponibles | Where-Object { $_.ToLower() -eq $preferida.ToLower() } | Select-Object -First 1
    if ($encontrada) { return $encontrada }
    return $disponibles[0]
}

$catComida = ObtenerCategoriaValida "comida" $admittedCategories
$catTransporte = ObtenerCategoriaValida "transporte" $admittedCategories
$catEntretenimiento = ObtenerCategoriaValida "entretenimiento" $admittedCategories
$catOtros = ObtenerCategoriaValida "otros" $admittedCategories

# 4. Definicion de exactamente 20 gastos demostrativos con descripciones y montos realistas para Ecuador
$gastosDemo = @(
    # Comida (5 registros)
    @{ descripcion = 'Almuerzo ejecutivo en el centro de Quito'; monto = 3.75; categoria = $catComida; fecha = '2026-10-01' },
    @{ descripcion = 'Encebollado mixto con chifles y jugo'; monto = 4.50; categoria = $catComida; fecha = '2026-10-03' },
    @{ descripcion = 'Compras de frutas y verduras en mercado local'; monto = 12.80; categoria = $catComida; fecha = '2026-10-05' },
    @{ descripcion = 'Desayuno con bolon de verde y cafe pasado'; monto = 3.25; categoria = $catComida; fecha = '2026-10-08' },
    @{ descripcion = 'Cena ligera de tigrillo con huevo y queso'; monto = 4.00; categoria = $catComida; fecha = '2026-10-12' },

    # Transporte (5 registros)
    @{ descripcion = 'Pasaje en Metro de Quito (2 viajes)'; monto = 0.90; categoria = $catTransporte; fecha = '2026-10-02' },
    @{ descripcion = 'Carrera de taxi al terminal terrestre'; monto = 4.50; categoria = $catTransporte; fecha = '2026-10-04' },
    @{ descripcion = 'Recarga de tarjeta Trolebus y Ecovia'; monto = 5.00; categoria = $catTransporte; fecha = '2026-10-07' },
    @{ descripcion = 'Gasolina Eco para movilizacion laboral'; monto = 15.00; categoria = $catTransporte; fecha = '2026-10-10' },
    @{ descripcion = 'Pasaje interprovincial Quito a Latacunga'; monto = 3.50; categoria = $catTransporte; fecha = '2026-10-14' },

    # Entretenimiento (5 registros)
    @{ descripcion = 'Entrada a sala de cine 2D en centro comercial'; monto = 6.50; categoria = $catEntretenimiento; fecha = '2026-10-06' },
    @{ descripcion = 'Suscripcion mensual a servicio de musica'; monto = 6.49; categoria = $catEntretenimiento; fecha = '2026-10-09' },
    @{ descripcion = 'Cafeteria y postre artesanal con amigos'; monto = 7.80; categoria = $catEntretenimiento; fecha = '2026-10-13' },
    @{ descripcion = 'Entrada al Museo de la Ciudad y recorrido'; monto = 3.00; categoria = $catEntretenimiento; fecha = '2026-10-16' },
    @{ descripcion = 'Snacks y bebidas para noche de peliculas'; monto = 5.50; categoria = $catEntretenimiento; fecha = '2026-10-18' },

    # Otros (5 registros)
    @{ descripcion = 'Recarga de paquete de datos prepago celular'; monto = 10.00; categoria = $catOtros; fecha = '2026-10-11' },
    @{ descripcion = 'Articulos de aseo personal y farmacia'; monto = 11.50; categoria = $catOtros; fecha = '2026-10-15' },
    @{ descripcion = 'Fotocopias y anillado de material de estudio'; monto = 2.75; categoria = $catOtros; fecha = '2026-10-17' },
    @{ descripcion = 'Corte de cabello en peluqueria de barrio'; monto = 5.00; categoria = $catOtros; fecha = '2026-10-19' },
    @{ descripcion = 'Reparacion de calzado artesanal'; monto = 4.00; categoria = $catOtros; fecha = '2026-10-20' }
)

Write-Host "`nRegistrando $($gastosDemo.Count) gastos demostrativos en el servidor..." -ForegroundColor Cyan

# 5. Envio secuencial mediante la API publica POST /gastos/
$gastosUrl = "$ApiBaseUrl/gastos/"
$postHeaders = @{
    "Authorization" = "Bearer $jwtToken"
    "Content-Type"  = "application/json; charset=utf-8"
}

$contadorExitosos = 0
for ($i = 0; $i -lt $gastosDemo.Count; $i++) {
    $gasto = $gastosDemo[$i]
    $num = $i + 1
    $bodyJson = [System.Text.Encoding]::UTF8.GetBytes(($gasto | ConvertTo-Json -Compress))

    try {
        $resp = Invoke-RestMethod -Uri $gastosUrl -Method Post -Headers $postHeaders -Body $bodyJson
        $contadorExitosos++
        $montoStr = "{0:N2}" -f $gasto.monto
        $msg = "  [{0}/20] OK: {1} (${2}) en [{3}]" -f $num, $gasto.descripcion, $montoStr, $gasto.categoria
        Write-Host $msg -ForegroundColor Green
    } catch {
        Write-Host "`n[ERROR] Fallo el registro del gasto #$num ($($gasto.descripcion))" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errBody = $reader.ReadToEnd()
            Write-Host "Detalle del servidor: $errBody" -ForegroundColor Yellow
        } else {
            Write-Host "Detalle: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        $jwtToken = $null
        exit 1
    }
}

# 6. Limpieza del token en memoria
$jwtToken = $null

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Carga completada con exito! Se registraron $contadorExitosos gastos." -ForegroundColor Green
Write-Host " Abre la aplicacion Bolsillo Claro para visualizar la lista," -ForegroundColor White
Write-Host " el resumen por categorias y consultar al Asistente de IA." -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
