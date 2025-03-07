$global:data_month = @{'01' = "Январь"; '02' = "Февраль"; '03' = "Март"; '04' = "Апрель"; '05' = "Май"; '06' = "Июнь"; '07' = "Июль"; '08' = "Август"; '09' = "Сентябрь"; '10' = "Октябрь"; '11' = "Ноябрь"; '12' = "Декабрь"}

$source = 'C:\Users\Mahabhara\Desktop\сканы'

$dest = 'C:\Users\Mahabhara\Desktop\result_test\Январь'   # + '01'  -join

$month_value = '01'   # validation ..keys ??


class BackupBlock {
    [string] $source_path
    hidden [array] $files = @(@(), @())

    [string] $month_value
    [int] $all_sum
    [int] $simple_files_sum
    [int] $eias_files_sum
    
    hidden [int[]] $protocol_type_sums
    [string[]] $missing_protocols
    
    hidden [string[]] $rgx = '^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-', '[ф]', '[р]', '[м]', '[ф][а]', '[р][а]', '[м][а]'
    
    BackupBlock([string] $p) {
        $this.source_path = $p
    }

    [array] get_files_block([string] $x) {        # обработка исключения
        foreach ($i in (0, 1)) { $this.files[$i] = Get-ChildItem -Path $this.source_path | Where-Object Name -Match $($this.rgx[$i] + "\d{2}\.$x\.\d{4}\.pdf$") }
        
        $this.month_value = $global:data_month[$x]
        $this.simple_files_sum = $this.files[0].Count
        $this.eias_files_sum = $this.files[1].Count
        $this.all_sum = $this.simple_files_sum + $this.eias_files_sum

        if ($this.all_sum -ne 0) {
            foreach ($i in $this.rgx[2..7]) {
                [int[]]$n = $this.files[0] | Where-Object Name -Match "^(?<number>\d+)-$i-" | ForEach-Object { [int]$Matches.number } | Sort-Object
                $this.protocol_type_sums += $n.Count
                
                if ($n.Count -gt 2) {
                    $y = [System.Collections.ArrayList]::new()
                    $y.AddRange($n[0]..$n[-1])
                    $n.GetEnumerator().ForEach({ $y.Remove($_) })
                    
                    if ($y.Count -gt 0) {
                        $this.missing_protocols += $y | ForEach-Object { -join([string]$_, '-', $i.Replace('[', '')) } | ForEach-Object { $_.Replace(']', '') }   
                    }
                    else { continue }
                }
                else { continue }
            }
        }
        else { Write-Host "За $($this.month_value) сканов не найдено !" }
    
    return $this.files[0] + $this.files[1] | Sort-Object        
    } 
}


class Backuping {
    [string] $destination_path

    [array] $prepared_block
        
    [bool] $status
    [int] $sent_files
        
    Backuping([string] $p, [array] $x) {
        $this.destination_path = $p
        $this.prepared_block = $x
    }

    [bool] tracing([array] $x) {
        $x | Copy-Item -Destination $this.destination_path      # check errors !!!!

        if ($?) {
            $this.sent_files = $x.Count
            return $this.status = $true 
        }
        else { return $this.status = $false }
    }

    [int] find_duplicates() {
        $j = 0
        [string[]]$files_in_backup_storage = Get-ChildItem -Path $this.destination_path -File -Filter *.pdf -Name | Sort-Object    
        
        if ($files_in_backup_storage.Count -gt 0) {
            foreach ($i in $this.prepared_block) {
                if ($this.files_in_backup_storage -contains $i.Name) { $j += 1 }
                else { continue }
            }
            return $j
        }
        else { return $j }        
    }

    [void] backup() {
        if ($this.find_duplicates() -eq 0) {
            $this.tracing($this.prepared_block)     
        }
        else {
            Write-Host 
            
            

        }

    }
    
}


$x = [BackupBlock]::new($source)

$y = [Backuping]::new($dest)

$f = $x.get_files_block($month_value)









