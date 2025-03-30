# **************************************

# Nebula Script. Backup-PDF Mod 2.0
# (c) Ivan Bogdanov. 2024-2025
# My contacts: fluenoriph@gmail.com, fluenoriph@yandex.ru
# Powered by Open Source 

# **************************************

using namespace System.Collections.Generic


$script:break_line = '- ' * 30
$script:flow_separator = '> ' * 40


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
        
    hidden [System.Collections.Hashtable] $data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; 
        '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}
    hidden [List[string]] $file_type_patterns = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-'
    hidden [List[psobject]] $protocol_type_patterns = (('[ф]', '[ф][а]'), ('[р]', '[р][а]'), ('[м]', '[м][а]'))
    hidden [List[string]] $protocol_location = 'Уссурийск', 'Арсеньев'
    hidden [List[string]] $protocol_types = 'Физические факторы', 'Радиационный контроль', 'Замеры мебели'
    hidden [scriptblock] $result_out = { Write-Host ("`nУспешно! Скопировано файлов за $($this.time_span) - $($this.result_sums[3][0])`n") }
    hidden [scriptblock] $log_path = { param($month) ".\logs\отчет_$month.txt" }
    hidden [scriptblock] $drop_backup = { Write-Host "`nРезервное копирование сброшено!`n$('*' * 31)`n" }
    hidden [scriptblock] $folder_create_error = { param($dir) Write-Host "`n* Ошибка! * >> Не удалось создать директорию '$dir'`n" }
    hidden [scriptblock] $copy_fix = { Read-Host "Подтвердить - (Y); Отмена - (N)" } 
    hidden [scriptblock] $entry_error = { Write-Host "`n* Неправильный символ! *`n" }
    
    BackupBlock([string] $month_value) {
        if ($this.data_month.Keys -contains $month_value) { $this.time_span = $this.data_month.$month_value }
        else { $this.time_span = -join($this.year, ' г.') }
                                                                         # обработка исключения
        [list[psobject]] $files_block = @(@(), @())
        foreach ($i in 0..1) { $files_block[$i] = Get-ChildItem -Path source:\ -File | Where-Object Name -Match $($this.file_type_patterns[$i] + "\d{2}\.$month_value\.$($this.year)\.pdf$") }
        
        $this.result_sums[3][1] = $files_block[1].Count
        $this.result_sums[3][0] = $files_block[0].Count + $files_block[1].Count
                
        if ($this.all_sum -ne 0) {
            foreach ($i in 0..2) {
                foreach ($j in 0..1) {
                    $pattern = $this.protocol_type_patterns[$i][$j]

                    [List[int]] $numbers = $files_block[0] | Where-Object Name -Match "^(?<number>\d+)-$pattern-" | ForEach-Object { [int]$Matches.number } | Sort-Object
                    $sum = $numbers.Count

                    $this.result_sums[$j][$i] += $sum

                    if ($sum -gt 2) {
                        [List[int]] $range = $numbers[0]..$numbers[-1]
                        $numbers.ForEach({ $range.Remove($_) })   # !! test
                        
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
                # try catch ???
        if ($temp_block[0].Count -eq 0) { 
            $this.files | Copy-Item -Destination $backup_dir
            &$this.result_out
        }
        else {
            [List[string]] $d = $temp_block[0] | ForEach-Object { $_.Name.Replace('.pdf', '') } 
            Write-Host "`nВнимание! Следующие файлы уже существуют в хранилище и будут перезаписаны.`n`n$($d -join "`n")`n"
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
                else { 
                    &$this.entry_error
                    continue
                }

            } while ($task -ne 'Y' -and $task -ne 'N')
        }   
    }
           
    [List[string]] out_missing_numbers() {
        if ($this.missing_protocols.Count -gt 0) { return "`n** Пропущенные сканы (номера протоколов):`n`n$($this.missing_protocols -join "`n")" }
        else { return "`nПропущенных нет!" }
    }

    [List[string]] out_block_log() {
        [List[string]] $log = "`nПериод: $($this.time_span)", "Всего сканов: $($this.result_sums[3][0])", "> ЕИАС: $($this.result_sums[3][1])", "> $($this.protocol_location[0]): $($this.result_sums[3][2])", "> $($this.protocol_location[1]): $($this.result_sums[3][3])`n"
        
        foreach ($i in 0..2) {
            [string] $location_sums = foreach ($j in 0..1) { "  * $($this.protocol_location[$j]): $($this.result_sums[$j][$i])`n" }

            $log.Add("| $($this.protocol_types[$i]) - всего: $($this.result_sums[2][$i])")
            $log.Add($location_sums)
        }
        $log.Add(">> Пропущенных: $($this.missing_protocols.Count)")
                
        return $($log -join "`n")
    }

    [void] logging() {
        $data = $this.out_block_log()
        $t = $this.files | ForEach-Object { $_.name }
        $data += "`nОтправленные сканы:`n`n$($t -join "`n")"
        $data += $this.out_missing_numbers()
        $data += $script:break_line
        $data | Out-File -FilePath $(&$this.log_path -month $this.time_span)
    }

    [void] get_log_info([string] $x) {
        Get-Content -Path $(&$this.log_path -month $this.data_month.$x) | Write-Host
    }
}
   

class DrivesControl {
    hidden [string] $config = '.\config_pathes.ini'   
    hidden [list[psobject]] $pathes

    hidden [System.Collections.Hashtable] $drives = @{'-s' = 'source'; '-d' = 'destination'}
    hidden [System.Collections.Hashtable] $drive_setup_status = @{'source' = $false; 'destination' = $false}    #test !!!

    hidden [scriptblock] $bad_path_message = { param($dir_type_out, $path) "$dir_type_out'$path' не существует или неверное имя! >> Установите верный путь!`n" }
    hidden [scriptblock] $write_directory_type = { param($type) if ($type -eq 'source') { "Исходная директория: " } else { "Директория резервного копирования: " } }
    
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
            Write-Host "$($script:break_line)`n<тип директории> [тип: -s - исходный; -d - резервный]`n`n>> Пример: -s C:\Directory\Folder\Source files`n"
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

$script:break_line
    ** Резервное копирование сканов протоколов ** 
$script:break_line     
| Копирование за месяц > 'month <значение месяца>' (01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12)
| Копирование за год > 'year'
| Поиск протокола по номеру > 'find <номер>' (123-A; 12345-01-02)
| Получить отчет за месяц > 'report <значение месяца>' (01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12)
| Создание папок по месяцам > 'cmds' ([директория по умолчанию]) 

  Подробная справка: 'help'
$script:flow_separator

"@

$drives_control = [DrivesControl]::new()
function rc { return $drives_control.reconfig_path() }

function backup_process {
    if ($drives_control.drive_setup_status.source -eq $true -and $drives_control.drive_setup_status.destination -eq $true) {
        $month_values = '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'
        $year_value = 'full'
        [scriptblock] $accept_copy = { Write-Host "$($script:break_line)`n>> Подтвердите копирование в резервное хранилище!`n" }
        Write-Host "$($script:break_line)`n>> Выберите, за какой период нужно отправить сканы >>`n`n> Месяц > [$($month_values -join '; ')] <`n> За весь год > [$year_value] <`n"

        do {
            $value = Read-Host "Ввод"
            
            if ($month_values -contains $value) {
                $data_block = [BackupBlock]::new($value)
                
                if ($data_block.status -eq $true) {     
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
