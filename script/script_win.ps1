<#
.SYNOPSIS
    Giao diện Terminal TUI Menu lồng Menu (Multi-level Interactive TUI Menu)
    Hệ thống cài đặt & Quản trị Windows 11 IT & Dev Edition.
    Hỗ trợ:
      - Menu chính gọn gàng (2 chức năng chính): Tải App & Chạy link IRM.
      - Chạy script trực tuyến linh hoạt: irm <link> | iex
      - Tương thích 100% với PowerShell 5.1 và Windows Terminal.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "WINDOWS 11 IT & DEV EDITION - CONTROL CENTER"
Clear-Host

# ==============================================================================
# LẤY THÔNG TIN CẤU HÌNH PHẦN CỨNG HỆ THỐNG (LẤY 1 LẦN KHI KHỞI ĐỘNG)
# ==============================================================================
$global:sysSpecs = try {
    $osInfo  = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cpuInfo = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $gpuInfo = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
    $diskC   = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue

    $ramGB   = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 1)
    $freeGB  = [math]::Round($diskC.FreeSpace / 1GB, 1)
    $totalGB = [math]::Round($diskC.Size / 1GB, 1)

    @{
        OS   = "$($osInfo.Caption) ($($osInfo.OSArchitecture))"
        CPU  = "$($cpuInfo.Name.Trim())"
        RAM  = "$($ramGB) GB RAM"
        GPU  = "$($gpuInfo.Name)"
        Disk = "Trống $freeGB GB / Tổng $totalGB GB"
    }
} catch { $null }

# ==============================================================================
# HÀM BỔ TRỢ GIAO DIỆN & TIỆN ÍCH
# ==============================================================================

function Show-Header {
    param (
        [string]$SubTitle = "",
        [string]$Breadcrumb = ""
    )
    Clear-Host
    Write-Host ""
    Write-Host "  =========================================================================================" -ForegroundColor Cyan
    Write-Host "                 HỆ THỐNG CÀI ĐẶT & QUẢN TRỊ WINDOWS 11 IT & DEV EDITION                   " -ForegroundColor Yellow
    Write-Host "  =========================================================================================" -ForegroundColor Cyan
    if ($Breadcrumb) {
        Write-Host "  📌 $Breadcrumb" -ForegroundColor DarkGray
    }
    if ($SubTitle) {
        Write-Host "  🚀 $SubTitle" -ForegroundColor Green
    }
    Write-Host ""
}

function Clear-InputBuffer {
    try { $Host.UI.RawUI.FlushInputBuffer() } catch {}
    try { while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) } } catch {}
}

function Wait-KeyPress {
    param ([string]$Message = "Nhấn phím bất kỳ để tiếp tục...")
    Write-Host ""
    Write-Host "  👉 $Message" -ForegroundColor DarkGray
    Clear-InputBuffer
    try {
        $null = [Console]::ReadKey($true)
    } catch {
        $null = Read-Host
    }
}

function Show-ProgressBar {
    param (
        [int]$Current,
        [int]$Total,
        [int]$Width = 40
    )
    if ($Total -le 0) { return }
    $percent = [math]::Round(($Current / $Total) * 100)
    $completedWidth = [math]::Round(($Current / $Total) * $Width)
    $remainingWidth = $Width - $completedWidth

    $bar = ("█" * $completedWidth) + ("░" * $remainingWidth)
    Write-Host "  Tiến độ: " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$bar] " -NoNewline -ForegroundColor Cyan
    Write-Host "$percent% " -NoNewline -ForegroundColor Yellow
    Write-Host "($Current/$Total tác vụ)" -ForegroundColor White
}

# ==============================================================================
# DANH MỤC ỨNG DỤNG WINGET (19 ỨNG DỤNG)
# ==============================================================================
$global:appList = @(
    # --- Nhóm 1: Trình duyệt & Bộ gõ tiếng Việt ---
    @{ Name = "Google Chrome";               Id = "Google.Chrome";                       Cat = "Trình duyệt"; Group = "Basic" },
    @{ Name = "EVKey (Bộ gõ tiếng Việt)";   Id = "lamquangminh.EVKey";                  Cat = "Bộ gõ Unikey";Group = "Basic" },

    # --- Nhóm 2: Lập trình & Môi trường Dev ---
    @{ Name = "Visual Studio Code";          Id = "Microsoft.VisualStudioCode";          Cat = "IDE / Code";   Group = "Dev" },
    @{ Name = "VS Code Insiders";            Id = "Microsoft.VisualStudioCode.Insiders"; Cat = "IDE / Code";   Group = "Dev" },
    @{ Name = "Google Antigravity IDE";      Id = "Google.AntigravityIDE";               Cat = "AI IDE";       Group = "Dev" },
    @{ Name = "Notepad++";                   Id = "Notepad++.Notepad++";                 Cat = "Soạn thảo";    Group = "Dev" },
    @{ Name = "Git SCM";                     Id = "Git.Git";                             Cat = "Quản lý Git";  Group = "Dev" },
    @{ Name = "Node.js (LTS)";               Id = "OpenJS.NodeJS.LTS";                   Cat = "Môi trường JS";Group = "Dev" },
    @{ Name = "Python 3.12";                 Id = "Python.Python.3.12";                  Cat = "Môi trường Py";Group = "Dev" },

    # --- Nhóm 3: Tiện ích hệ thống & Tối ưu ---
    @{ Name = "7-Zip";                       Id = "7zip.7zip";                           Cat = "Nén file";     Group = "Basic" },
    @{ Name = "WinRAR";                      Id = "RARLab.WinRAR";                       Cat = "Nén file";     Group = "Util" },
    @{ Name = "Microsoft PowerToys";         Id = "Microsoft.PowerToys";                 Cat = "Tiện ích Win"; Group = "Util" },
    @{ Name = "Everything (Tìm file nhanh)"; Id = "voidtools.Everything";                Cat = "Tìm kiếm";     Group = "Util" },
    @{ Name = "Visual C++ Runtimes (x64)";   Id = "Microsoft.VCRedist.2015+.x64";        Cat = "Thư viện C++"; Group = "Basic" },
    @{ Name = "NTLite";                      Id = "Nlitesoft.NTLite";                    Cat = "Build ISO";    Group = "Util" },

    # --- Nhóm 4: Giao tiếp & Điều khiển từ xa ---
    @{ Name = "Zalo";                        Id = "VNGCorp.Zalo";                        Cat = "Nhắn tin";     Group = "Comm" },
    @{ Name = "UltraViewer";                 Id = "DucFabulous.UltraViewer";             Cat = "Điều khiển";   Group = "Comm" },
    @{ Name = "LocalSend";                   Id = "LocalSend.LocalSend";                 Cat = "Chia sẻ LAN";  Group = "Comm" },

    # --- Nhóm 5: Đa phương tiện ---
    @{ Name = "VLC Media Player";            Id = "VideoLAN.VLC";                        Cat = "Xem video";    Group = "Media" }
)

# ==============================================================================
# DANH SÁCH LINK IRM ONLINE (BẠN TỰ THÊM HOẶC CHỈNH SỬA LINK TẠI ĐÂY)
# Cú pháp thực thi tương đương: irm "<Url>" | iex
# ==============================================================================
$global:irmList = @(
    # --- Link mẫu 1: Kích hoạt Windows & Office bản quyền số MAS ---
    @{
        Name = "Kích hoạt Windows & Office (MAS - Microsoft Activation Scripts)";
        Url  = "https://get.activated.win";
        Desc = "HWID / KMS38"
    }

)

# ==============================================================================
# HÀM THỰC THI CÀI ĐẶT WINGET
# ==============================================================================
function Install-SelectedApps {
    param ([array]$TargetApps)

    if (-not $TargetApps -or $TargetApps.Count -eq 0) {
        Write-Host "  [!] Không có ứng dụng nào được chọn để cài đặt." -ForegroundColor Yellow
        Wait-KeyPress
        return
    }

    # 1. Kiểm tra kết nối Internet
    Write-Host "  [Kiểm tra kết nối Internet]" -ForegroundColor Yellow
    Write-Host "  ├─ Trạng thái mạng: " -NoNewline -ForegroundColor DarkGray
    Write-Host "Đang kiểm tra kết nối mạng..." -NoNewline -ForegroundColor Yellow

    $dotCount = 0
    while (-not (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet)) {
        $dotCount++
        Write-Host "`r  ├─ Trạng thái mạng: " -NoNewline -ForegroundColor DarkGray
        Write-Host "Chưa có mạng! Vui lòng cắm dây LAN hoặc kết nối Wi-Fi... (Thử lại sau 3s [$dotCount])" -NoNewline -ForegroundColor Red
        Start-Sleep -Seconds 3
        if ($dotCount -ge 5) {
            Write-Host "`n  [!] Không thể kết nối Internet sau 15 giây. Huỷ cài đặt." -ForegroundColor Red
            Wait-KeyPress
            return
        }
    }

    Write-Host "`r  ├─ Trạng thái mạng: " -NoNewline -ForegroundColor DarkGray
    Write-Host "ĐÃ KẾT NỐI INTERNET THÀNH CÔNG!                     " -ForegroundColor Green
    Write-Host "  └─ Công cụ cài đặt: " -NoNewline -ForegroundColor DarkGray
    Write-Host "Windows Package Manager (Winget CLI)" -ForegroundColor Cyan
    Write-Host ""

    # 2. Tiến hành cài đặt
    $totalApps = $TargetApps.Count
    $currentApp = 0
    $successList = @()
    $failedList  = @()

    $commonArgs = @(
        "--silent",
        "--accept-source-agreements",
        "--accept-package-agreements"
    )

    $startTime = Get-Date

    foreach ($item in $TargetApps) {
        $currentApp++
        $numStr = $currentApp.ToString("00")
        
        Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Show-ProgressBar -Current ($currentApp - 1) -Total $totalApps
        Write-Host ""
        Write-Host "  [+] [$numStr/$totalApps] Đang tải & cài đặt: " -NoNewline -ForegroundColor Cyan
        Write-Host "$($item.Name)..." -ForegroundColor White

        try {
            $process = Start-Process -FilePath "winget" -ArgumentList ("install --id `"$($item.Id)`" -e " + ($commonArgs -join " ")) -NoNewWindow -PassThru -Wait
            $exitCode = $process.ExitCode
        } catch {
            $exitCode = -1
        }

        if ($exitCode -eq 0 -or $exitCode -eq -1978335189) {
            Write-Host "      └─ [✔] THÀNH CÔNG: " -NoNewline -ForegroundColor Green
            Write-Host "$($item.Name) đã sẵn sàng sử dụng!" -ForegroundColor White
            $successList += $item.Name
        } else {
            Write-Host "      └─ [✖] THẤT BẠI: " -NoNewline -ForegroundColor Red
            Write-Host "$($item.Name) (Mã lỗi: $exitCode)" -ForegroundColor DarkYellow
            $failedList += "$($item.Name) (ExitCode: $exitCode)"
        }
        Write-Host ""
    }

    # Bảng tổng kết
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Show-ProgressBar -Current $totalApps -Total $totalApps
    Write-Host ""

    $duration = [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1)

    Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                             HOÀN TẤT QUÁ TRÌNH CÀI ĐẶT                                ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "  ├─ Tổng số ứng dụng: $($totalApps)" -ForegroundColor White
    Write-Host "  ├─ Cài đặt thành công: $($successList.Count)" -ForegroundColor Green
    if ($failedList.Count -gt 0) {
        Write-Host "  ├─ Cài đặt thất bại:   $($failedList.Count)" -ForegroundColor Red
        foreach ($err in $failedList) {
            Write-Host "  │  • $err" -ForegroundColor Red
        }
    }
    Write-Host "  └─ Tổng thời gian:     $($duration) phút" -ForegroundColor Cyan

    Wait-KeyPress -Message "Nhấn phím bất kỳ để quay lại menu..."
}

# ==============================================================================
# BẢNG CHỌN & CÀI ĐẶT ỨNG DỤNG (CHỌN THEO SỐ HOẶC ENTER CÀI TẤT CẢ)
# ==============================================================================
function Show-AppSelectionTable {
    while ($true) {
        Show-Header -SubTitle "BẢNG CHỌN ỨNG DỤNG CẦN CÀI ĐẶT" -Breadcrumb "MAIN MENU > [1] CÀI ĐẶT ỨNG DỤNG"

        Write-Host "  ┌────┬───────────────────────────────────────────────────────────┬───────────────────┐" -ForegroundColor DarkGray
        Write-Host "  │ #  │ TÊN ỨNG DỤNG                                              │ PHÂN LOẠI         │" -ForegroundColor Cyan
        Write-Host "  ├────┼───────────────────────────────────────────────────────────┼───────────────────┤" -ForegroundColor DarkGray

        $index = 1
        foreach ($item in $global:appList) {
            $numStr  = $index.ToString("00")
            $nameStr = $item.Name
            if ($nameStr.Length -gt 57) { $nameStr = $nameStr.Substring(0, 54) + "..." }
            $namePadded = $nameStr.PadRight(57)

            $catStr  = $item.Cat
            if ($catStr.Length -gt 17) { $catStr = $catStr.Substring(0, 14) + "..." }
            $catPadded = $catStr.PadRight(17)

            Write-Host "  │ " -NoNewline -ForegroundColor DarkGray
            Write-Host $numStr -NoNewline -ForegroundColor Yellow
            Write-Host " │ " -NoNewline -ForegroundColor DarkGray
            Write-Host $namePadded -NoNewline -ForegroundColor White
            Write-Host " │ " -NoNewline -ForegroundColor DarkGray
            Write-Host $catPadded -NoNewline -ForegroundColor Magenta
            Write-Host " │" -ForegroundColor DarkGray
            $index++
        }
        Write-Host "  └────┴───────────────────────────────────────────────────────────┴───────────────────┘" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "  ║  HƯỚNG DẪN CHỌN CÀI ĐẶT:                                                              ║" -ForegroundColor Yellow
        Write-Host "  ║   • Nhập số (VD: 1,3,7,10 hoặc 1-5) để cài ứng dụng tương ứng                         ║" -ForegroundColor White
        Write-Host "  ║   • Nhấn [Enter] trực tiếp để cài đặt TẤT CẢ ($($global:appList.Count) ứng dụng)                               ║" -ForegroundColor White
        Write-Host "  ║   • Nhập '0' hoặc 'B' để QUAY LẠI Menu chính                                          ║" -ForegroundColor White
        Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        Write-Host ""

        Clear-InputBuffer
        $inputChoice = Read-Host "  👉 Nhập số ứng dụng bạn muốn cài"
        $inputChoice = $inputChoice.Trim()

        if ($inputChoice -ieq "0" -or $inputChoice -ieq "B") {
            return
        }

        $selected = @()
        if ([string]::IsNullOrWhiteSpace($inputChoice)) {
            $selected = $global:appList
        } else {
            $chosenIndices = @()
            $parts = $inputChoice -split "[,;\s]+"

            foreach ($part in $parts) {
                if ($part -match '^\d+$') {
                    $num = [int]$part
                    if ($num -ge 1 -and $num -le $global:appList.Count) {
                        $chosenIndices += ($num - 1)
                    }
                }
                elseif ($part -match '^(\d+)\s*-\s*(\d+)$') {
                    $start = [int]$matches[1]
                    $end   = [int]$matches[2]
                    if ($start -le $end) {
                        for ($i = $start; $i -le $end; $i++) {
                            if ($i -ge 1 -and $i -le $global:appList.Count) {
                                $chosenIndices += ($i - 1)
                            }
                        }
                    }
                }
            }

            $chosenIndices = $chosenIndices | Select-Object -Unique | Sort-Object
            foreach ($idx in $chosenIndices) {
                $selected += $global:appList[$idx]
            }
        }

        if ($selected.Count -gt 0) {
            Write-Host "`n  [OK] Bạn đã chọn $($selected.Count) ứng dụng để cài đặt:" -ForegroundColor Green
            foreach ($a in $selected) {
                Write-Host "       • $($a.Name)" -ForegroundColor Cyan
            }
            Write-Host ""
            $confirm = Read-Host "  👉 Bắt đầu cài đặt ngay? (Y/n)"
            if ($confirm -ieq "Y" -or [string]::IsNullOrWhiteSpace($confirm)) {
                Install-SelectedApps -TargetApps $selected
                return
            }
        } else {
            Write-Host "  [!] Không có lựa chọn hợp lệ nào được chọn." -ForegroundColor Red
            Wait-KeyPress
        }
    }
}

# ==============================================================================
# HÀM CHUẨN HÓA & TRÍCH XUẤT URL (HỖ TRỢ CẢ HTTP, HTTPS & CHUỖI IRM/IEX)
# ==============================================================================
function Get-NormalizedUrl {
    param ([string]$InputText)

    if ([string]::IsNullOrWhiteSpace($InputText)) { return $null }
    $clean = $InputText.Trim().Trim('"').Trim("'")

    # Nếu người dùng paste cả câu lệnh: irm "https://..." | iex hoặc iwr "https://..."
    if ($clean -match '(?:irm|Invoke-RestMethod|iwr|Invoke-WebRequest)\s+["'']?([^\s"'']+)["'']?') {
        $clean = $matches[1]
    }
    # Hoặc chuỗi có chứa https:// hoặc http://
    elseif ($clean -match '(https?://[^\s"''>|]+)') {
        $clean = $matches[1]
    }

    # Bỏ dấu ngoặc, pipe hoặc ký tự rác nếu có
    $clean = $clean.Trim().Trim(')','|','}','"',"'")

    # Nếu người dùng không nhập scheme (ví dụ: get.activated.win hoặc christitus.com/win)
    if ($clean -notmatch '^https?://') {
        $clean = "https://" + $clean.TrimStart('/')
    }

    # Kiểm tra tính hợp lệ của URI
    $uriResult = $null
    if ([System.Uri]::TryCreate($clean, [System.UriKind]::Absolute, [ref]$uriResult)) {
        if ($uriResult.Scheme -eq "http" -or $uriResult.Scheme -eq "https") {
            return $uriResult.AbsoluteUri
        }
    }

    return $null
}

# ==============================================================================
# CHỨC NĂNG CHẠY ONLINE SCRIPT QUA LINK IRM (INVOKE-RESTMETHOD | INVOKE-EXPRESSION)
# Hỗ trợ cả HTTP & HTTPS, tự động kích hoạt TLS 1.2/1.3 và xử lý lỗi mạng
# ==============================================================================
function Execute-IrmLink {
    param (
        [string]$Url,
        [string]$Title = "Script Online"
    )

    $validUrl = Get-NormalizedUrl -InputText $Url
    if (-not $validUrl) {
        Write-Host "  [!] URL không hợp lệ: '$Url'" -ForegroundColor Red
        Write-Host "      Vui lòng nhập định dạng http:// hoặc https:// hợp lệ!" -ForegroundColor DarkGray
        Wait-KeyPress
        return
    }

    $isHttpInsecure = $validUrl.StartsWith("http://", [System.StringComparison]::OrdinalIgnoreCase)

    Show-Header -SubTitle "CHẠY ONLINE SCRIPT: $Title" -Breadcrumb "MAIN MENU > [2] CHẠY LINK IRM > THỰC THI"
    Write-Host "  [*] URL mục tiêu : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$validUrl" -ForegroundColor Cyan
    Write-Host "  [*] Giao thức    : " -NoNewline -ForegroundColor DarkGray
    if ($isHttpInsecure) {
        Write-Host "HTTP (Không mã hóa - Kém an toàn)" -ForegroundColor Red
    } else {
        Write-Host "HTTPS (Mã hóa SSL/TLS an toàn)" -ForegroundColor Green
    }
    Write-Host "  [*] Lệnh thực thi: " -NoNewline -ForegroundColor DarkGray
    Write-Host "irm `"$validUrl`" | iex" -ForegroundColor Yellow
    Write-Host ""

    if ($isHttpInsecure) {
        Write-Host "  [!] CẢNH BÁO: Script chạy qua giao thức HTTP không được mã hóa." -ForegroundColor Red
        Write-Host "      Nội dung script có nguy cơ bị can thiệp nếu bạn đang dùng Wi-Fi/mạng lạ!" -ForegroundColor DarkYellow
        Write-Host ""
    }

    # Kiểm tra kết nối Internet
    Write-Host "  [Kiểm tra kết nối Internet]" -ForegroundColor Yellow
    if (-not (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet)) {
        Write-Host "  [!] Không thể kết nối Internet. Vui lòng kiểm tra lại mạng trước khi chạy IRM!" -ForegroundColor Red
        Wait-KeyPress
        return
    }
    Write-Host "  ├─ Kết nối Internet: " -NoNewline -ForegroundColor DarkGray
    Write-Host "ĐÃ KẾT NỐI (OK)" -ForegroundColor Green
    Write-Host ""

    $confirm = Read-Host "  👉 Bạn có chắc chắn muốn tải và chạy script này? (Y/n)"
    if ($confirm -ne "" -and $confirm -ine "Y") {
        Write-Host "  [!] Đã hủy thao tác." -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
        return
    }

    Write-Host "`n  [*] Đang tải và thực thi: irm `"$validUrl`" | iex ..." -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    try {
        # Đảm bảo bật TLS 1.2 và TLS 1.3 (nếu hệ thống hỗ trợ) để tránh lỗi handshake SSL
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls13
        } catch {}

        # Tải nội dung script kèm User-Agent để tránh bị web server / CDN chặn request từ PowerShell
        $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) PowerShell/IRM" }
        $scriptContent = Invoke-RestMethod -Uri $validUrl -UseBasicParsing -Headers $headers
        Invoke-Expression $scriptContent

        Write-Host ""
        Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  [✔] ĐÃ HOÀN TẤT THỰC THI SCRIPT!" -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  [✖] Lỗi trong quá trình tải hoặc thực thi:" -ForegroundColor Red
        Write-Host "      $($_.Exception.Message)" -ForegroundColor DarkYellow
    }

    Wait-KeyPress -Message "Nhấn phím bất kỳ để quay lại menu..."
}

function Show-SubMenu-IrmRunner {
    while ($true) {
        Show-Header -SubTitle "CHẠY ONLINE SCRIPT QUA LINK IRM (INVOKE-RESTMETHOD)" -Breadcrumb "MAIN MENU > [2] CHẠY LINK IRM"

        Write-Host "  ┌────┬───────────────────────────────────────────────────────────┬───────────────────┐" -ForegroundColor DarkGray
        Write-Host "  │ #  │ TÊN SCRIPT / TÍNH NĂNG                                    │ MÔ TẢ             │" -ForegroundColor Cyan
        Write-Host "  ├────┼───────────────────────────────────────────────────────────┼───────────────────┤" -ForegroundColor DarkGray

        $idx = 1
        foreach ($item in $global:irmList) {
            $numStr = $idx.ToString().PadRight(2)
            $nameStr = $item.Name
            if ($nameStr.Length -gt 57) { $nameStr = $nameStr.Substring(0, 54) + "..." }
            $namePadded = $nameStr.PadRight(57)

            $descStr = $item.Desc
            if ($descStr.Length -gt 17) { $descStr = $descStr.Substring(0, 14) + "..." }
            $descPadded = $descStr.PadRight(17)

            Write-Host "  │ " -NoNewline -ForegroundColor DarkGray
            Write-Host $numStr -NoNewline -ForegroundColor Yellow
            Write-Host " │ " -NoNewline -ForegroundColor DarkGray
            Write-Host $namePadded -NoNewline -ForegroundColor White
            Write-Host " │ " -NoNewline -ForegroundColor DarkGray
            Write-Host $descPadded -NoNewline -ForegroundColor DarkCyan
            Write-Host " │" -ForegroundColor DarkGray
            $idx++
        }

        Write-Host "  ├────┼───────────────────────────────────────────────────────────┼───────────────────┤" -ForegroundColor DarkGray
        Write-Host "  │ 0  │ ↩️  QUAY LẠI MENU CHÍNH                                    │ Trở về trang chủ  │" -ForegroundColor Yellow
        Write-Host "  └────┴───────────────────────────────────────────────────────────┴───────────────────┘" -ForegroundColor DarkGray
        Write-Host ""

        Clear-InputBuffer
        $choice = Read-Host "  👉 Nhập số (1-$($global:irmList.Count)) hoặc '0' để quay lại"
        $choice = $choice.Trim()

        if ($choice -eq "0") {
            return
        }
        elseif ($choice -match '^\d+$') {
            $num = [int]$choice
            if ($num -ge 1 -and $num -le $global:irmList.Count) {
                $target = $global:irmList[$num - 1]
                Execute-IrmLink -Url $target.Url -Title $target.Name
            } else {
                Write-Host "  [!] Số thứ tự không hợp lệ. Vui lòng chọn trong danh sách!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
        else {
            Write-Host "  [!] Lựa chọn không hợp lệ." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

# ==============================================================================
# HÀM HIỂN THỊ CẤU HÌNH PHẦN CỨNG MÁY TÍNH
# ==============================================================================
function Show-SystemSpecsBox {
    if (-not $global:sysSpecs) { return }

    Write-Host "  ┌── THÔNG TIN CẤU HÌNH PHẦN CỨNG ────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    $specRows = @(
        ("• Hệ điều hành : " + $global:sysSpecs.OS),
        ("• Vi xử lý (CPU): " + $global:sysSpecs.CPU),
        ("• Bộ nhớ (RAM) : " + $global:sysSpecs.RAM),
        ("• Đồ họa (GPU) : " + $global:sysSpecs.GPU),
        ("• Ổ cứng (C:)  : " + $global:sysSpecs.Disk)
    )

    foreach ($row in $specRows) {
        $text = $row
        if ($text.Length -gt 85) { $text = $text.Substring(0, 82) + "..." }
        $padded = $text.PadRight(85)
        Write-Host "  │ " -NoNewline -ForegroundColor DarkGray
        Write-Host $padded.Substring(0, 17) -NoNewline -ForegroundColor Cyan
        Write-Host $padded.Substring(17) -NoNewline -ForegroundColor White
        Write-Host " │" -ForegroundColor DarkGray
    }
    Write-Host "  └───────────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
}

# ==============================================================================
# MENU CHÍNH (MAIN MENU) - CHỈ 2 TÙY CHỌN CHÍNH
# ==============================================================================
function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "  =========================================================================================" -ForegroundColor Cyan
        Write-Host "                 HỆ THỐNG CÀI ĐẶT & QUẢN TRỊ WINDOWS 11 IT & DEV EDITION                   " -ForegroundColor Yellow
        Write-Host "  =========================================================================================" -ForegroundColor Cyan
        Write-Host "  📌 TRANG CHỦ / MAIN MENU" -ForegroundColor DarkGray
        Write-Host ""

        Show-SystemSpecsBox

        Write-Host "  ┌────┬───────────────────────────────────────────────────────────┬───────────────────┐" -ForegroundColor DarkGray
        Write-Host "  │ #  │ DANH MỤC CHỨC NĂNG CHÍNH                                  │ PHÂN LOẠI         │" -ForegroundColor Cyan
        Write-Host "  ├────┼───────────────────────────────────────────────────────────┼───────────────────┤" -ForegroundColor DarkGray
        Write-Host "  │ 1  │ 📦 Tải & Cài đặt ứng dụng tự động qua Winget (App Install)│ Chọn theo số      │" -ForegroundColor White
        Write-Host "  │ 2  │ 🚀 Chạy Script Online qua link IRM (irm <link> | iex)     │ Online Scripts    │" -ForegroundColor White
        Write-Host "  ├────┼───────────────────────────────────────────────────────────┼───────────────────┤" -ForegroundColor DarkGray
        Write-Host "  │ 0  │ 🚪 THOÁT CHƯƠNG TRÌNH (Exit)                               │ Đóng cửa sổ       │" -ForegroundColor Yellow
        Write-Host "  └────┴───────────────────────────────────────────────────────────┴───────────────────┘" -ForegroundColor DarkGray
        Write-Host ""

        Clear-InputBuffer
        $mainChoice = Read-Host "  👉 Nhập lựa chọn của bạn (0-2)"
        $mainChoice = $mainChoice.Trim()

        switch ($mainChoice) {
            "1" { Show-AppSelectionTable }
            "2" { Show-SubMenu-IrmRunner }
            "0" {
                Write-Host ""
                Write-Host "  [i] Cảm ơn bạn đã sử dụng bộ công cụ Windows 11 Setup!" -ForegroundColor Green
                Write-Host "  [!] Đang đóng chương trình sau 2 giây..." -ForegroundColor DarkGray
                Start-Sleep -Seconds 2
                exit 0
            }
            default {
                Write-Host "  [!] Lựa chọn không hợp lệ. Vui lòng nhập 0, 1 hoặc 2!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# ==============================================================================
# KHỞI CHẠY CHƯƠNG TRÌNH
# ==============================================================================
Show-MainMenu

