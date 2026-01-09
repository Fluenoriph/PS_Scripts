# Суммы каждого типа файла в директории

using namespace System.Collections.Generic


$side_border = '|'
$top_border = "--------------------------------------"

$target_dir = Read-Host "`n>>> Введите требуемую директорию"

$calc_file_sums = [FileTypeSum]::new($target_dir)

if ($calc_file_sums.is_correct)
{
    Write-Host "`n> Директория - $($calc_file_sums.directory) содержит следующие файлы:`n$($top_border)"

    foreach ($item in $calc_file_sums.result_file_sum.GetEnumerator())
    {
        Write-Host "$($side_border) $($item.Key) - $($item.Value)"
    }

    Write-Host "$($top_border)`n| Всего файлов: $($calc_file_sums.all_files_sum)`n"
}
else 
{
    Write-Host "`n* Ошибка скрипта ! Перезапустите заново !"
    return
}

        
class FileTypeSum
{
    [string] $directory
    [list[string]] $file_types_list
    [int] $all_files_sum
    [Dictionary[string, int]] $result_file_sum = @{}   
    [bool] $is_correct
        
    FileTypeSum([string] $target_directory)
    {
        $this.directory = $target_directory

        $file_list = Get-ChildItem -Path $this.directory -File -Recurse -Force | ForEach-Object {$_.Extension.Replace('.', '').ToUpper()}
        $this.all_files_sum = $file_list.Count
        $this.file_types_list = $file_list | Sort-Object
        
        $this.CalculateEachFileType()
        
        $test_sum = 0

        foreach ($item_value in $this.result_file_sum.Values)
        {
            $test_sum += $item_value
        }

        if ($this.all_files_sum -eq $test_sum)
        {
            $this.is_correct = $true
        }
        else 
        {
            $this.is_correct = $false
        }
    }  

    [void] CalculateEachFileType()
    {
        for ($file_type_index = 0; $file_type_index -lt $this.all_files_sum; $file_type_index++) 
        {
            $start_file_type = $this.file_types_list[$file_type_index]
            
            if (-not $this.result_file_sum.ContainsKey($start_file_type))
            {
                $file_type_count = 1

                for ($start_index = $file_type_index + 1; $start_index -lt $this.all_files_sum; $start_index++)
                {
                    if ($start_file_type -eq $this.file_types_list[$start_index])
                    {
                        $file_type_count += 1
                    }
                }

                $this.result_file_sum.Add($start_file_type, $file_type_count)
            }
        }        
    }
}











