<#
.SYNOPSIS
    Giao diện Terminal TUI (ASCII Art + Color Palette) cài đặt phần mềm tự động qua Winget.
    Thiết kế siêu nhẹ, tương thích 100% với Windows PowerShell 5.1 và Windows Terminal.
    Hỗ trợ nhập liệu chính xác từ bàn phím (tránh lỗi loạn phím khi cuộn Touchpad).
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "DEV & IT POST-SETUP INSTALLER"

# Hàm vẽ thanh tiến trình text ASCII
function Show-ProgressBar {
    param (
        [int]$Current,
        [int]$Total,
        [int]$Width = 40
    )
    $percent = [math]::Round(($Current / $Total) * 100)
    $completedWidth = [math]::Round(($Current / $Total) * $Width)
    $remainingWidth = $Width - $completedWidth

    $bar = ("█" * $completedWidth) + ("░" * $remainingWidth)
    Write-Host "  Tiến độ: " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$bar] " -NoNewline -ForegroundColor Cyan
    Write-Host "$percent% " -NoNewline -ForegroundColor Yellow
    Write-Host "($Current/$Total ứng dụng)" -ForegroundColor White
}

# Xóa màn hình chuẩn bị vẽ UI
Clear-Host

# 1. Header ASCII Art
Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   __        _____ _   _     _ _      ____  _______     __   ___ _____                 ║" -ForegroundColor Cyan
Write-Host "  ║   \ \      / /_ _| \ | |   / / |    |  _ \| ____\ \   / /  |_ _|_   _|                ║" -ForegroundColor Cyan
Write-Host "  ║    \ \ /\ / / | ||  \| |  / /| |    | | | |  _|  \ \ / /    | |  | |                  ║" -ForegroundColor Cyan
Write-Host "  ║     \ V  V /  | || |\  | / / | |    | |_| | |___  \ V /     | |  | |                  ║" -ForegroundColor Cyan
Write-Host "  ║      \_/\_/  |___|_| \_|/_/  |_|    |____/|_____|  \_/     |___| |_|                  ║" -ForegroundColor Cyan
Write-Host "  ║                                                                                       ║" -ForegroundColor Cyan
Write-Host "  ║                     WINDOWS 11 IT & DEV EDITION - POST INSTALLER                      ║" -ForegroundColor White
Write-Host "  ║               Tự động tải và cài đặt phần mềm qua Winget Package Manager              ║" -ForegroundColor DarkGray
Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 2. Kiểm tra kết nối Internet
Write-Host "  [Kiểm tra hệ thống]" -ForegroundColor Yellow
Write-Host "  ├─ Trạng thái mạng: " -NoNewline -ForegroundColor DarkGray
Write-Host "Đang kiểm tra kết nối Internet..." -NoNewline -ForegroundColor Yellow

$dotCount = 0
while (-not (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet)) {
    $dotCount++
    Write-Host "`r  ├─ Trạng thái mạng: " -NoNewline -ForegroundColor DarkGray
    Write-Host "Chưa có mạng! Vui lòng cắm dây LAN hoặc kết nối Wi-Fi... (Thử lại sau 3s [$dotCount])" -NoNewline -ForegroundColor Red
    Start-Sleep -Seconds 3
}

Write-Host "`r  ├─ Trạng thái mạng: " -NoNewline -ForegroundColor DarkGray
Write-Host "ĐÃ KẾT NỐI INTERNET THÀNH CÔNG!                     " -ForegroundColor Green
Write-Host "  └─ Công cụ cài đặt: " -NoNewline -ForegroundColor DarkGray
Write-Host "Windows Package Manager (Winget CLI)" -ForegroundColor Cyan
Write-Host ""

# 3. Danh mục các ứng dụng phân chia theo nhóm chức năng
$apps = @(
    # --- Nhóm 1: Trình duyệt & Bộ gõ tiếng Việt ---
    @{ Name = "Google Chrome";               Id = "Google.Chrome";                       Cat = "Trình duyệt"   }
    @{ Name = "EVKey (Bộ gõ tiếng Việt)";   Id = "lamquangminh.EVKey";                  Cat = "Bộ gõ Unikey"  }

    # --- Nhóm 2: Lập trình & Môi trường Dev ---
    @{ Name = "Visual Studio Code";          Id = "Microsoft.VisualStudioCode";          Cat = "IDE / Code"    }
    @{ Name = "VS Code Insiders";            Id = "Microsoft.VisualStudioCode.Insiders"; Cat = "IDE / Code"    }
    @{ Name = "Google Antigravity IDE";      Id = "Google.AntigravityIDE";               Cat = "AI IDE"        }
    @{ Name = "Notepad++";                   Id = "Notepad++.Notepad++";                 Cat = "Soạn thảo"     }
    @{ Name = "Git SCM";                     Id = "Git.Git";                             Cat = "Quản lý Git"   }
    @{ Name = "Node.js (LTS)";               Id = "OpenJS.NodeJS.LTS";                   Cat = "Môi trường JS" }
    @{ Name = "Python 3.12";                 Id = "Python.Python.3.12";                  Cat = "Môi trường Py" }

    # --- Nhóm 3: Tiện ích hệ thống & Tối ưu ---
    @{ Name = "7-Zip";                       Id = "7zip.7zip";                           Cat = "Nén file"      }
    @{ Name = "WinRAR";                      Id = "RARLab.WinRAR";                       Cat = "Nén file"      }
    @{ Name = "Microsoft PowerToys";         Id = "Microsoft.PowerToys";                 Cat = "Tiện ích Win"  }
    @{ Name = "Everything (Tìm file nhanh)"; Id = "voidtools.Everything";                Cat = "Tìm kiếm"      }
    @{ Name = "Visual C++ Runtimes (x64)";   Id = "Microsoft.VCRedist.2015+.x64";        Cat = "Thư viện C++"  }
    @{ Name = "NTLite";                      Id = "Nlitesoft.NTLite";                    Cat = "Build ISO"     }

    # --- Nhóm 4: Giao tiếp & Điều khiển từ xa ---
    @{ Name = "Zalo";                        Id = "VNGCorp.Zalo";                        Cat = "Nhắn tin"      }
    @{ Name = "UltraViewer";                 Id = "DucFabulous.UltraViewer";             Cat = "Điều khiển"    }
    @{ Name = "LocalSend";                   Id = "LocalSend.LocalSend";                 Cat = "Chia sẻ LAN"   }

    # --- Nhóm 5: Đa phương tiện ---
    @{ Name = "VLC Media Player";            Id = "VideoLAN.VLC";                        Cat = "Xem video"     }
)

# 4. Hiển thị bảng danh sách ứng dụng (ASCII Box-drawing Table)
Write-Host "  ┌────┬─────────────────────────────┬────────────────────────────────────┬──────────────┐" -ForegroundColor DarkGray
Write-Host "  │ #  │ TÊN ỨNG DỤNG                │ PACKAGE ID (WINGET)                │ NHÓM         │" -ForegroundColor Cyan
Write-Host "  ├────┼─────────────────────────────┼────────────────────────────────────┼──────────────┤" -ForegroundColor DarkGray

$index = 1
foreach ($item in $apps) {
    $numStr  = $index.ToString("00")
    $nameStr = $item.Name.PadRight(27)
    $idStr   = $item.Id.PadRight(34)
    $catStr  = $item.Cat.PadRight(12)

    Write-Host "  │ " -NoNewline -ForegroundColor DarkGray
    Write-Host $numStr -NoNewline -ForegroundColor Yellow
    Write-Host " │ " -NoNewline -ForegroundColor DarkGray
    Write-Host $nameStr -NoNewline -ForegroundColor White
    Write-Host " │ " -NoNewline -ForegroundColor DarkGray
    Write-Host $idStr -NoNewline -ForegroundColor DarkCyan
    Write-Host " │ " -NoNewline -ForegroundColor DarkGray
    Write-Host $catStr -NoNewline -ForegroundColor Magenta
    Write-Host " │" -ForegroundColor DarkGray
    $index++
}
Write-Host "  └────┴─────────────────────────────┴────────────────────────────────────┴──────────────┘" -ForegroundColor DarkGray
Write-Host ""

# 5. Xóa sạch bộ đệm phím bấm thừa do lướt Touchpad cuộn màn hình
try {
    $Host.UI.RawUI.FlushInputBuffer()
} catch {}
while ([Console]::KeyAvailable) {
    $null = [Console]::ReadKey($true)
}

# 6. Nhập lựa chọn chính xác từ bàn phím (Chỉ nhận khi nhấn phím Enter)
Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║  ĐIỀU KHIỂN BÀN PHÍM:                                                                 ║" -ForegroundColor Yellow
Write-Host "  ║   • Nhấn [Enter] để cài đặt TẤT CẢ 19 ứng dụng                                        ║" -ForegroundColor White
Write-Host "  ║   • Nhập số (VD: 1,3,7,10 hoặc 1-5) để chỉ cài các ứng dụng được chọn                 ║" -ForegroundColor White
Write-Host "  ║   • Nhập 'Q' và nhấn [Enter] để THOÁT                                                 ║" -ForegroundColor White
Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

$selectedApps = @()

while ($true) {
    # Xóa sạch phím bấm rác trước khi nhận input
    try { $Host.UI.RawUI.FlushInputBuffer() } catch {}
    while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) }

    $inputChoice = Read-Host "  👉 Lựa chọn của bạn"
    $inputChoice = $inputChoice.Trim()

    if ([string]::IsNullOrWhiteSpace($inputChoice)) {
        # Người dùng chỉ nhấn Enter -> Cài tất cả
        $selectedApps = $apps
        Write-Host "  [OK] Bạn đã chọn cài đặt: TẤT CẢ 19 ỨNG DỤNG.`n" -ForegroundColor Green
        break
    }
    elseif ($inputChoice -ieq "Q") {
        Write-Host "  [!] Đã hủy quá trình cài đặt theo yêu cầu của bạn. Thoát sau 2s..." -ForegroundColor Red
        Start-Sleep -Seconds 2
        exit 0
    }
    else {
        # Phân tích danh sách số người dùng nhập (VD: "1, 3, 5-8")
        $chosenIndices = @()
        $parts = $inputChoice -split "[,;\s]+"

        foreach ($part in $parts) {
            if ($part -match '^\d+$') {
                $num = [int]$part
                if ($num -ge 1 -and $num -le $apps.Count) {
                    $chosenIndices += ($num - 1)
                }
            }
            elseif ($part -match '^(\d+)\s*-\s*(\d+)$') {
                $start = [int]$matches[1]
                $end   = [int]$matches[2]
                if ($start -le $end) {
                    for ($i = $start; $i -le $end; $i++) {
                        if ($i -ge 1 -and $i -le $apps.Count) {
                            $chosenIndices += ($i - 1)
                        }
                    }
                }
            }
        }

        $chosenIndices = $chosenIndices | Select-Object -Unique | Sort-Object

        if ($chosenIndices.Count -gt 0) {
            foreach ($idx in $chosenIndices) {
                $selectedApps += $apps[$idx]
            }
            Write-Host "  [OK] Bạn đã chọn cài đặt: $($selectedApps.Count) ứng dụng:" -ForegroundColor Green
            foreach ($a in $selectedApps) {
                Write-Host "       • $($a.Name)" -ForegroundColor Cyan
            }
            Write-Host ""
            break
        }
        else {
            Write-Host "  [!] Lựa chọn không hợp lệ. Vui lòng nhập số hợp lệ từ 1 đến $($apps.Count) hoặc nhấn Enter." -ForegroundColor Red
        }
    }
}

# 7. Bắt đầu quá trình cài đặt tuần tự
$totalApps = $selectedApps.Count
$currentApp = 0
$successList = @()
$failedList  = @()

$commonArgs = @(
    "--silent",
    "--accept-source-agreements",
    "--accept-package-agreements"
)

$startTime = Get-Date

foreach ($item in $selectedApps) {
    $currentApp++
    $numStr = $currentApp.ToString("00")
    
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Show-ProgressBar -Current ($currentApp - 1) -Total $totalApps
    Write-Host ""
    Write-Host "  [+] [$numStr/$totalApps] Đang tải & cài đặt: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($item.Name) " -NoNewline -ForegroundColor White
    Write-Host "($($item.Id))..." -ForegroundColor DarkGray

    # Gọi winget cài đặt
    $process = Start-Process -FilePath "winget" -ArgumentList ("install --id `"$($item.Id)`" -e " + ($commonArgs -join " ")) -NoNewWindow -PassThru -Wait
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq -1978335189) {
        # 0 = Thành công, -1978335189 (0x8A15002B) = Đã được cài đặt từ trước
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

# 8. Thanh tiến trình 100%
Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Show-ProgressBar -Current $totalApps -Total $totalApps
Write-Host ""

# 9. Bảng tổng kết kết quả
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
Write-Host ""

# Xóa buffer trước khi chờ Enter kết thúc
try { $Host.UI.RawUI.FlushInputBuffer() } catch {}
while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) }

Read-Host "  [i] Nhấn [Enter] để đóng cửa sổ"
