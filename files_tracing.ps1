using namespace System.Collections.Generic


$global:data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}

$global:separatop = '- - - - - - - - - - - - - - - - - - - - - - - - - - - -'

$source = -join ($home, '\Desktop\сканы')

$month_value = '01'   # validation ..keys ??

$main_dest_path = -join($home, '\Desktop\result_test\')

$dest = -join ($main_dest_path, $global:data_month[$month_value])  


class BackupBlock {
    hidden [string] $source_path
    hidden [List[psobject]] $files = @(@(), @())

    [string] $month
    [int] $all_sum
    [int] $eias_files_sum
    hidden [List[int]] $simple_files_types_sums       
    [List[string]] $missing_protocols
    
    hidden [List[regex]] $rgx = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-', '[ф]', '[р]', '[м]', '[ф][а]', '[р][а]', '[м][а]'
    hidden [List[string]] $protocol_types = '> Физ. факторы (Усс.): ', '> Рад. контроль (Усс.): ', '> Замеры мебели (Усс.): '
    hidden [List[string]] $log_path = '.\logs\отчет_', '.txt'
    
    BackupBlock([string] $p) {
        $this.source_path = $p
    }

    [List[System.IO.FileInfo]] get_files_block([string] $x) {        # обработка исключения
        foreach ($i in (0, 1)) { $this.files[$i] = Get-ChildItem -Path $this.source_path -File | Where-Object Name -Match $($this.rgx[$i] + "\d{2}\.$x\.\d{4}\.pdf$") }
        
        $this.month = $global:data_month[$x]
        $this.eias_files_sum = $this.files[1].Count
        $this.all_sum = $this.files[0].Count + $this.eias_files_sum

        if ($this.all_sum -ne 0) {
            foreach ($i in $this.rgx[2..7]) {
                [List[int]] $n = $this.files[0] | Where-Object Name -Match "^(?<number>\d+)-$i-" | ForEach-Object { [int]$Matches.number } | Sort-Object
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

            $this.protocol_types += $this.protocol_types | ForEach-Object { $_.Replace('Усс', 'Арс') }
            Write-Host $this.out_block_log()
            Write-Host "*** Пропущенные сканы:`n$($this.missing_protocols -join "`n")"
        }
        else { Write-Host "`nЗа $($this.month) сканов протоколов не найдено!`n" }
    
    return $this.files[0] + $this.files[1] | Sort-Object        
    }
    
    [List[string]] out_block_log() {
        [List[string]] $log = "`nПериод (месяц): $($this.month)", "Всего сканов: $($this.all_sum)`n", "> ЕИАС: $($this.eias_files_sum)"
        
        foreach ($i in 0..5) { $log.Add($(-join($this.protocol_types[$i], $this.simple_files_types_sums[$i]))) }
        $log.Add("`n")
        
        return $($log -join "`n")
    }

    [void] logging() {
        $data = $this.out_block_log() 
        $data += $this.files | ForEach-Object { $_.name }
        $data | Out-File -FilePath $(-join($this.log_path[0], $this.month, $this.log_path[1]))      
    }

    [void] get_log_info([string] $x) {
        Get-Content -Path $(-join($this.log_path[0], $global:data_month[$x], $this.log_path[1])) | Write-Host
        Write-Host "`n"
    }


}


class Backuping {
    hidden [string] $destination_path    
    [int] $backuping_count
    hidden [string] $out_log = "`nУспешно! Скопировано файлов: "
        
    Backuping([string] $p) { 
        $this.destination_path = $p 
    }
        # status ??
    [void] backup([List[System.IO.FileInfo]] $prepared_block) {
        [List[psobject]] $backup_block = @(@(), @())
                
        foreach ($i in $prepared_block) {
            if (Test-Path $(-join($this.destination_path, '\', $i.Name))) { $backup_block[0] += $i }
            else { $backup_block[1] += $i }
        }
                # try catch ???
        if ($backup_block[0].Count -eq 0) { 
            $prepared_block | Copy-Item -Destination $this.destination_path
            $this.backuping_count = $prepared_block.Count
            Write-Host $(-join($this.out_log, [string] $this.backuping_count, "`n"))
        }
        else {
            [List[string]] $d = $backup_block[0] | ForEach-Object { $_.Name.Replace('.pdf', ';') } 
            Write-Host "`nВнимание! Следующие файлы уже существуют в хранилище и будут перезаписаны.`n`n$($d -join "`n")`n"
            $task = Read-Host "Подтвердить - (Y); Отмена - (N)"

            if ($task -eq 'Y') {
                $backup_block[0] | Copy-Item -Destination $this.destination_path -Force
                $backup_block[1] | Copy-Item -Destination $this.destination_path
                $this.backuping_count = $backup_block[0].Count + $backup_block[1].Count
                Write-Host $(-join($this.out_log, [string] $this.backuping_count, "`n"))
            }
            else { 
                Write-Host "`nРезервное копирование сброшено!`n"
            }          
        }   
    }
    
    [void] create_backup_folders() {

    }

}


class DrivesControls {
    [string] $config = '.\config_pathes.ini'   
    [list[psobject]] $pathes
    [System.Collections.Hashtable] $drives = @{'-s' = 'source'; '-d' = 'destination'}
    [scriptblock] $bad_path_message = { param($dir_type_out, $path) "$dir_type_out'$path' не существует или неверное имя! >> Установите верный путь!`n" }
    
    DrivesControls() {        
        $this.pathes = Get-Content -Path $this.config -Encoding utf8 | ConvertFrom-StringData
                
        if ($? -eq $true) {
            foreach ($k in $this.drives.Keys | Sort-Object -Descending) {
                $disk = $this.drives.$k
                $path = $this.pathes.$disk
                $type_out = $this.write_directory_type($disk)

                New-PSDrive -Name $disk -PSProvider FileSystem -Root $path -Scope Global 2>$null

                if ($? -eq $false) { Write-Host $(&$this.bad_path_message -dir_type_out $type_out -path $path) }
                
                else { Write-Host $(-join($type_out, $path))}
            }           
        }
        else {
            Write-Host "`n* Ошибка чтения настроек! *`n`n>>> Файл '$($this.config)' не существует в корневой директории или неверное имя файла!`n"
        }
    }
    
    [void] reconfig_path() {
        [bool] $err = $true

        do {
            Write-Host $global:separatop
            Write-Host "<тип директория> [тип: -s - исходный; -d - резервный]`n`n>> Пример: -s C:\Directory\Folder\Source files`n"
            $x = Read-Host "Ввод"
            $parameters += $x -split " ", 2

            if ($parameters[0] -match "^[-][s|d]$") {
                $drive = $this.drives[$parameters[0]]
                Get-PSDrive -Name $drive 2>$null
                if ($? -eq $false) { Remove-PSDrive -Name $drive }
                
                (Get-Content -Path $this.config -Encoding utf8) -replace "$drive=.+", "$drive=$($parameters[1].Replace('\', '\\'))" | Set-Content -Path $this.config
                New-PSDrive -Name $drive -PSProvider FileSystem -Root $parameters[1] -Scope Global 2>$null
                $err = $?   
            
                if ($err -eq $false) { Write-Host $(&$this.bad_path_message -dir_type_out $this.write_directory_type($drive) -path $parameters[1]) }
                else { Write-Host $(-join($this.write_directory_type($drive), "успешно установлена!`n")) }   
            }
            else {
                Write-Host "`n* Введен неверный тип директории! * >> Вводите заново!`n"
                $err = $false
            }
            
        } while ($err -eq $false)
    }
    
    [string] write_directory_type([string] $type) {
        if ($type -eq 'source') { return "`nИсходная директория: " }
        
        else { return "`nДиректория резервного копирования: " }
    }
}

$x = [BackupBlock]::new($source)
$y = [Backuping]::new($dest)

#$f = $y.backup($x.get_files_block($month_value))

$d = [DrivesControls]::new()
#$x.logging()

#$x.get_log_info($month_value)










