# PSCertTool

PowerShell GUI tool for creating self-signed certificates and converting existing PFX files — powered by OpenSSL, no certificate store required.

> **UI languages:** Dutch (Nederlands) · English

---

## Features

- **Create** self-signed certificates (RSA 2048/4096, SHA256/384/512, custom validity)
- **Convert** existing PFX/P12 files to other formats
- **Export** to any combination of: PFX/P12, PEM (cert + key), DER, P7B/PKCS#7
- **Multilingual** — choose Dutch or English at startup; easily extendable to other languages
- **Auto-installs OpenSSL** via `winget` if not present — or lets you point to it manually
- **No certificate store pollution** — all operations go directly through OpenSSL to files
- Copyable PFX password in the result dialog (no more typing it over)
- Random 16-character password generated per certificate

---

## Requirements

| Requirement | Notes |
|---|---|
| Windows 10 / 11 | Required for WinForms GUI |
| PowerShell 5.1 or later | Pre-installed on Windows 10+ |
| OpenSSL | Auto-installed via `winget` on first run |

> **Note:** If your organisation blocks `winget`, install OpenSSL manually from  
> https://slproweb.com/products/Win32OpenSSL.html and make sure `openssl.exe` is in your `PATH`.

---

## Getting Started

### 1. Download

Download `CertTool.ps1` from this repository, or clone it:

```bash
git clone https://github.com/YOUR_USERNAME/PSCertTool.git
```

### 2. Allow script execution (if needed)

Open PowerShell as your regular user and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 3. Run

Right-click `CertTool.ps1` → **Run with PowerShell**, or from a terminal:

```powershell
.\CertTool.ps1
```

---

## Usage

### Step 1 — Choose your language

On first launch a language picker appears. Select **Nederlands** or **English**. All labels, buttons, and messages will follow your choice.

### Step 2 — Create a new certificate

1. Click **Create new certificate** / **Nieuw certificaat aanmaken**
2. Fill in the certificate details:

   | Field (EN) | Field (NL) | Description |
   |---|---|---|
   | Name (CN) | Naam (CN) | Common Name — e.g. `MyApp` or `server.domain.local` |
   | Reference (OU) | Referentie (OU) | Organisational Unit / reference number |
   | Organisation (O) | Organisatie (O) | Organisation name |
   | Location (L) | Locatie (L) | City / location |
   | Country (C) | Land (C) | Two-letter country code, e.g. `NL` |
   | Key length | Sleutellengte | RSA key size: `2048` or `4096` |
   | Hash algorithm | Hash algoritme | `SHA256`, `SHA384` (default), or `SHA512` |
   | Validity (days) | Geldigheid (dagen) | 30 / 60 / 90 / 120 / 150 / 180 / 365 / 730 / 1095 / 1825 |

3. Select an output folder
4. Tick the desired output formats
5. Click **Create** / **Aanmaken**
6. Copy the generated PFX password from the result dialog — it is not stored anywhere

### Step 3 — Or convert an existing PFX

1. Click **Convert existing certificate** / **Bestaand certificaat converteren**
2. Browse to your `.pfx` or `.p12` file
3. Enter the current password
4. Select an output folder and desired formats
5. Click **Convert** / **Converteren**
6. A new PFX password is generated if PFX is selected as output format

---

## Output formats

| Format | Extension | Use case |
|---|---|---|
| PFX / P12 | `.pfx` | Windows, IIS, Azure — full chain with private key |
| PEM | `.crt` + `.key` | Apache, nginx, Linux — separate cert and key files |
| DER | `.der` | Java keystores, binary certificate |
| P7B / PKCS#7 | `.p7b` | IIS certificate import, certificate chain without private key |

---

## OpenSSL Detection

On startup, the script searches for `openssl.exe` in the following order:

1. System `PATH`
2. Known installation paths (`Program Files\OpenSSL-Win64`, etc.)
3. Full recursive search through `Program Files`
4. If still not found: manual file picker dialog

---

## Adding a Language

All UI strings live in the `$Translations` hashtable near the top of `CertTool.ps1`. To add a third language (e.g. German):

1. Copy the `EN = @{ ... }` block and rename it `DE`
2. Translate all string values
3. Add a button for it in the `Show-LanguagePicker` function

---

## Security Notes

- Private keys (`.key`) are exported **unencrypted** in PEM mode — protect your output folder accordingly
- PFX files are protected with a randomly generated 16-character password, shown once in the result dialog
- No certificates are written to the Windows certificate store at any point

---

## Author

**Johannes Muller**  
Version 1.1 — 2026-06-18
