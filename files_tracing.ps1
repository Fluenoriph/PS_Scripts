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
    hidden [string] $year = (Get-Date -Format "yyyy")
    hidden [string] $time_span
    hidden [int] $all_sum
    hidden [int] $eias_files_sum



    hidden [List[int]] $simple_files_types_sums       # !!!!!!!
    
    
    hidden [List[string]] $missing_protocols
    hidden [bool] $status
        
    hidden [System.Collections.Hashtable] $data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; 
        '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}

    hidden [List[string]] $file_type_patterns = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-'
    
    [List[string]] $protocol_type_patterns = '[ф]', '[р]', '[м]', '[ф][а]', '[р][а]', '[м][а]'
    hidden [List[string]] $protocol_types = '> Физ. факторы (Усс.): ', '> Рад. контроль (Усс.): ', '> Замеры мебели (Усс.): ', 
        '> Физ. факторы (Арс.): ', '> Рад. контроль (Арс.): ', '> Замеры мебели (Арс.): '
    
    hidden [scriptblock] $result_out = { Write-Host ("`nУспешно! Скопировано файлов за $($this.time_span) - $($this.all_sum)`n") }
    hidden [scriptblock] $log_path = { param($month) ".\logs\отчет_$month.txt" }
    hidden [scriptblock] $drop_backup = { Write-Host "`nРезервное копирование сброшено!`n" }
    hidden [scriptblock] $folder_create_error = { param($dir) Write-Host "`n* Ошибка! * >> Не удалось создать директорию '$dir'`n" }
    
    BackupBlock([string] $month_value) {
        if ($this.data_month.Keys -contains $month_value) { $this.time_span = $this.data_month.$month_value }
        else { $this.time_span = -join($this.year, ' г.') }
                                                                         # обработка исключения
        [list[psobject]] $files_block = @(@(), @())
        foreach ($i in (0, 1)) { $files_block[$i] = Get-ChildItem -Path source:\ -File | Where-Object Name -Match $($this.file_type_patterns[$i] + "\d{2}\.$month_value\.$($this.year)\.pdf$") }
        
        $this.eias_files_sum = $files_block[1].Count
        $this.all_sum = $files_block[0].Count + $this.eias_files_sum
                
        if ($this.all_sum -ne 0) {
            
            



            foreach ($i in $this.protocol_type_patterns) {
                
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
            [List[string]] $d = $temp_block[0] | ForEach-Object { $_.Name.Replace('.pdf', ';') } 
            Write-Host "`nВнимание! Следующие файлы уже существуют в хранилище и будут перезаписаны.`n`n$($d -join "`n")`n"
            $task = Read-Host "Подтвердить - (Y); Отмена - (N)"

            if ($task -eq 'Y') {
                $temp_block[0] | Copy-Item -Destination $backup_dir -Force
                $temp_block[1] | Copy-Item -Destination $backup_dir
                &$this.result_out
            }
            else { 
                &$this.drop_backup
                return 
            }          
        }   
    }
            # create !!
    [void] backup_to_year() {
        foreach ($key in $this.data_month.keys | Sort-Object) {
            $value = $this.data_month.$key
            $folder = -join('destination:\', '\', $value)

            if (-not (Test-Path $folder)) {
                New-Item -Path $folder -Type "directory" 2>$null
                if ($? -eq $false) { 
                    &$this.folder_create_error -dir $folder
                    &$this.drop_backup
                    break
                    return 
                }
            } 
        }
    }

    [List[string]] out_missing_numbers() {
        if ($this.missing_protocols.Count -gt 0) { return "`n** Пропущенные сканы (номера протоколов):`n`n$($this.missing_protocols -join "`n")" }
        else { return "`nПропущенных нет!" }
    }

    [List[string]] out_block_log() {
        [List[string]] $log = "`nПериод: $($this.time_span)", "Всего сканов: $($this.all_sum)`n", "> ЕИАС: $($this.eias_files_sum)"
        
        foreach ($i in 0..5) { $log.Add(-join($this.protocol_types[$i], $this.simple_files_types_sums[$i])) }

        $log.Add("`n>>> Пропущенных: $($this.missing_protocols.Count)")
                
        return $($log -join "`n")
    }

    [void] logging() {
        $data = $this.out_block_log()
        $t = $this.files | ForEach-Object { $_.name }
        $data += "`nОтправленные сканы:`n`n$($t -join "`n")"
        $data += $this.out_missing_numbers()
        $data += $global:break_line
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

function backup_process {
    $month_values = '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'
    $year_value = 'full'
    Write-Host "$($global:break_line)`n>> Выберите, за какой период нужно отправить сканы >>`n`n> Месяц > [$($month_values -join '; ')] <`n> За весь год > [$year_value]`n"

    do {
        $value = Read-Host "Ввод"
        
        if ($month_values -contains $value) {
            $data_block = [BackupBlock]::new($value)
            
            if ($data_block.status -eq $true) {     
                $data_block.out_block_log()
                $data_block.out_missing_numbers()
                $data_block.backuping()
                $data_block.logging()
            }
            else { return }
        }
        elseif ($value -ceq $year_value) {
            $full_block = [BackupBlock]::new('\d{2}')
            $full_block.out_block_log()
            $global:break_line
            
            foreach ($i in $month_values) {
                $step_block = [BackupBlock]::new($i)

                if ($step_block.status -eq $true) {
                    $step_block.backuping()
                    $step_block.logging()
                }
            }  
        }
        else { 
            Write-Host "`n* Неверное значение! * >> Попробуйте заново!`n" 
            continue
        }

    } while ($month_values -notcontains $value -and $value -cne $year_value) 
}

if ($drives_control.drive_setup_status.source -eq $true -and $drives_control.drive_setup_status.destination -eq $true) { backup_process }

else { exit }















