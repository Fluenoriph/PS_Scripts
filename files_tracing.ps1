# **************************************

# Nebula Script. Backup-PDF Mod 2.0
# (c) Ivan Bogdanov. 2024-2025
# My contacts: fluenoriph@gmail.com, fluenoriph@yandex.ru
# Powered by Open Source 

# **************************************

using namespace System.Collections.Generic


$global:break_line = '- ' * 30
$global:flow_separator = '> ' * 40


class BackupBlock {
    hidden [List[psobject]] $files
    [string] $month
    [int] $all_sum
    [int] $eias_files_sum
    hidden [List[int]] $simple_files_types_sums       
    [List[string]] $missing_protocols
        
    [System.Collections.Hashtable] $data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; 
        '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}

    hidden [List[string]] $rgx = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-', '[ф]', '[р]', '[м]', '[ф][а]', '[р][а]', '[м][а]'
    hidden [List[string]] $protocol_types = '> Физ. факторы (Усс.): ', '> Рад. контроль (Усс.): ', '> Замеры мебели (Усс.): '
    [scriptblock] $result_out = { Write-Host ("`nУспешно! Скопировано файлов: $($this.all_sum)`n") }
    [scriptblock] $log_path = { param($month) ".\logs\отчет_$month.txt" }
    
    [void] get_files_block([string] $month_value) {        # обработка исключения
        [list[psobject]] $files_block = @(@(), @())
        
        foreach ($i in (0, 1)) { $files_block[$i] = Get-ChildItem -Path source:\ -File | Where-Object Name -Match $($this.rgx[$i] + "\d{2}\.$month_value\.\d{4}\.pdf$") }
        
        $this.month = $this.data_month.$month_value
        $this.eias_files_sum = $files_block[1].Count
        $this.all_sum = $files_block[0].Count + $this.eias_files_sum
        $this.protocol_types += $this.protocol_types | ForEach-Object { $_.Replace('Усс', 'Арс') }

        if ($this.all_sum -ne 0) {
            foreach ($i in $this.rgx[2..7]) {
                [List[int]] $n = $files_block[0] | Where-Object Name -Match "^(?<number>\d+)-$i-" | ForEach-Object { [int]$Matches.number } | Sort-Object
                $this.simple_files_types_sums += $n.Count
                
                if ($n.Count -gt 2) {
                    [List[int]] $r = $n[0]..$n[-1]
                    $n.GetEnumerator().ForEach({ $r.Remove($_) })
                    
                    if ($r.Count -gt 0) {
                        $this.missing_protocols += $r | ForEach-Object { -join([string]$_, '-', $i.Replace('[', '')) } | ForEach-Object { $_.Replace(']', '') }
                    }
                    else { continue }
                }
                else { continue }
            }            
        }
        else { Write-Host "`nЗа $($this.month) сканов протоколов не найдено!`n" }
    
    $this.files = $files_block[0] + $files_block[1] | Sort-Object        
    }
    
    [void] backuping() {
        [List[psobject]] $temp_block = @(@(), @())
        [string] $backup_dir = -join('destination:\', '\', $this.month)
                
        foreach ($i in $this.files) {
            if (Test-Path $(-join($backup_dir, '\', $i.Name))) { $temp_block[0] += $i }
            else { $temp_block[1] += $i }
        }
                # try catch ???
        if ($temp_block[0].Count -eq 0) { 
            $this.files | Copy-Item -Destination $backup_dir
            &$this.result_out
        }
        else {
            [List[string]] $d = $temp_block[0] | ForEach-Object { $_.Name.Replace('.pdf', ';') } 
            Write-Host "`nВнимание! Следующие файлы уже существуют в хранилище и будут перезаписаны.`n`n$($d -join "`n")`n"
            $task = Read-Host "Подтвердить - (Y); Отмена - (N)"

            if ($task -eq 'Y') {
                $temp_block[0] | Copy-Item -Destination $backup_dir -Force
                $temp_block[1] | Copy-Item -Destination $backup_dir
                &$this.result_out
            }
            else { Write-Host "`nРезервное копирование сброшено!`n" }          
        }   
    }

    [void] create_backup_folders() {
        foreach ($key in $this.data_month.keys | Sort-Object) {
            $value = $this.data_month.$key
            $folder = -join('destination:\', '\', $value)

            if (Test-Path $folder) {
                Write-Host "`nПапка за $value уже существует!"
            }
            else {
                New-Item -Path $folder -Type "directory" 2>$null

                if ($? -eq $true) { Write-Host "`nПапка за $value успешно создана!" }
                else { Write-Host "`n`Ошибка! Папка за $value не создана!`n" }
            } 
        }
    }

    [List[string]] out_missing_numbers() { return "`n** Пропущенные сканы:`n`n$($this.missing_protocols -join "`n")" }
    
    [List[string]] out_block_log() {
        [List[string]] $log = "`nПериод (месяц): $($this.month)", "Всего сканов: $($this.all_sum)`n", "> ЕИАС: $($this.eias_files_sum)"
        
        foreach ($i in 0..5) { $log.Add(-join($this.protocol_types[$i], $this.simple_files_types_sums[$i])) }
                
        return $($log -join "`n")
    }

    [void] logging() {
        $data = $this.out_block_log()
        $t = $this.files | ForEach-Object { $_.name }
        $data += "`nОтправленные сканы:`n`n$($t -join "`n")"
        $data += $this.out_missing_numbers()
        $data += $global:break_line
        $data | Out-File -FilePath $(&$this.log_path -month $this.month)
    }

    [void] get_log_info([string] $x) {
        Get-Content -Path $(&$this.log_path -month $this.data_month.$x) | Write-Host
    }
}
   

class DrivesControl {
    [string] $config = '.\config_pathes.ini'   
    [list[psobject]] $pathes

    [System.Collections.Hashtable] $drives = @{'-s' = 'source'; '-d' = 'destination'}
    [System.Collections.Hashtable] $drive_setup_status = @{'source' = $false; 'destination' = $false}    #test !!!

    [scriptblock] $bad_path_message = { param($dir_type_out, $path) "$dir_type_out'$path' не существует или неверное имя! >> Установите верный путь!`n" }
    [scriptblock] $write_directory_type = { param($type) if ($type -eq 'source') { "Исходная директория: " } else { "Директория резервного копирования: " } }
    
    DrivesControl() {
        if (Test-Path -Path $this.config) {
            $this.pathes = Get-Content -Path $this.config -Encoding utf8 | ConvertFrom-StringData  
            
            foreach ($k in $this.drives.Keys | Sort-Object -Descending) {
                $disk = $this.drives.$k
                $path = $this.pathes.$disk
                $type_out = &$this.write_directory_type -type $disk
                
                if (Test-Path -Path $path) {    
                    New-PSDrive -Name $disk -PSProvider FileSystem -Root $path -Scope Global
                    $this.drive_setup_status.$disk = $true
                    Write-Host $(-join($type_out, $path, "`n"))
                }
                else {
                    Write-Host $(&$this.bad_path_message -dir_type_out $type_out -path $path)
                    $this.reconfig_path()
                }
            }           
        }
        else { Write-Host "`n* Ошибка чтения настроек! *`n`n>> Файл '$($this.config)' не существует в корневой директории или неверное имя файла!`n" }    
    }
    
    [void] reconfig_path() {
        [list[string]] $current_drives = Get-PSDrive -PSProvider FileSystem | ForEach-Object { $_.Name }

        do {
            Write-Host "$($global:break_line)`n<тип директории> [тип: -s - исходный; -d - резервный]`n`n>> Пример: -s C:\Directory\Folder\Source files`n"
            $x = Read-Host "Ввод"
            
            [list[string]] $parameters = @()
            $parameters += $x -split " ", 2
            
            if ($parameters[0] -match '[-][s|d]') {
                $drive = $this.drives[$parameters[0]]
                if ($current_drives -contains $drive) { Remove-PSDrive -Name $drive }
                                
                (Get-Content -Path $this.config -Encoding utf8) -replace "$drive=.+", "$drive=$($parameters[1].Replace('\', '\\'))" | Set-Content -Path $this.config
                New-PSDrive -Name $drive -PSProvider FileSystem -Root $parameters[1] -Scope Global 2>$null
                [bool] $err = $?   
            
                if ($err -eq $false) {
                    Write-Host $(&$this.bad_path_message -dir_type_out $(&$this.write_directory_type -type $drive) -path $parameters[1]) }
                else {
                    $this.drive_setup_status.$drive = $true
                    $dir = &$this.write_directory_type -type $drive
                    Write-Host $(-join("`n", $dir.Replace(':', ''), "успешно установлена!`n")) }   
            }
            else {
                $err = $false
                Write-Host "`n* Введен неверный тип директории! * >> Вводите заново!`n"
            }
            
        } while ($err -eq $false)
    }
}


Write-Host @"

$global:break_line
    ** Резервное копирование сканов протоколов ** 
$global:break_line     
| Копирование за месяц > 'month <значение месяца>' (01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12)
| Копирование за год > 'year'
| Поиск протокола по номеру > 'find <номер>' (123-A; 12345-01-02)
| Получить отчет за месяц > 'report <значение месяца>' (01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12)
| Создание папок по месяцам > 'cmds' ([директория по умолчанию]) 

  Подробная справка: 'help'
$global:flow_separator

"@

$drives_control = [DrivesControl]::new()
function rc { return $drives_control.reconfig_path() }
$data_block = [BackupBlock]::new()

function backup_process {
    $set_values = $data_block.data_month.keys | Sort-Object
    Write-Host "$($global:break_line)`n>> Выберите, за какой месяц нужно отправить сканы >>`n`n> [$($set_values -join '; ')] <`n"

    do {
        $value = Read-Host "Ввод"
        if ($set_values -contains $value) {
            $data_block.get_files_block($value)
            $data_block.out_block_log()
            $data_block.out_missing_numbers()
            $data_block.backuping()
            $data_block.logging()
        }
        else { 
            Write-Host "`n* Неверное значение! * >> Попробуйте заново!`n" 
            continue
        }

    } while ($set_values -notcontains $value) 
}

if ($drives_control.drive_setup_status.source -eq $true -and $drives_control.drive_setup_status.destination -eq $true) { backup_process }

else { exit }















