Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Configuración del Formulario Principal ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Traducción - Yakuza Ishin"
$form.Size = New-Object System.Drawing.Size(640, 480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)

# --- Título Principal ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "Yakuza Ishin!`n(Ryu ga Gotoku Ishin!)"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$title.Size = New-Object System.Drawing.Size(600, 100)
$title.Location = New-Object System.Drawing.Point(12, 50)
$form.Controls.Add($title)

# --- Botón Activar Traducción ---
$btnTranslate = New-Object System.Windows.Forms.Button
$btnTranslate.Text = "INSTALAR TRADUCCIÓN"
$btnTranslate.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$btnTranslate.Size = New-Object System.Drawing.Size(320, 70)
$btnTranslate.Location = New-Object System.Drawing.Point(152, 220)
$btnTranslate.BackColor = [System.Drawing.Color]::FromArgb(180, 0, 0)
$btnTranslate.ForeColor = [System.Drawing.Color]::White
$btnTranslate.FlatStyle = "Flat"
$btnTranslate.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnTranslate)

# --- Etiqueta de Estado ---
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Presiona el botón y selecciona la carpeta PS3_GAME."
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$statusLabel.ForeColor = [System.Drawing.Color]::LightGray
$statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$statusLabel.Size = New-Object System.Drawing.Size(600, 30)
$statusLabel.Location = New-Object System.Drawing.Point(12, 320)
$form.Controls.Add($statusLabel)

# --- Lógica de Instalación, Reestructuración y Partool ---
function Instalar-Archivos {
    $baseDirectory = $PSScriptRoot
    if ([string]::IsNullOrEmpty($baseDirectory)) {
        $baseDirectory = [AppDomain]::CurrentDomain.BaseDirectory
    }

    # Diálogo para seleccionar la carpeta PS3_GAME
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Selecciona la carpeta PS3_GAME del juego Yakuza Ishin"
    
    if ($folderBrowser.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        return
    }

    $ps3GamePath = $folderBrowser.SelectedPath

    # Validación básica de la carpeta seleccionada
    if ((Split-Path $ps3GamePath -Leaf) -ne "PS3_GAME") {
        [System.Windows.Forms.MessageBox]::Show("Por favor selecciona específicamente la carpeta llamada 'PS3_GAME'.", "Carpeta Incorrecta", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Estructura según la planilla:
    $archivos = @(
        @{ Renombrado = "2021428.pak"; Original = "PIC1.PNG";     SubRuta = "" },
        @{ Renombrado = "6661971.pak"; Original = "c01_010.usm"; SubRuta = "USRDIR\movie" },
        @{ Renombrado = "5CC0382.pak"; Original = "c01_020.usm"; SubRuta = "USRDIR\movie" },
        @{ Renombrado = "632121R.pak"; Original = "c01_030.usm"; SubRuta = "USRDIR\movie" },
        @{ Renombrado = "TFZ18HH.pak"; Original = "c01_040.usm"; SubRuta = "USRDIR\movie" },
        @{ Renombrado = "8318P11.pak"; Original = "c01_050.usm"; SubRuta = "USRDIR\movie" },
        @{ Renombrado = "521W994.pak"; Original = "c01_010.par"; SubRuta = "USRDIR\auth" },
        @{ Renombrado = "7ab5453.pak"; Original = "c01_020.par"; SubRuta = "USRDIR\auth" },
        @{ Renombrado = "06473d3.pak"; Original = "c01_030.par"; SubRuta = "USRDIR\auth" },
        @{ Renombrado = "686d647.pak"; Original = "c01_040.par"; SubRuta = "USRDIR\auth" },
        @{ Renombrado = "e160c1e.pak"; Original = "c01_050.par"; SubRuta = "USRDIR\auth" },
        @{ Renombrado = "6ac6816.pak"; Original = "c01_060.par"; SubRuta = "USRDIR\auth" },
        @{ Renombrado = "c7d32e5.pak"; Original = "c01_070.par"; SubRuta = "USRDIR\auth" }
    )

    $exitos = 0
    $errores = 0

    foreach ($item in $archivos) {
        $pathOrigen = Join-Path $baseDirectory $item.Renombrado
        $carpetaDestino = Join-Path $ps3GamePath $item.SubRuta
        $pathDestino = Join-Path $carpetaDestino $item.Original

        if (Test-Path $pathOrigen) {
            try {
                if (-not (Test-Path $carpetaDestino)) {
                    New-Item -ItemType Directory -Path $carpetaDestino -Force | Out-Null
                }

                Move-Item -Path $pathOrigen -Destination $pathDestino -Force
                $exitos++
            } catch {
                $errores++
            }
        } else {
            $errores++
        }
    }

    # --- Lógica de empacado con Partool.exe ---
    $partoolExe = Join-Path $baseDirectory "TMP\PS3_GAME\USRDIR\data\Partool.exe"
    $carpetaHact = Join-Path $baseDirectory "TMP\PS3_GAME\USRDIR\data\hact.par.unpack"

    if ((Test-Path $partoolExe) -and (Test-Path $carpetaHact)) {
        try {
            $statusLabel.Text = "Procesando hact.par.unpack con Partool.exe..."
            
            # Equivale a arrastrar la carpeta hacia Partool.exe
            $process = Start-Process -FilePath $partoolExe -ArgumentList "`"$carpetaHact`"" -WorkingDirectory $baseDirectory -PassThru -Wait
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error al ejecutar Partool.exe:`n$($_.Exception.Message)", "Error de ejecución", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        if (-not (Test-Path $partoolExe)) {
            [System.Windows.Forms.MessageBox]::Show("No se encontró 'Partool.exe' en la raíz del script.", "Archivo Faltante", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
        if (-not (Test-Path $carpetaHact)) {
            [System.Windows.Forms.MessageBox]::Show("No se encontró la carpeta en:`n$carpetaHact", "Carpeta Faltante", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    }

    # --- Resultado final ---
    if ($exitos -gt 0 -and $errores -eq 0) {
        $statusLabel.Text = "¡Traducción y empaquetado completados con éxito!"
        $statusLabel.ForeColor = [System.Drawing.Color]::LimeGreen
        [System.Windows.Forms.MessageBox]::Show("Proceso finalizado correctamente.", "¡Éxito!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } elseif ($exitos -gt 0 -and $errores -gt 0) {
        $statusLabel.Text = "Proceso terminado con advertencias."
        $statusLabel.ForeColor = [System.Drawing.Color]::Orange
        [System.Windows.Forms.MessageBox]::Show("Se renombraron $exitos archivos, pero $errores fallaron o no se encontraron.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        $statusLabel.Text = "No se encontraron archivos .pak."
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
    }
}

# --- Evento del Botón ---
$btnTranslate.Add_Click({
    Instalar-Archivos
})

# Mostrar la ventana
[void]$form.ShowDialog()