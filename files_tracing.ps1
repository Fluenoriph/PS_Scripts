using namespace System.Collections.Generic


$global:data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}

$source = -join ($home, '\Desktop\сканы')

$month_value = '01'   # validation ..keys ??

$dest = -join ($home, '\Desktop\result_test\', $global:data_month[$month_value])  


class BackupBlock {
    hidden [string] $source_path
    hidden [List[psobject]] $files = @(@(), @())

    [string] $month_value
    hidden [List[int]] $simple_files_types_sums   # show dict !!
    [int] $eias_files_sum
    [int] $all_sum
    [List[psobject]] $missing_protocols
    
    hidden [List[string]] $rgx = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-', '[ф]', '[р]', '[м]', '[ф][а]', '[р][а]', '[м][а]'
    
    BackupBlock([string] $p) {
        $this.source_path = $p
    }

    [List[System.IO.FileInfo]] get_files_block([string] $x) {        # обработка исключения
        foreach ($i in (0, 1)) { $this.files[$i] = Get-ChildItem -Path $this.source_path | Where-Object Name -Match $($this.rgx[$i] + "\d{2}\.$x\.\d{4}\.pdf$") }
        
        $this.month_value = $global:data_month[$x]
        $this.eias_files_sum = $this.files[1].Count
        $this.all_sum = $this.files[0].Count + $this.eias_files_sum

        if ($this.all_sum -ne 0) {
            foreach ($i in $this.rgx[2..7]) {
                [List[int]] $n = $this.files[0] | Where-Object Name -Match "^(?<number>\d+)-$i-" | ForEach-Object { [int]$Matches.number } | Sort-Object
                $this.simple_files_types_sums += $n.Count
                
                if ($n.Count -gt 2) {
                    $this.missing_protocols = $n[0]..$n[-1]
                    $n.GetEnumerator().ForEach({ $this.missing_protocols.Remove($_) })
                    
                    if ($this.missing_protocols.Count -gt 0) {
                        $this.missing_protocols | ForEach-Object { -join([string]$_, '-', $i.Replace('[', '')) } | ForEach-Object { $_.Replace(']', '') }   
                    }
                    else { continue }
                }
                else { continue }
            }
        }
        else { Write-Host "За $($this.month_value) сканов протоколов не найдено !" }
    
    return $this.files[0] + $this.files[1] | Sort-Object        
    } 
}


class Backuping {
    hidden [string] $destination_path    
    hidden [List[int]] $sent_files
        
    Backuping([string] $p) {
        $this.destination_path = $p
    }
        
    [int] backup([List[System.IO.FileInfo]] $prepared_block) {
        [List[psobject]] $backup_block = @(@(), @())
        [List[System.IO.FileInfo]] $dupl = @()
        
        foreach ($i in $prepared_block) {
            $file_path = -join($this.destination_path, '\', $i.Name)

            if (Test-Path $file_path) { $dupl += $i }
            else { $backup_block[1] += $i }
        }
                # try catch ???
        if ($backup_block[0].Count -eq 0) {
            $backup_block[1] | Copy-Item -Destination $this.destination_path
        }
        else {
            $d = $dupl | Select-Object -Property Name
            Write-Host "Внимание ! Следующие файлы уже существуют в хранилище и будут перезаписаны.`n"
            Write-Host $d
            $task = Read-Host 'Подтвердить: (Y); Отмена (N)'

            if ($task -eq 'Y') {
                $backup_block[0] | Copy-Item -Destination $this.destination_path -Force
                $backup_block[1] | Copy-Item -Destination $this.destination_path
            }
            else { $backup_block[1] | Copy-Item -Destination $this.destination_path }
        }
        $this.sent_files.Add($backup_block[0].Count)
        $this.sent_files.Add($backup_block[1].Count)

        return $this.sent_files
    }   
}


$x = [BackupBlock]::new($source)
$y = [Backuping]::new($dest)

$f = $y.backup($x.get_files_block($month_value))









