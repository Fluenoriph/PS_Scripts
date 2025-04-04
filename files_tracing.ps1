# **************************************

# Nebula Script. Backup-PDF Mod 2.0 (Ussuriysk location)
# (c) Ivan Bogdanov. 2024-2025
# My contacts: fluenoriph@gmail.com, fluenoriph@yandex.ru
# Powered by Open Source 

# **************************************

using namespace System.Collections.Generic


$script:break_line = '- ' * 40
$script:flow_separator = '> ' * 40

[System.Collections.Hashtable] $script:data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; 
        '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}

[scriptblock] $script:log_path = { param($month) ".\logs\отчет_$month.txt" }


class BackupBlock {
    <# (Суммы сканов: result_sums)
        
    0. Ф-Ф Уссурийск, Рад. Уссурийск, Меб. Уссурийск; 
    1. Ф-Ф Арсеньев, Рад. Арсеньев, Меб. Арсеньев;
    2. Физ. факторы, Радиация, Мебель;
    3. Все абсолютно, ЕИАС, Уссурийск, Арсеньев.
    #>

    hidden [List[psobject]] $files
    hidden [string] $year = (Get-Date -Format "yyyy")
    hidden [string] $time_span
    hidden [list[psobject]] $result_sums = @(@(0, 0, 0), @(0, 0, 0), @(0, 0, 0), @(0, 0, 0, 0))    
    hidden [List[string]] $missing_protocols
    hidden [bool] $status
                
    hidden [List[string]] $file_type_patterns = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-'
    hidden [List[psobject]] $protocol_type_patterns = (('[ф]', '[ф][а]'), ('[р]', '[р][а]'), ('[м]', '[м][а]'))
    hidden [List[string]] $protocol_location = 'Уссурийск', 'Арсеньев'
    hidden [List[string]] $protocol_types = 'Физические факторы', 'Радиационный контроль', 'Замеры мебели'
    
    hidden [scriptblock] $result_out = { Write-Host ("$($script:break_line)`n`nУспешно! Скопировано файлов за $($this.time_span) - $($this.result_sums[3][0])`n") }
    hidden [scriptblock] $drop_backup = { Write-Host "`nРезервное копирование сброшено!`n$('*' * 31)`n" }
    hidden [scriptblock] $folder_create_error = { param($dir) Write-Host "`n* Ошибка! * >> Не удалось создать директорию '$dir'`n" }
    hidden [scriptblock] $copy_fix = { Read-Host "Подтвердить - (Y); Отмена - (N)" } 
    hidden [scriptblock] $entry_error = { Write-Host "`n* Неправильный символ! *`n" }
    
    BackupBlock([string] $month_value) {
        if ($script:data_month.Keys -contains $month_value) { $this.time_span = $script:data_month.$month_value }
        else { $this.time_span = -join($this.year, ' г.') }
                                                                         
        [list[psobject]] $files_block = @(@(), @())
        foreach ($i in 0..1) { $files_block[$i] = Get-ChildItem -Path source:\ -File | Where-Object Name -Match $($this.file_type_patterns[$i] + "\d{2}\.$month_value\.$($this.year)\.pdf$") }
        
        $this.result_sums[3][1] = $files_block[1].Count
        $this.result_sums[3][0] = $files_block[0].Count + $files_block[1].Count
                
        if ($this.result_sums[3][0] -ne 0) {
            foreach ($i in 0..2) {
                foreach ($j in 0..1) {
                    $pattern = $this.protocol_type_patterns[$i][$j]

                    [List[int]] $numbers = $files_block[0] | Where-Object Name -Match "^(?<number>\d+)-$pattern-" | ForEach-Object { [int]$Matches.number } | Sort-Object
                    $sum = $numbers.Count
                    $this.result_sums[$j][$i] += $sum

                    if ($sum -gt 2) {
                        [List[int]] $range = $numbers[0]..$numbers[-1]
                        $numbers.ForEach({ $range.Remove($_) }) 
                        
                        if ($range.Count -gt 0) {
                            $this.missing_protocols += $range | ForEach-Object { -join([string]$_, '-', $pattern.Replace('[', '')) } | ForEach-Object { $_.Replace(']', '') }
                        }
                        else { continue }
                    }
                    else { continue }
                }

                $type_uss = $this.result_sums[0][$i]
                $type_ars = $this.result_sums[1][$i]

                $this.result_sums[2][$i] = $type_uss + $type_ars
                $this.result_sums[3][2] += $type_uss
                $this.result_sums[3][3] += $type_ars
            }

            foreach ($i in (0, 1)) { $this.files += $files_block[$i] }
            $this.files | Sort-Object
            $this.status = $true        
        }
        else { 
            $this.status = $false
            Write-Host "`nЗа $($this.time_span) сканов протоколов не найдено!`n" 
        }
    }
    
    [void] backuping() {
        [List[psobject]] $temp_block = @(@(), @())
        [string] $backup_dir = -join('destination:\', '\', $this.time_span)
        
        if (-not (Test-Path $backup_dir)) { 
            New-Item -Path $backup_dir -Type "directory" 2>$null
            if ($? -eq $false) { 
                &$this.folder_create_error -dir $backup_dir
                &$this.drop_backup
                return 
            }
        }
                
        foreach ($i in $this.files) {
            if (Test-Path $(-join($backup_dir, '\', $i.Name))) { $temp_block[0] += $i }
            else { $temp_block[1] += $i }
        }
        
        if ($temp_block[0].Count -eq 0) { 
            $this.files | Copy-Item -Destination $backup_dir
            &$this.result_out
        }
        else {
            [List[string]] $d = $temp_block[0] | ForEach-Object { $_.Name.Replace('.pdf', '') } 
            Write-Host "$($script:flow_separator)`n`nВнимание! Следующие файлы уже существуют в хранилище и будут перезаписаны`n`n$($d -join "`n")`n"
            [string] $task = ''

            do {
                $task = &$this.copy_fix

                if ($task -eq 'Y') {
                    $temp_block[0] | Copy-Item -Destination $backup_dir -Force
                    $temp_block[1] | Copy-Item -Destination $backup_dir
                    &$this.result_out
                }
                elseif ($task -eq 'N') { 
                    &$this.drop_backup
                    return 
                }
                else { &$this.entry_error }

            } while ($task -ne 'Y' -and $task -ne 'N')
        }   
    }
           
    [List[string]] out_missing_numbers() {
        if ($this.missing_protocols.Count -gt 0) { return ">> Пропущенные сканы (номера протоколов):`n`n$($this.missing_protocols -join "`n")" }
        else { return $null }
    }

    [List[string]] out_block_log() {
        [List[string]] $log = "`nПериод: $($this.time_span)", "Всего сканов: $($this.result_sums[3][0])", "> ЕИАС: $($this.result_sums[3][1])", 
            "> $($this.protocol_location[0]): $($this.result_sums[3][2])", "> $($this.protocol_location[1]): $($this.result_sums[3][3])", "> Пропущенных: $($this.missing_protocols.Count)`n"
        
        foreach ($i in 0..2) {
            [string] $location_sums = foreach ($j in 0..1) { "  * $($this.protocol_location[$j]): $($this.result_sums[$j][$i])`n" }

            $log.Add("| $($this.protocol_types[$i]) - всего: $($this.result_sums[2][$i])")
            $log.Add($location_sums)
        }        
        return $($log -join "`n")
    }

    [void] logging() {
        $data = $this.out_block_log()
        $t = $this.files | ForEach-Object { $_.name }   
        $data.Add("`nОтправленные сканы:`n`n$($t -join "`n")")
        $data.Add($this.out_missing_numbers())
        $data.Add($script:break_line)
        $data | Out-File -FilePath $(&$script:log_path -month $this.time_span)
    }
}
   

class DrivesControl {
    hidden [string] $config = '.\config_pathes.ini'   
    hidden [list[psobject]] $pathes

    hidden [List[string]] $drive_types = 'source', 'destination'
    hidden [System.Collections.Hashtable] $drives = @{'-s' = $this.drive_types[0]; '-d' = $this.drive_types[1]}
    hidden [System.Collections.Hashtable] $drive_setup_status = @{$this.drive_types[0] = $false; $this.drive_types[1] = $false}    

    hidden [scriptblock] $bad_path_message = { param($dir_type_out, $path) "$dir_type_out'$path' не существует или неверное имя! >> Установите верный путь!`n" }
    hidden [scriptblock] $write_directory_type = { param($type) if ($type -eq $this.drive_types[0]) { "Исходная директория: " } else { "Директория резервного копирования: " } }
    
    DrivesControl() {
        if (Test-Path -Path $this.config) {
            $this.pathes = Get-Content -Path $this.config -Encoding utf8 | ConvertFrom-StringData  
            
            foreach ($disk in $this.drive_types) {
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
            Write-Host "$($script:break_line)`n`nКонфигурация директории: <тип директории> [тип: -s - исходный; -d - резервный] <путь>`n`n>> Пример: -s C:\Folder\Source files`n"
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
                Write-Host "`n* Введен неверный тип директории! * >> Введите заново!`n"
            }
            
        } while ($err -eq $false)
    }
}


Set-Alias -Name bp -Value backup_process
Set-Alias -Name fp -Value find_protocol
Set-Alias -Name li -Value get_log_info
Set-Alias -Name hp -Value get_script_info

Write-Host @"

$script:break_line
  * * * * * * * *  Резервное копирование сканов протоколов  * * * * * * * * * 
$script:break_line

| Запуск копирования > 'bp'
| Поиск протокола в резервном хранилище > 'fp'
| Отобразить отчет за месяц > 'li'
| Перенастроить рабочие пути > 'rc'

  Подробная справка: 'hp'
$script:flow_separator

"@

$drives_control = [DrivesControl]::new()
Write-Host $(-join(('* ' * 40), "`n"))
function rc { return $drives_control.reconfig_path() }

function backup_process {
    if ($drives_control.drive_setup_status.source -eq $true -and $drives_control.drive_setup_status.destination -eq $true) {
        $month_values = $script:data_month.Keys | Sort-Object
        $year_value = 'full'
        [scriptblock] $accept_copy = { Write-Host "$($script:break_line)`n`n* Подтвердите копирование в резервное хранилище!`n" }
        Write-Host "$($script:break_line)`n`n>> Выберите, за какой период нужно отправить сканы >>`n`n> Месяц > [$($month_values -join '; ')] <`n> За весь год > [$year_value] <`n"

        do {
            $value = Read-Host "Ввод"      
            
            if ($month_values -contains $value) {
                $data_block = [BackupBlock]::new($value)
                
                if ($data_block.status -eq $true) {     
                    $script:flow_separator
                    $data_block.out_block_log()
                    $data_block.out_missing_numbers()
                    &$accept_copy
                    
                    do {
                        $fix = &$data_block.copy_fix

                        if ($fix -eq 'Y') {
                            $data_block.backuping()
                            $data_block.logging()
                        }
                        elseif ($fix -eq 'N') {
                            &$data_block.drop_backup
                            return
                        }
                        else { 
                            &$data_block.entry_error
                            continue 
                        }

                    } while ($fix -ne 'Y' -and $fix -ne 'N') 
                }
                else { return }
            }
            elseif ($value -ceq $year_value) {
                $full_block = [BackupBlock]::new('\d{2}')
                $script:flow_separator
                $full_block.out_block_log()
                &$accept_copy

                do {
                    $fix = &$full_block.copy_fix

                    if ($fix -eq 'Y') {
                        foreach ($i in $month_values) {
                            $step_block = [BackupBlock]::new($i)
            
                            if ($step_block.status -eq $true) {
                                $step_block.backuping()
                                $step_block.logging()
                            }
                        }  
                    }
                    elseif ($fix -eq 'N') {
                        &$full_block.drop_backup
                        return
                    }
                    else { 
                        &$full_block.entry_error
                        continue 
                    }

                } while ($fix -ne 'Y' -and $fix -ne 'N')   
            }
            else { 
                Write-Host "`n* Неверное значение! * >> Попробуйте заново!`n" 
                continue
            }

        } while ($month_values -notcontains $value -and $value -cne $year_value) 
    }
    else { exit }
}

function find_protocol {
    [scriptblock] $err = { Write-Host "`n* Системная ошибка! *`n" }

    Write-Host "$($script:break_line)`nПример: (123-A; 12345-01-02)`n"
    $mask = Read-Host "Введите номер протокола"
    $result = Get-ChildItem -Path destination:\ -File -Recurse | Where-Object Name -Like "$($mask)*.pdf"

    if ($result.Count -gt 0) {
        if ($? -eq $true) {
            Write-Host "`n>> Найдено:"
            $result | Format-Table -Property Name -HideTableHeaders

            Write-Host "$($script:break_line)`nКопировать на рабочий стол ?`n"
            $select = Read-Host "Да - 'Y'; Отмена - <любой символ>"

            if ($select -eq 'Y') {
                $result | Copy-Item -Destination {$home + '\Desktop'}
                
                if ($? -eq $true) { Write-Host "`nУспешно!`n" }
                else { 
                    &$err
                    return 
                }
            }
            else {
                Write-Host ''
                return 
            }
        }
        else { 
            &$err
            return 
        }
    }
    else { Write-Host "`n>> Ничего не найдено!`n" }
}

function get_log_info {
    $script:break_line
    Write-Host "`n* Все файлы отчетов расположены в папке: '$(-join($current_script_path, '\logs'))'`n"
    $x = Read-Host "Для текущего отображения введите значение месяца"
    
    if ($script:data_month.Keys -contains $x) {
        $script:flow_separator
        Get-Content -Path $(&$script:log_path -month $script:data_month.$x) | Write-Host  # error file not exist
    }
    else { return }
}

function get_script_info { return Get-Help .\files_tracing.ps1 -Full }


<#
.SYNOPSIS
    Сценарий files_tracing.ps1

    * Nebula Script. Backup-PDF Mod 2.0 (Уссурийск)
    * (c) Иван Богданов. 2025 г. Все права защищены. 
.DESCRIPTION
    <bp>     Копировать за месяц. Параметры: [01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12]
             Копировать за год: [full]

    <fp>     Поиск скана протокола в резервной директории. Параметры: [пример - (123-A; 12345-01-02)]

    <li>     Отобразить отчет из текстового файла. Параметры: [01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12]

    <rc>     Настойка директорий. Параметры: [-s: исходная; -d: резервная] [путь]
             Пример: -d X:\Folder\Files folder   
.NOTES
    Псевдонимы функций:
    
    backup_process >> bp
    find_protocol >> fp
    get_log_info >> gl
    get_script_info >> hp
    [DrivesControl].reconfig_path >> rc (reload method)

    Правильные имена файлов сканов:
        Протокол ЕИАС: 12345-01-02-31.01.2025
        Обычный протокол: 1-а-31.01.2025
    
    Важно!!! Программа работает только с файлами 'PDF'. 
    Именовать сканы строго по вышеприведенным маскам!
 #>