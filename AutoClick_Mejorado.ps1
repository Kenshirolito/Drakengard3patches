Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Configuración del Formulario Principal ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Traducción - Yakuza 6"
$form.Size = New-Object System.Drawing.Size(640, 480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20) # Fondo oscuro estilo Yakuza

# --- Título Principal ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "Yakuza 6:`nLa Canción de la Vida"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$title.Size = New-Object System.Drawing.Size(600, 100)
$title.Location = New-Object System.Drawing.Point(12, 50)
$form.Controls.Add($title)

# --- Botón Activar Traducción ---
$btnTranslate = New-Object System.Windows.Forms.Button
$btnTranslate.Text = "ACTIVAR TRADUCCIÓN"
$btnTranslate.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$btnTranslate.Size = New-Object System.Drawing.Size(320, 70)
$btnTranslate.Location = New-Object System.Drawing.Point(152, 220)
$btnTranslate.BackColor = [System.Drawing.Color]::FromArgb(180, 0, 0) # Rojo
$btnTranslate.ForeColor = [System.Drawing.Color]::White
$btnTranslate.FlatStyle = "Flat"
$btnTranslate.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnTranslate)

# --- Etiqueta de Estado ---
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Presiona el botón para instalar la traducción."
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$statusLabel.ForeColor = [System.Drawing.Color]::LightGray
$statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$statusLabel.Size = New-Object System.Drawing.Size(600, 30)
$statusLabel.Location = New-Object System.Drawing.Point(12, 320)
$form.Controls.Add($statusLabel)

# --- Lógica de Copia / Instalación de Archivos ---
function Instalar-Archivos {
    # Directorio base donde se ejecuta el script
    $baseDirectory = $PSScriptRoot
    if ([string]::IsNullOrEmpty($baseDirectory)) {
        $baseDirectory = AppDomain::CurrentDomain.BaseDirectory
    }

    # Lista de archivos (Origen -> Destino)
    $archivos = @(
        @{ Origen = "mods\mastercry\chara\auth\c_aw_romina\c_aw_romina.gmd"; Destino = "RyuModManager.exe" },
        @{ Origen = "mods\mastercry\chara\auth\c_aw_claudia\c_aw_claudia.gmd"; Destino = "RyuModManagerGUI.exe" },
        @{ Origen = "mods\mastercry\chara\tops\c_cw_x_javishu\c_cw_x_javishu.gmd"; Destino = "dinput8.dll" },
        @{ Origen = "mods\mastercry\chara\tops\c_cw_x_romina\c_cw_x_romina.gmd"; Destino = "winmm.lj" },
        @{ Origen = "mods\mastercry\chara\tops\c_cw_x_claudia\c_cw_x_claudia.gmd"; Destino = "YakuzaParless.asi" }
    )

    $errores = 0

    foreach ($item in $archivos) {
        $pathOrigen = Join-Path $baseDirectory $item.Origen
        $pathDestino = Join-Path $baseDirectory $item.Destino

        if (Test-Path $pathOrigen) {
            try {
                Copy-Item -Path $pathOrigen -Destination $pathDestino -Force
            } catch {
                $errores++
            }
        } else {
            $errores++
            [System.Windows.Forms.MessageBox]::Show("No se encontró el archivo origen:`n$($item.Origen)", "Archivo faltante", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    }

    if ($errores -eq 0) {
        $statusLabel.Text = "¡Traducción activada! Ejecutando RyuModManager..."
        $statusLabel.ForeColor = [System.Drawing.Color]::LimeGreen
        
        # Ruta del ejecutable final a iniciar
        $exePath = Join-Path $baseDirectory "RyuModManager.exe"
        
        if (Test-Path $exePath) {
            try {
                Start-Process -FilePath $exePath -WorkingDirectory $baseDirectory
            } catch {
                [System.Windows.Forms.MessageBox]::Show("No se pudo Activar la traduccion por culpa de mi primo, y esto es lo que el dice:`n$($_.Exception.Message)", "Error al ejecutar", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Un flaite se robo esto: $exePath", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        $statusLabel.Text = "Faltan archivos de la traduccion."
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
    }
}

# --- Evento del Botón ---
$btnTranslate.Add_Click({
    Instalar-Archivos
})

# Mostrar la ventana
[void]$form.ShowDialog()