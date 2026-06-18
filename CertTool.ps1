#Requires -Version 5.1
<#
.SYNOPSIS
    CertTool - Certificate creation and conversion GUI
.DESCRIPTION
    Creates self-signed certificates via OpenSSL (no certificate store)
    or converts existing PFX files to PFX, PEM, DER and/or P7B.
    Automatically installs OpenSSL via winget if not present.
    Supports Dutch (NL) and English (EN) interface.
.NOTES
    Created by : Johannes Muller
    Version    : 1.1
    Date       : 2026-06-18
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ============================================================
#  VERTALINGEN / TRANSLATIONS
# ============================================================

$Translations = @{
    NL = @{
        # Taalkeuzescherm
        LangTitle        = "Taal kiezen"
        LangPrompt       = "Kies de taal van de interface:"

        # Hoofdmenu
        AppTitle         = "Certificaat Tool"
        MenuNew          = "  Nieuw certificaat aanmaken"
        MenuConvert      = "  Bestaand certificaat converteren"
        OpenSSLLabel     = "OpenSSL:"

        # Nieuw certificaat form
        NewCertTitle     = "Nieuw certificaat aanmaken"
        GrpCertDetails   = "Certificaatgegevens"
        FieldCN          = "Naam (CN):"
        FieldOU          = "Referentie (OU):"
        FieldO           = "Organisatie (O):"
        FieldL           = "Locatie (L):"
        FieldC           = "Land (C, 2 letters):"
        FieldKeyLen      = "Sleutellengte:"
        FieldHash        = "Hash algoritme:"
        FieldDays        = "Geldigheid (dagen):"
        GrpOutput        = "Uitvoer"
        FieldOutDir      = "Uitvoermap:"
        GrpFormats       = "Uitvoerformaten"
        BtnCreate        = "Aanmaken"
        BtnCancel        = "Annuleren"
        BtnBrowse        = "..."

        # Converteren form
        ConvertTitle     = "Bestaand certificaat converteren"
        GrpSource        = "Bronbestand"
        FieldPFXFile     = "PFX-bestand:"
        FieldPassword    = "Wachtwoord:"
        BtnConvert       = "Converteren"
        BtnBrowsePFX     = "Bladeren..."

        # Uitvoerformaten labels
        FmtPFX           = "PFX / P12"
        FmtPEM           = "PEM (cert + key)"
        FmtDER           = "DER"
        FmtP7B           = "P7B / PKCS#7"

        # Validatieberichten
        ValCNRequired    = "Naam (CN) is verplicht."
        ValOutDirReq     = "Selecteer een uitvoermap."
        ValFormatReq     = "Selecteer minimaal een uitvoerformaat."
        ValPFXInvalid    = "Selecteer een geldig PFX-bestand."
        ValTitle         = "Validatie"

        # Voortgang
        ProgressCreating = "Certificaat aanmaken voor '{0}'..."
        ProgressConvert  = "Certificaat '{0}' converteren..."

        # Resultaat
        ResultCreateTitle = "Certificaat aangemaakt"
        ResultConvertTitle = "Certificaat geconverteerd"
        ResultCreated    = "Certificaat '{0}' succesvol aangemaakt!`nBestanden opgeslagen in: {1}`nAlgoritme: RSA {2} / {3}  |  Geldig: {4} dagen"
        ResultConverted  = "Certificaat '{0}' succesvol geconverteerd!`nBestanden opgeslagen in: {1}"
        PFXPasswordLabel = "PFX-wachtwoord:"
        NewPFXPwdLabel   = "Nieuw PFX-wachtwoord:"
        BtnCopy          = "Kopieer"
        BtnCopied        = "Gekopieerd!"
        PwdWarning       = "Sla dit wachtwoord op - het wordt niet bewaard door dit script."
        BtnOK            = "OK"

        # Foutberichten
        ErrTitle         = "Fout"
        ErrGeneric       = "Er is een fout opgetreden:`n`n{0}"
        ErrKeyGen        = "Sleutel genereren mislukt:`n{0}"
        ErrCertGen       = "Certificaat aanmaken mislukt:`n{0}"
        ErrPFXExport     = "PFX export mislukt: {0}"
        ErrPEMCert       = "PEM cert export mislukt: {0}"
        ErrPEMKey        = "PEM key export mislukt: {0}"
        ErrDER           = "DER export mislukt: {0}"
        ErrP7B           = "P7B export mislukt: {0}"
        ErrExtractCert   = "Certificaat extraheren mislukt. Controleer het wachtwoord.`n{0}"
        ErrExtractKey    = "Private key extraheren mislukt.`n{0}"

        # OpenSSL berichten
        SSLNotFound      = "OpenSSL is niet gevonden op dit systeem.`n`nWil je OpenSSL automatisch installeren via winget?"
        SSLNotFoundTitle = "OpenSSL niet gevonden"
        SSLRequired      = "OpenSSL is vereist om dit script te gebruiken.`n`nDownload het handmatig via:`nhttps://slproweb.com/products/Win32OpenSSL.html"
        SSLRequiredTitle = "OpenSSL vereist"
        SSLInstalling    = "OpenSSL wordt geinstalleerd via winget...`nEven geduld. Dit kan een minuut duren."
        SSLInstallingTitle = "OpenSSL installeren"
        SSLInstallFail   = "winget niet beschikbaar of installatie mislukt.`nFout: {0}`n`nDownload OpenSSL handmatig via https://slproweb.com/products/Win32OpenSSL.html"
        SSLInstallFailTitle = "Installatie mislukt"
        SSLFound         = "OpenSSL succesvol gevonden op:`n{0}"
        SSLFoundTitle    = "Klaar"
        SSLManualPrompt  = "OpenSSL is geinstalleerd maar kan niet automatisch worden gevonden.`n`nKlik OK om het pad handmatig op te geven."
        SSLManualTitle   = "Pad opgeven"
        SSLManualFilter  = "openssl.exe|openssl.exe|Alle bestanden (*.*)|*.*"
        SSLManualInit    = "C:\Program Files"
        SSLNoPath        = "Geen geldig pad opgegeven. Script wordt afgesloten."
        SSLNoPathTitle   = "Fout"
        SSLRestartNeeded = "Herstart nodig"
    }
    EN = @{
        # Language picker
        LangTitle        = "Choose Language"
        LangPrompt       = "Select the interface language:"

        # Main menu
        AppTitle         = "Certificate Tool"
        MenuNew          = "  Create new certificate"
        MenuConvert      = "  Convert existing certificate"
        OpenSSLLabel     = "OpenSSL:"

        # New certificate form
        NewCertTitle     = "Create new certificate"
        GrpCertDetails   = "Certificate details"
        FieldCN          = "Name (CN):"
        FieldOU          = "Reference (OU):"
        FieldO           = "Organisation (O):"
        FieldL           = "Location (L):"
        FieldC           = "Country (C, 2 letters):"
        FieldKeyLen      = "Key length:"
        FieldHash        = "Hash algorithm:"
        FieldDays        = "Validity (days):"
        GrpOutput        = "Output"
        FieldOutDir      = "Output folder:"
        GrpFormats       = "Output formats"
        BtnCreate        = "Create"
        BtnCancel        = "Cancel"
        BtnBrowse        = "..."

        # Convert form
        ConvertTitle     = "Convert existing certificate"
        GrpSource        = "Source file"
        FieldPFXFile     = "PFX file:"
        FieldPassword    = "Password:"
        BtnConvert       = "Convert"
        BtnBrowsePFX     = "Browse..."

        # Format labels
        FmtPFX           = "PFX / P12"
        FmtPEM           = "PEM (cert + key)"
        FmtDER           = "DER"
        FmtP7B           = "P7B / PKCS#7"

        # Validation
        ValCNRequired    = "Name (CN) is required."
        ValOutDirReq     = "Please select an output folder."
        ValFormatReq     = "Select at least one output format."
        ValPFXInvalid    = "Please select a valid PFX file."
        ValTitle         = "Validation"

        # Progress
        ProgressCreating = "Creating certificate for '{0}'..."
        ProgressConvert  = "Converting certificate '{0}'..."

        # Result
        ResultCreateTitle = "Certificate created"
        ResultConvertTitle = "Certificate converted"
        ResultCreated    = "Certificate '{0}' created successfully!`nFiles saved to: {1}`nAlgorithm: RSA {2} / {3}  |  Valid: {4} days"
        ResultConverted  = "Certificate '{0}' converted successfully!`nFiles saved to: {1}"
        PFXPasswordLabel = "PFX password:"
        NewPFXPwdLabel   = "New PFX password:"
        BtnCopy          = "Copy"
        BtnCopied        = "Copied!"
        PwdWarning       = "Save this password - it is not stored by this script."
        BtnOK            = "OK"

        # Error messages
        ErrTitle         = "Error"
        ErrGeneric       = "An error occurred:`n`n{0}"
        ErrKeyGen        = "Key generation failed:`n{0}"
        ErrCertGen       = "Certificate creation failed:`n{0}"
        ErrPFXExport     = "PFX export failed: {0}"
        ErrPEMCert       = "PEM certificate export failed: {0}"
        ErrPEMKey        = "PEM key export failed: {0}"
        ErrDER           = "DER export failed: {0}"
        ErrP7B           = "P7B export failed: {0}"
        ErrExtractCert   = "Certificate extraction failed. Check the password.`n{0}"
        ErrExtractKey    = "Private key extraction failed.`n{0}"

        # OpenSSL messages
        SSLNotFound      = "OpenSSL was not found on this system.`n`nWould you like to install OpenSSL automatically via winget?"
        SSLNotFoundTitle = "OpenSSL not found"
        SSLRequired      = "OpenSSL is required to use this tool.`n`nDownload it manually from:`nhttps://slproweb.com/products/Win32OpenSSL.html"
        SSLRequiredTitle = "OpenSSL required"
        SSLInstalling    = "Installing OpenSSL via winget...`nPlease wait. This may take a minute."
        SSLInstallingTitle = "Installing OpenSSL"
        SSLInstallFail   = "winget is not available or installation failed.`nError: {0}`n`nDownload OpenSSL manually from https://slproweb.com/products/Win32OpenSSL.html"
        SSLInstallFailTitle = "Installation failed"
        SSLFound         = "OpenSSL found at:`n{0}"
        SSLFoundTitle    = "Done"
        SSLManualPrompt  = "OpenSSL was installed but cannot be located automatically.`n`nClick OK to browse for openssl.exe manually."
        SSLManualTitle   = "Locate OpenSSL"
        SSLManualFilter  = "openssl.exe|openssl.exe|All files (*.*)|*.*"
        SSLManualInit    = "C:\Program Files"
        SSLNoPath        = "No valid path provided. Exiting."
        SSLNoPathTitle   = "Error"
        SSLRestartNeeded = "Restart required"
    }
}

# ============================================================
#  OPENSSL DETECTIE & INSTALLATIE
# ============================================================

function Find-OpenSSL {
    $fromPath = Get-Command openssl -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
    if ($fromPath -and (Test-Path $fromPath)) { return $fromPath }

    $knownPaths = @(
        "$env:ProgramFiles\OpenSSL-Win64\bin\openssl.exe",
        "$env:ProgramFiles\OpenSSL\bin\openssl.exe",
        "${env:ProgramFiles(x86)}\OpenSSL-Win32\bin\openssl.exe",
        "C:\Program Files\OpenSSL-Win64\bin\openssl.exe",
        "C:\Program Files\OpenSSL\bin\openssl.exe",
        "C:\OpenSSL-Win64\bin\openssl.exe",
        "C:\OpenSSL\bin\openssl.exe"
    )
    $found = $knownPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($found) { return $found }

    $searchRoots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, "C:\") | Where-Object { $_ }
    foreach ($root in $searchRoots) {
        $hit = Get-ChildItem -Path $root -Filter "openssl.exe" -Recurse -ErrorAction SilentlyContinue |
               Select-Object -First 1 -ExpandProperty FullName
        if ($hit) { return $hit }
    }
    return $null
}

function Test-IsAdmin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-OpenSSL {
    # OpenSSL detectie loopt voor taalkeuze - gebruik Engels als fallback
    $t = if ($script:T) { $script:T } else { $Translations.EN }

    $path = Find-OpenSSL
    if ($path) { return $path }

    $answer = [System.Windows.Forms.MessageBox]::Show(
        $t.SSLNotFound, $t.SSLNotFoundTitle,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) {
        [System.Windows.Forms.MessageBox]::Show($t.SSLRequired, $t.SSLRequiredTitle,
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        exit
    }

    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = $t.SSLInstallingTitle
    $dlg.Size = New-Object System.Drawing.Size(440, 140)
    $dlg.StartPosition = "CenterScreen"
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ControlBox = $false
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $t.SSLInstalling
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lbl.Location = New-Object System.Drawing.Point(20, 30)
    $lbl.AutoSize = $true
    $dlg.Controls.Add($lbl)
    $dlg.Show(); $dlg.Refresh()

    try {
        $args = "install --id ShiningLight.OpenSSL -e --accept-package-agreements --accept-source-agreements --silent"
        if (-not (Test-IsAdmin)) { $args += " --scope user" }
        Start-Process winget -ArgumentList $args -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop | Out-Null
    } catch {
        $dlg.Close()
        [System.Windows.Forms.MessageBox]::Show(
            ($t.SSLInstallFail -f $_), $t.SSLInstallFailTitle,
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
    $dlg.Close()

    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH","User")

    $path = Find-OpenSSL
    if ($path) {
        [System.Windows.Forms.MessageBox]::Show(
            ($t.SSLFound -f $path), $t.SSLFoundTitle,
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return $path
    }

    [System.Windows.Forms.MessageBox]::Show($t.SSLManualPrompt, $t.SSLManualTitle,
        [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)

    $dlgFile = New-Object System.Windows.Forms.OpenFileDialog
    $dlgFile.Title = $t.SSLManualTitle
    $dlgFile.Filter = $t.SSLManualFilter
    $dlgFile.InitialDirectory = $t.SSLManualInit
    if ($dlgFile.ShowDialog() -eq "OK" -and (Test-Path $dlgFile.FileName)) {
        return $dlgFile.FileName
    }

    [System.Windows.Forms.MessageBox]::Show($t.SSLNoPath, $t.SSLNoPathTitle,
        [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# ============================================================
#  HULPFUNCTIES
# ============================================================

function Get-RandomPassword {
    param([int]$Length = 16, [int]$NonAlpha = 2)
    Add-Type -AssemblyName 'System.Web'
    return [System.Web.Security.Membership]::GeneratePassword($Length, $NonAlpha)
}

function Invoke-OpenSSL {
    param([string]$Arguments, [string]$WorkDir = $env:TEMP)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $script:OpenSSLPath
    $psi.Arguments = $Arguments
    $psi.WorkingDirectory = $WorkDir
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute  = $false
    $psi.CreateNoWindow   = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return [PSCustomObject]@{ ExitCode = $p.ExitCode; Out = $stdout; Err = $stderr }
}

function New-TempDir {
    $path = Join-Path $env:TEMP "CertTool_$(Get-Random)"
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    return $path
}

# ============================================================
#  STYLING HELPERS
# ============================================================

$ScriptVersion = "1.1"
$ScriptAuthor  = "Johannes Muller"
$ColorPrimary  = [System.Drawing.Color]::FromArgb(0, 120, 212)
$ColorBg       = [System.Drawing.Color]::FromArgb(250, 250, 250)
$FontUI        = New-Object System.Drawing.Font("Segoe UI", 9)
$FontBold      = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$FontTitle     = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)

function New-StyledButton {
    param([string]$Text, [int]$X, [int]$Y, [int]$W = 120, [int]$H = 32, [bool]$Primary = $false)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $Text
    $btn.Location = New-Object System.Drawing.Point($X, $Y)
    $btn.Size = New-Object System.Drawing.Size($W, $H)
    $btn.Font = $FontBold
    $btn.FlatStyle = "Flat"
    if ($Primary) {
        $btn.BackColor = $ColorPrimary
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.FlatAppearance.BorderSize = 0
    } else {
        $btn.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
        $btn.ForeColor = [System.Drawing.Color]::Black
    }
    return $btn
}

function New-FormBase {
    param([string]$Title, [int]$W, [int]$H)
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Title
    $f.Size = New-Object System.Drawing.Size($W, $H)
    $f.StartPosition = "CenterScreen"
    $f.FormBorderStyle = "FixedDialog"
    $f.MaximizeBox = $false
    $f.BackColor = $ColorBg
    $f.Font = $FontUI
    return $f
}

# ============================================================
#  TAALKEUZESCHERM
# ============================================================

function Show-LanguagePicker {
    $f = New-FormBase "CertTool" 340 200
    $f.FormBorderStyle = "FixedDialog"

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "CertTool v$ScriptVersion"
    $lbl.Font = $FontTitle
    $lbl.Location = New-Object System.Drawing.Point(20, 18)
    $lbl.AutoSize = $true
    $f.Controls.Add($lbl)

    $lblSub = New-Object System.Windows.Forms.Label
    $lblSub.Text = "Choose language / Kies taal:"
    $lblSub.Font = $FontUI
    $lblSub.Location = New-Object System.Drawing.Point(20, 56)
    $lblSub.AutoSize = $true
    $f.Controls.Add($lblSub)

    $btnNL = New-StyledButton "Nederlands" 20 82 135 42 $true
    $btnNL.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btnNL.Add_Click({ $f.Tag = "NL"; $f.Close() })
    $f.Controls.Add($btnNL)

    $btnEN = New-StyledButton "English" 165 82 135 42 $false
    $btnEN.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $btnEN.Add_Click({ $f.Tag = "EN"; $f.Close() })
    $f.Controls.Add($btnEN)

    $lblAuthor = New-Object System.Windows.Forms.Label
    $lblAuthor.Text = "Created by: $ScriptAuthor"
    $lblAuthor.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $lblAuthor.ForeColor = [System.Drawing.Color]::Gray
    $lblAuthor.Location = New-Object System.Drawing.Point(20, 148)
    $lblAuthor.AutoSize = $true
    $f.Controls.Add($lblAuthor)

    $f.ShowDialog() | Out-Null
    return $f.Tag
}

# ============================================================
#  HOOFDMENU
# ============================================================

function Show-MainMenu {
    $t = $script:T
    $f = New-FormBase "$($t.AppTitle) v$ScriptVersion" 400 265

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $t.AppTitle
    $lbl.Font = $FontTitle
    $lbl.Location = New-Object System.Drawing.Point(20, 18)
    $lbl.AutoSize = $true
    $f.Controls.Add($lbl)

    $sep = New-Object System.Windows.Forms.Panel
    $sep.Location = New-Object System.Drawing.Point(20, 52)
    $sep.Size = New-Object System.Drawing.Size(345, 1)
    $sep.BackColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
    $f.Controls.Add($sep)

    $btnNew = New-StyledButton $t.MenuNew 20 68 345 46 $true
    $btnNew.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btnNew.TextAlign = "MiddleLeft"
    $btnNew.Add_Click({ $f.Tag = "new"; $f.Close() })
    $f.Controls.Add($btnNew)

    $btnConv = New-StyledButton $t.MenuConvert 20 124 345 46 $false
    $btnConv.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $btnConv.TextAlign = "MiddleLeft"
    $btnConv.Add_Click({ $f.Tag = "convert"; $f.Close() })
    $f.Controls.Add($btnConv)

    $lblAuthor = New-Object System.Windows.Forms.Label
    $lblAuthor.Text = "v$ScriptVersion  |  Created by: $ScriptAuthor"
    $lblAuthor.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
    $lblAuthor.ForeColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
    $lblAuthor.Location = New-Object System.Drawing.Point(20, 183)
    $lblAuthor.Size = New-Object System.Drawing.Size(345, 14)
    $f.Controls.Add($lblAuthor)

    $lblSSL = New-Object System.Windows.Forms.Label
    $lblSSL.Text = "$($t.OpenSSLLabel) $($script:OpenSSLPath)"
    $lblSSL.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $lblSSL.ForeColor = [System.Drawing.Color]::Gray
    $lblSSL.Location = New-Object System.Drawing.Point(20, 198)
    $lblSSL.Size = New-Object System.Drawing.Size(345, 14)
    $f.Controls.Add($lblSSL)

    $f.ShowDialog() | Out-Null
    return $f.Tag
}

# ============================================================
#  NIEUW CERTIFICAAT FORM
# ============================================================

function Show-NewCertForm {
    $t = $script:T
    $f = New-FormBase $t.NewCertTitle 500 590
    $y = 15

    $grpCert = New-Object System.Windows.Forms.GroupBox
    $grpCert.Text = $t.GrpCertDetails
    $grpCert.Location = New-Object System.Drawing.Point(15, $y)
    $grpCert.Size = New-Object System.Drawing.Size(460, 255)
    $grpCert.Font = $FontBold
    $f.Controls.Add($grpCert)

    $controls = @{}
    $gy = 22

    function Add-Field {
        param($parent, $label, $key, $default = "", $isCombo = $false, $items = @(), $gy)
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $label
        $lbl.Location = New-Object System.Drawing.Point(12, ($gy + 3))
        $lbl.Size = New-Object System.Drawing.Size(130, 18)
        $lbl.Font = $FontUI
        $parent.Controls.Add($lbl)
        if ($isCombo) {
            $ctrl = New-Object System.Windows.Forms.ComboBox
            $ctrl.DropDownStyle = "DropDownList"
            foreach ($i in $items) { $ctrl.Items.Add($i) | Out-Null }
            $ctrl.SelectedItem = $default
        } else {
            $ctrl = New-Object System.Windows.Forms.TextBox
            $ctrl.Text = $default
        }
        $ctrl.Location = New-Object System.Drawing.Point(148, $gy)
        $ctrl.Size = New-Object System.Drawing.Size(295, 24)
        $ctrl.Font = $FontUI
        $parent.Controls.Add($ctrl)
        return $ctrl
    }

    $controls["CN"]   = Add-Field $grpCert $t.FieldCN   "CN"   ""         $false @()                                                      $gy; $gy += 34
    $controls["OU"]   = Add-Field $grpCert $t.FieldOU   "OU"   ""         $false @()                                                      $gy; $gy += 34
    $controls["O"]    = Add-Field $grpCert $t.FieldO    "O"    "Proxsys*" $false @()                                                      $gy; $gy += 34
    $controls["L"]    = Add-Field $grpCert $t.FieldL    "L"    ""         $false @()                                                      $gy; $gy += 34
    $controls["C"]    = Add-Field $grpCert $t.FieldC    "C"    "NL"       $false @()                                                      $gy; $gy += 34
    $controls["Key"]  = Add-Field $grpCert $t.FieldKeyLen "Key" "2048"    $true  @("2048","4096")                                         $gy; $gy += 34
    $controls["Hash"] = Add-Field $grpCert $t.FieldHash "Hash" "SHA384"   $true  @("SHA256","SHA384","SHA512")                            $gy; $gy += 34
    $controls["Days"] = Add-Field $grpCert $t.FieldDays "Days" "365"      $true  @("30","60","90","120","150","180","365","730","1095","1825") $gy

    $y += 265

    # Uitvoer
    $grpOut = New-Object System.Windows.Forms.GroupBox
    $grpOut.Text = $t.GrpOutput
    $grpOut.Location = New-Object System.Drawing.Point(15, $y)
    $grpOut.Size = New-Object System.Drawing.Size(460, 70)
    $grpOut.Font = $FontBold
    $f.Controls.Add($grpOut)

    $lblDir = New-Object System.Windows.Forms.Label
    $lblDir.Text = $t.FieldOutDir
    $lblDir.Location = New-Object System.Drawing.Point(12, 28)
    $lblDir.Size = New-Object System.Drawing.Size(95, 18)
    $lblDir.Font = $FontUI
    $grpOut.Controls.Add($lblDir)

    $txtDir = New-Object System.Windows.Forms.TextBox
    $txtDir.Location = New-Object System.Drawing.Point(112, 25)
    $txtDir.Size = New-Object System.Drawing.Size(265, 24)
    $txtDir.Font = $FontUI
    $grpOut.Controls.Add($txtDir)

    $btnDir = New-Object System.Windows.Forms.Button
    $btnDir.Text = $t.BtnBrowse
    $btnDir.Location = New-Object System.Drawing.Point(382, 25)
    $btnDir.Size = New-Object System.Drawing.Size(35, 24)
    $btnDir.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($dlg.ShowDialog() -eq "OK") { $txtDir.Text = $dlg.SelectedPath }
    })
    $grpOut.Controls.Add($btnDir)

    $y += 80

    # Uitvoerformaten
    $grpFmt = New-Object System.Windows.Forms.GroupBox
    $grpFmt.Text = $t.GrpFormats
    $grpFmt.Location = New-Object System.Drawing.Point(15, $y)
    $grpFmt.Size = New-Object System.Drawing.Size(460, 90)
    $grpFmt.Font = $FontBold
    $f.Controls.Add($grpFmt)

    $chkPFX = New-Object System.Windows.Forms.CheckBox; $chkPFX.Text = $t.FmtPFX; $chkPFX.Location = New-Object System.Drawing.Point(12, 22);  $chkPFX.AutoSize = $true; $chkPFX.Checked = $true; $chkPFX.Font = $FontUI
    $chkPEM = New-Object System.Windows.Forms.CheckBox; $chkPEM.Text = $t.FmtPEM; $chkPEM.Location = New-Object System.Drawing.Point(130, 22); $chkPEM.AutoSize = $true; $chkPEM.Font = $FontUI
    $chkDER = New-Object System.Windows.Forms.CheckBox; $chkDER.Text = $t.FmtDER; $chkDER.Location = New-Object System.Drawing.Point(290, 22); $chkDER.AutoSize = $true; $chkDER.Font = $FontUI
    $chkP7B = New-Object System.Windows.Forms.CheckBox; $chkP7B.Text = $t.FmtP7B; $chkP7B.Location = New-Object System.Drawing.Point(12, 55);  $chkP7B.AutoSize = $true; $chkP7B.Font = $FontUI
    $grpFmt.Controls.AddRange(@($chkPFX, $chkPEM, $chkDER, $chkP7B))

    $y += 100

    $btnOK = New-StyledButton $t.BtnCreate ($f.ClientSize.Width - 265) $y 120 32 $true
    $btnOK.Add_Click({
        if (-not $controls["CN"].Text.Trim()) {
            [System.Windows.Forms.MessageBox]::Show($t.ValCNRequired, $t.ValTitle,
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning); return
        }
        if (-not $txtDir.Text.Trim()) {
            [System.Windows.Forms.MessageBox]::Show($t.ValOutDirReq, $t.ValTitle,
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning); return
        }
        if (-not ($chkPFX.Checked -or $chkPEM.Checked -or $chkDER.Checked -or $chkP7B.Checked)) {
            [System.Windows.Forms.MessageBox]::Show($t.ValFormatReq, $t.ValTitle,
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning); return
        }
        $f.Tag = [PSCustomObject]@{
            CN = $controls["CN"].Text.Trim(); OU = $controls["OU"].Text.Trim()
            O  = $controls["O"].Text.Trim();  L  = $controls["L"].Text.Trim()
            C  = $controls["C"].Text.Trim()
            KeyLen = $controls["Key"].SelectedItem
            Hash   = $controls["Hash"].SelectedItem
            Days   = $controls["Days"].SelectedItem
            OutDir = $txtDir.Text.Trim()
            FmtPFX = $chkPFX.Checked; FmtPEM = $chkPEM.Checked
            FmtDER = $chkDER.Checked; FmtP7B = $chkP7B.Checked
        }
        $f.DialogResult = [System.Windows.Forms.DialogResult]::OK; $f.Close()
    })
    $f.Controls.Add($btnOK)

    $btnCancel = New-StyledButton $t.BtnCancel ($f.ClientSize.Width - 135) $y 110 32 $false
    $btnCancel.Add_Click({ $f.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $f.Close() })
    $f.Controls.Add($btnCancel)
    $f.AcceptButton = $btnOK; $f.CancelButton = $btnCancel

    if ($f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $f.Tag }
    return $null
}

# ============================================================
#  CONVERTEREN FORM
# ============================================================

function Show-ConvertForm {
    $t = $script:T
    $f = New-FormBase $t.ConvertTitle 500 370
    $y = 15

    $grpSrc = New-Object System.Windows.Forms.GroupBox
    $grpSrc.Text = $t.GrpSource
    $grpSrc.Location = New-Object System.Drawing.Point(15, $y)
    $grpSrc.Size = New-Object System.Drawing.Size(460, 110)
    $grpSrc.Font = $FontBold
    $f.Controls.Add($grpSrc)

    $lblPFX = New-Object System.Windows.Forms.Label; $lblPFX.Text = $t.FieldPFXFile; $lblPFX.Location = New-Object System.Drawing.Point(12, 28); $lblPFX.Size = New-Object System.Drawing.Size(100,18); $lblPFX.Font = $FontUI
    $grpSrc.Controls.Add($lblPFX)
    $txtPFX = New-Object System.Windows.Forms.TextBox; $txtPFX.Location = New-Object System.Drawing.Point(116, 25); $txtPFX.Size = New-Object System.Drawing.Size(230, 24); $txtPFX.Font = $FontUI
    $grpSrc.Controls.Add($txtPFX)
    $btnPFX = New-Object System.Windows.Forms.Button; $btnPFX.Text = $t.BtnBrowsePFX; $btnPFX.Location = New-Object System.Drawing.Point(352, 25); $btnPFX.Size = New-Object System.Drawing.Size(92, 24)
    $btnPFX.Add_Click({
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = "PFX / P12 (*.pfx;*.p12)|*.pfx;*.p12|*.*|*.*"
        if ($dlg.ShowDialog() -eq "OK") { $txtPFX.Text = $dlg.FileName }
    })
    $grpSrc.Controls.Add($btnPFX)

    $lblPwd = New-Object System.Windows.Forms.Label; $lblPwd.Text = $t.FieldPassword; $lblPwd.Location = New-Object System.Drawing.Point(12, 68); $lblPwd.Size = New-Object System.Drawing.Size(100,18); $lblPwd.Font = $FontUI
    $grpSrc.Controls.Add($lblPwd)
    $txtPwd = New-Object System.Windows.Forms.TextBox; $txtPwd.Location = New-Object System.Drawing.Point(116, 65); $txtPwd.Size = New-Object System.Drawing.Size(200, 24); $txtPwd.PasswordChar = [char]0x25CF; $txtPwd.Font = $FontUI
    $grpSrc.Controls.Add($txtPwd)

    $y += 120

    $grpOut = New-Object System.Windows.Forms.GroupBox
    $grpOut.Text = $t.GrpOutput
    $grpOut.Location = New-Object System.Drawing.Point(15, $y)
    $grpOut.Size = New-Object System.Drawing.Size(460, 65)
    $grpOut.Font = $FontBold
    $f.Controls.Add($grpOut)

    $lblDir = New-Object System.Windows.Forms.Label; $lblDir.Text = $t.FieldOutDir; $lblDir.Location = New-Object System.Drawing.Point(12, 28); $lblDir.Size = New-Object System.Drawing.Size(100,18); $lblDir.Font = $FontUI
    $grpOut.Controls.Add($lblDir)
    $txtDir = New-Object System.Windows.Forms.TextBox; $txtDir.Location = New-Object System.Drawing.Point(116, 25); $txtDir.Size = New-Object System.Drawing.Size(255, 24); $txtDir.Font = $FontUI
    $grpOut.Controls.Add($txtDir)
    $btnDir = New-Object System.Windows.Forms.Button; $btnDir.Text = $t.BtnBrowse; $btnDir.Location = New-Object System.Drawing.Point(378, 25); $btnDir.Size = New-Object System.Drawing.Size(35, 24)
    $btnDir.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($dlg.ShowDialog() -eq "OK") { $txtDir.Text = $dlg.SelectedPath }
    })
    $grpOut.Controls.Add($btnDir)

    $y += 75

    $grpFmt = New-Object System.Windows.Forms.GroupBox
    $grpFmt.Text = $t.GrpFormats
    $grpFmt.Location = New-Object System.Drawing.Point(15, $y)
    $grpFmt.Size = New-Object System.Drawing.Size(460, 90)
    $grpFmt.Font = $FontBold
    $f.Controls.Add($grpFmt)

    $chkPFX = New-Object System.Windows.Forms.CheckBox; $chkPFX.Text = $t.FmtPFX; $chkPFX.Location = New-Object System.Drawing.Point(12, 22);  $chkPFX.AutoSize = $true; $chkPFX.Font = $FontUI
    $chkPEM = New-Object System.Windows.Forms.CheckBox; $chkPEM.Text = $t.FmtPEM; $chkPEM.Location = New-Object System.Drawing.Point(130, 22); $chkPEM.AutoSize = $true; $chkPEM.Checked = $true; $chkPEM.Font = $FontUI
    $chkDER = New-Object System.Windows.Forms.CheckBox; $chkDER.Text = $t.FmtDER; $chkDER.Location = New-Object System.Drawing.Point(290, 22); $chkDER.AutoSize = $true; $chkDER.Font = $FontUI
    $chkP7B = New-Object System.Windows.Forms.CheckBox; $chkP7B.Text = $t.FmtP7B; $chkP7B.Location = New-Object System.Drawing.Point(12, 55);  $chkP7B.AutoSize = $true; $chkP7B.Font = $FontUI
    $grpFmt.Controls.AddRange(@($chkPFX, $chkPEM, $chkDER, $chkP7B))

    $y += 100

    $btnOK = New-StyledButton $t.BtnConvert ($f.ClientSize.Width - 265) $y 130 32 $true
    $btnOK.Add_Click({
        if (-not $txtPFX.Text -or -not (Test-Path $txtPFX.Text)) {
            [System.Windows.Forms.MessageBox]::Show($t.ValPFXInvalid, $t.ValTitle,
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning); return
        }
        if (-not $txtDir.Text.Trim()) {
            [System.Windows.Forms.MessageBox]::Show($t.ValOutDirReq, $t.ValTitle,
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning); return
        }
        if (-not ($chkPFX.Checked -or $chkPEM.Checked -or $chkDER.Checked -or $chkP7B.Checked)) {
            [System.Windows.Forms.MessageBox]::Show($t.ValFormatReq, $t.ValTitle,
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning); return
        }
        $f.Tag = [PSCustomObject]@{
            PFXPath  = $txtPFX.Text; Password = $txtPwd.Text
            OutDir   = $txtDir.Text.Trim()
            FmtPFX   = $chkPFX.Checked; FmtPEM = $chkPEM.Checked
            FmtDER   = $chkDER.Checked; FmtP7B = $chkP7B.Checked
        }
        $f.DialogResult = [System.Windows.Forms.DialogResult]::OK; $f.Close()
    })
    $f.Controls.Add($btnOK)

    $btnCancel = New-StyledButton $t.BtnCancel ($f.ClientSize.Width - 125) $y 110 32 $false
    $btnCancel.Add_Click({ $f.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $f.Close() })
    $f.Controls.Add($btnCancel)
    $f.AcceptButton = $btnOK; $f.CancelButton = $btnCancel

    if ($f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $f.Tag }
    return $null
}

# ============================================================
#  RESULTAAT FORM
# ============================================================

function Show-Result {
    param([string]$Title, [string]$Message, [string]$Password = "", [string]$PasswordLabel = "")
    $t = $script:T
    $hasPassword = $Password -ne ""
    $formHeight  = if ($hasPassword) { 280 } else { 200 }

    $f = New-FormBase $Title 460 $formHeight
    $f.FormBorderStyle = "FixedDialog"
    $f.MaximizeBox = $false

    $lblMsg = New-Object System.Windows.Forms.Label
    $lblMsg.Text = $Message
    $lblMsg.Font = $FontUI
    $lblMsg.Location = New-Object System.Drawing.Point(20, 18)
    $lblMsg.Size = New-Object System.Drawing.Size(415, 80)
    $f.Controls.Add($lblMsg)

    if ($hasPassword) {
        $lblPwd = New-Object System.Windows.Forms.Label
        $lblPwd.Text = $PasswordLabel
        $lblPwd.Font = $FontBold
        $lblPwd.Location = New-Object System.Drawing.Point(20, 108)
        $lblPwd.AutoSize = $true
        $f.Controls.Add($lblPwd)

        $txtPwd = New-Object System.Windows.Forms.TextBox
        $txtPwd.Text = $Password
        $txtPwd.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
        $txtPwd.ReadOnly = $true
        $txtPwd.Location = New-Object System.Drawing.Point(20, 132)
        $txtPwd.Size = New-Object System.Drawing.Size(305, 26)
        $txtPwd.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
        $txtPwd.BorderStyle = "FixedSingle"
        $f.Controls.Add($txtPwd)

        $btnCopy = New-StyledButton $t.BtnCopy 332 131 95 28 $true
        $btnCopy.Add_Click({
            [System.Windows.Forms.Clipboard]::SetText($Password)
            $btnCopy.Text = $t.BtnCopied
            $btnCopy.BackColor = [System.Drawing.Color]::FromArgb(16, 137, 62)
        })
        $f.Controls.Add($btnCopy)

        $lblWarn = New-Object System.Windows.Forms.Label
        $lblWarn.Text = $t.PwdWarning
        $lblWarn.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
        $lblWarn.ForeColor = [System.Drawing.Color]::FromArgb(180, 60, 0)
        $lblWarn.Location = New-Object System.Drawing.Point(20, 166)
        $lblWarn.Size = New-Object System.Drawing.Size(415, 18)
        $f.Controls.Add($lblWarn)
    }

    $btnOK = New-StyledButton $t.BtnOK (($f.ClientSize.Width - 90) / 2) ($formHeight - 68) 90 32 $false
    $btnOK.Add_Click({ $f.Close() })
    $f.Controls.Add($btnOK)
    $f.AcceptButton = $btnOK

    $f.Add_Shown({ if ($hasPassword) { $txtPwd.SelectAll(); $txtPwd.Focus() } })
    $f.ShowDialog() | Out-Null
}

# ============================================================
#  VOORTGANG FORM
# ============================================================

function Show-Progress {
    param([string]$Message)
    $f = New-FormBase "..." 400 110
    $f.ControlBox = $false
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $Message
    $lbl.Font = $FontUI
    $lbl.Location = New-Object System.Drawing.Point(20, 35)
    $lbl.Size = New-Object System.Drawing.Size(350, 40)
    $lbl.TextAlign = "MiddleCenter"
    $f.Controls.Add($lbl)
    $f.Show(); $f.Refresh()
    return $f
}

# ============================================================
#  UITVOER CONVERSIES
# ============================================================

function Export-Formats {
    param($CertFile, $KeyFile, $BaseName, $OutDir, $Password, $Cfg)
    $t = $script:T

    if ($Cfg.FmtPFX) {
        $out = Join-Path $OutDir "$BaseName.pfx"
        $r = Invoke-OpenSSL "pkcs12 -export -in `"$CertFile`" -inkey `"$KeyFile`" -out `"$out`" -passout pass:`"$Password`"" $OutDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrPFXExport -f $r.Err) }
    }
    if ($Cfg.FmtPEM) {
        $r = Invoke-OpenSSL "x509 -in `"$CertFile`" -out `"$(Join-Path $OutDir "$BaseName.crt")`" -outform PEM" $OutDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrPEMCert -f $r.Err) }
        $r = Invoke-OpenSSL "pkey -in `"$KeyFile`" -out `"$(Join-Path $OutDir "$BaseName.key")`"" $OutDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrPEMKey -f $r.Err) }
    }
    if ($Cfg.FmtDER) {
        $r = Invoke-OpenSSL "x509 -in `"$CertFile`" -out `"$(Join-Path $OutDir "$BaseName.der")`" -outform DER" $OutDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrDER -f $r.Err) }
    }
    if ($Cfg.FmtP7B) {
        $r = Invoke-OpenSSL "crl2pkcs7 -nocrl -certfile `"$CertFile`" -out `"$(Join-Path $OutDir "$BaseName.p7b")`"" $OutDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrP7B -f $r.Err) }
    }
}

# ============================================================
#  NIEUW CERTIFICAAT AANMAKEN
# ============================================================

function New-Certificate {
    param($Cfg)
    $t = $script:T
    $tmpDir   = New-TempDir
    $baseName = ($Cfg.CN -replace '[^\w\-]', '_')
    if (-not (Test-Path $Cfg.OutDir)) { New-Item -ItemType Directory -Path $Cfg.OutDir -Force | Out-Null }

    $keyFile  = Join-Path $tmpDir "$baseName.key"
    $certFile = Join-Path $tmpDir "$baseName.crt"
    $password = Get-RandomPassword
    $prog     = Show-Progress ($t.ProgressCreating -f $Cfg.CN)

    try {
        $subject = "/CN=$($Cfg.CN)"
        if ($Cfg.OU) { $subject += "/OU=$($Cfg.OU)" }
        if ($Cfg.O)  { $subject += "/O=$($Cfg.O)" }
        if ($Cfg.L)  { $subject += "/L=$($Cfg.L)" }
        if ($Cfg.C)  { $subject += "/C=$($Cfg.C)" }

        $r = Invoke-OpenSSL "genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$($Cfg.KeyLen) -out `"$keyFile`"" $tmpDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrKeyGen -f $r.Err) }

        $r = Invoke-OpenSSL "req -new -x509 -key `"$keyFile`" -out `"$certFile`" -days $($Cfg.Days) -subj `"$subject`" -$($Cfg.Hash.ToLower())" $tmpDir
        if ($r.ExitCode -ne 0) { throw ($t.ErrCertGen -f $r.Err) }

        Export-Formats -CertFile $certFile -KeyFile $keyFile -BaseName $baseName `
                       -OutDir $Cfg.OutDir -Password $password -Cfg $Cfg

        $prog.Close()
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

        $msg    = $t.ResultCreated -f $Cfg.CN, $Cfg.OutDir, $Cfg.KeyLen, $Cfg.Hash, $Cfg.Days
        $pfxPwd = if ($Cfg.FmtPFX) { $password } else { "" }
        Show-Result -Title $t.ResultCreateTitle -Message $msg -Password $pfxPwd -PasswordLabel $t.PFXPasswordLabel

    } catch {
        $prog.Close()
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show(($t.ErrGeneric -f $_), $t.ErrTitle,
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# ============================================================
#  BESTAAND PFX CONVERTEREN
# ============================================================

function Convert-ExistingPFX {
    param($Cfg)
    $t = $script:T
    $tmpDir   = New-TempDir
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Cfg.PFXPath)
    if (-not (Test-Path $Cfg.OutDir)) { New-Item -ItemType Directory -Path $Cfg.OutDir -Force | Out-Null }

    $certFile   = Join-Path $tmpDir "$baseName.crt"
    $keyFile    = Join-Path $tmpDir "$baseName.key"
    $newPassword = Get-RandomPassword
    $prog       = Show-Progress ($t.ProgressConvert -f $baseName)

    try {
        $passIn = "pass:`"$($Cfg.Password)`""

        $r = Invoke-OpenSSL "pkcs12 -in `"$($Cfg.PFXPath)`" -nokeys -clcerts -out `"$certFile`" -passin $passIn -legacy" $tmpDir
        if ($r.ExitCode -ne 0) {
            $r = Invoke-OpenSSL "pkcs12 -in `"$($Cfg.PFXPath)`" -nokeys -clcerts -out `"$certFile`" -passin $passIn" $tmpDir
            if ($r.ExitCode -ne 0) { throw ($t.ErrExtractCert -f $r.Err) }
        }

        $r = Invoke-OpenSSL "pkcs12 -in `"$($Cfg.PFXPath)`" -nocerts -nodes -out `"$keyFile`" -passin $passIn -legacy" $tmpDir
        if ($r.ExitCode -ne 0) {
            $r = Invoke-OpenSSL "pkcs12 -in `"$($Cfg.PFXPath)`" -nocerts -nodes -out `"$keyFile`" -passin $passIn" $tmpDir
            if ($r.ExitCode -ne 0) { throw ($t.ErrExtractKey -f $r.Err) }
        }

        Export-Formats -CertFile $certFile -KeyFile $keyFile -BaseName $baseName `
                       -OutDir $Cfg.OutDir -Password $newPassword -Cfg $Cfg

        $prog.Close()
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

        $msg    = $t.ResultConverted -f $baseName, $Cfg.OutDir
        $pfxPwd = if ($Cfg.FmtPFX) { $newPassword } else { "" }
        Show-Result -Title $t.ResultConvertTitle -Message $msg -Password $pfxPwd -PasswordLabel $t.NewPFXPwdLabel

    } catch {
        $prog.Close()
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show(($t.ErrGeneric -f $_), $t.ErrTitle,
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# ============================================================
#  HOOFDPROGRAMMA
# ============================================================

# 1. OpenSSL controleren (voor taalkeuze - gebruikt Engels als fallback)
$script:OpenSSLPath = Ensure-OpenSSL

# 2. Taal kiezen
$langChoice = Show-LanguagePicker
if (-not $langChoice) { exit }
$script:T = $Translations[$langChoice]

# 3. Hoofdmenu en verwerking
$choice = Show-MainMenu

switch ($choice) {
    "new"     { $cfg = Show-NewCertForm;   if ($cfg) { New-Certificate    $cfg } }
    "convert" { $cfg = Show-ConvertForm;   if ($cfg) { Convert-ExistingPFX $cfg } }
}
